// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/flow_graph_optimizer.h"

#include "vm/flow_graph_builder.h"
#include "vm/il_printer.h"
#include "vm/object_store.h"

namespace dart {

DECLARE_FLAG(bool, enable_type_checks);
DECLARE_FLAG(bool, print_flow_graph);
DECLARE_FLAG(bool, trace_optimization);

void FlowGraphOptimizer::ApplyICData() {
  VisitBlocks();
  if (FLAG_print_flow_graph) {
    OS::Print("After Optimizations:\n");
    FlowGraphPrinter printer(Function::Handle(), block_order_);
    printer.PrintBlocks();
  }
}


void FlowGraphOptimizer::VisitBlocks() {
  for (intptr_t i = 0; i < block_order_.length(); ++i) {
    Instruction* instr = block_order_[i]->Accept(this);
    // Optimize all successors until an exit, branch, or a block entry.
    while ((instr != NULL) && !instr->IsBlockEntry()) {
      instr = instr->Accept(this);
    }
  }
}


static bool ICDataHasReceiverClassId(const ICData& ic_data, intptr_t class_id) {
  ASSERT(ic_data.num_args_tested() > 0);
  for (intptr_t i = 0; i < ic_data.NumberOfChecks(); i++) {
    const intptr_t test_class_id = ic_data.GetReceiverClassIdAt(i);
    if (test_class_id == class_id) {
      return true;
    }
  }
  return false;
}


static bool ICDataHasReceiverArgumentClasses(const ICData& ic_data,
                                             intptr_t receiver_class_id,
                                             intptr_t argument_class_id) {
  ASSERT(receiver_class_id != kIllegalObjectKind);
  ASSERT(argument_class_id != kIllegalObjectKind);
  if (ic_data.num_args_tested() != 2) return false;

  Function& target = Function::Handle();
  for (intptr_t i = 0; i < ic_data.NumberOfChecks(); i++) {
    GrowableArray<intptr_t> class_ids;
    ic_data.GetCheckAt(i, &class_ids, &target);
    ASSERT(class_ids.length() == 2);
    if ((class_ids[0] == receiver_class_id) &&
        (class_ids[1] == argument_class_id)) {
      return true;
    }
  }
  return false;
}


static bool HasOneSmi(const ICData& ic_data) {
  return ICDataHasReceiverClassId(ic_data, kSmi);
}


static bool HasTwoSmi(const ICData& ic_data) {
  return ICDataHasReceiverArgumentClasses(ic_data, kSmi, kSmi);
}


static bool HasMintSmi(const ICData& ic_data) {
  return ICDataHasReceiverArgumentClasses(ic_data, kMint, kSmi);
}


static bool HasOneDouble(const ICData& ic_data) {
  return ICDataHasReceiverClassId(ic_data, kDouble);
}


static bool HasTwoDouble(const ICData& ic_data) {
  return ICDataHasReceiverArgumentClasses(ic_data, kDouble, kDouble);
}


bool FlowGraphOptimizer::TryReplaceWithBinaryOp(InstanceCallComp* comp,
                                                Token::Kind op_kind) {
  BinaryOpComp::OperandsType operands_type;

  if (HasMintSmi(*comp->ic_data())) {
    // We check for Mint receiver and Smi argument, but we try to support any
    // combination of Mint and Smi.
    if (op_kind != Token::kBIT_AND) {
      // TODO(regis): Not yet supported.
      return false;
    }

    operands_type = BinaryOpComp::kMintOperands;
  }

  if (comp->ic_data()->NumberOfChecks() != 1) {
    // TODO(srdjan): Not yet supported.
    return false;
  }

  if (HasTwoSmi(*comp->ic_data())) {
    if (op_kind == Token::kDIV ||
        op_kind == Token::kMOD) {
      // TODO(srdjan): Not yet supported.
      return false;
    }

    operands_type = BinaryOpComp::kSmiOperands;
  } else if (HasTwoDouble(*comp->ic_data())) {
    if (op_kind != Token::kADD &&
        op_kind != Token::kSUB &&
        op_kind != Token::kMUL &&
        op_kind != Token::kDIV) {
      // TODO(vegorov): Not yet supported.
      return false;
    }

    operands_type = BinaryOpComp::kDoubleOperands;
  } else {
    // TODO(srdjan): Not yet supported.
    return false;
  }

  ASSERT(comp->instr() != NULL);
  ASSERT(comp->InputCount() == 2);
  Value* left = comp->InputAt(0);
  Value* right = comp->InputAt(1);
  BinaryOpComp* bin_op =
      new BinaryOpComp(op_kind,
                       operands_type,
                       comp,
                       left,
                       right);
  bin_op->set_ic_data(comp->ic_data());
  comp->ReplaceWith(bin_op);
  return true;
}


bool FlowGraphOptimizer::TryReplaceWithUnaryOp(InstanceCallComp* comp,
                                               Token::Kind op_kind) {
  if (comp->ic_data()->NumberOfChecks() != 1) {
    // TODO(srdjan): Not yet supported.
    return false;
  }
  ASSERT(comp->instr() != NULL);
  ASSERT(comp->InputCount() == 1);
  Computation* unary_op = NULL;
  if (HasOneSmi(*comp->ic_data())) {
    unary_op = new UnarySmiOpComp(op_kind, comp, comp->InputAt(0));
  } else if (HasOneDouble(*comp->ic_data()) && (op_kind == Token::kNEGATE)) {
    unary_op = new NumberNegateComp(comp, comp->InputAt(0));
  }
  if (unary_op != NULL) {
    unary_op->set_ic_data(comp->ic_data());
    comp->ReplaceWith(unary_op);
    return true;
  }
  return false;
}


// Returns true if all targets are the same.
// TODO(srdjan): if targets are native use their C_function to compare.
static bool HasOneTarget(const ICData& ic_data) {
  ASSERT(ic_data.NumberOfChecks() > 0);
  const Function& first_target = Function::Handle(ic_data.GetTargetAt(0));
  Function& test_target = Function::Handle();
  for (intptr_t i = 1; i < ic_data.NumberOfChecks(); i++) {
    test_target = ic_data.GetTargetAt(i);
    if (first_target.raw() != test_target.raw()) {
      return false;
    }
  }
  return true;
}


// Using field class
static RawField* GetField(intptr_t class_id, const String& field_name) {
  Class& cls = Class::Handle(Isolate::Current()->class_table()->At(class_id));
  Field& field = Field::Handle();
  while (!cls.IsNull()) {
    field = cls.LookupInstanceField(field_name);
    if (!field.IsNull()) {
      return field.raw();
    }
    cls = cls.SuperClass();
  }
  return Field::null();
}


// Returns ICData with num_args_checked == 1. If necessary creates a new ICData
// object that contains unique receiver class-ids
static RawICData* ToUnaryClassChecks(const ICData& ic_data) {
  ASSERT(!ic_data.IsNull());
  ASSERT(ic_data.num_args_tested() != 0);
  if (ic_data.num_args_tested() == 1) return ic_data.raw();
  const intptr_t kNumArgsTested = 1;
  ICData& result = ICData::Handle(ICData::New(
      Function::Handle(ic_data.function()),
      String::Handle(ic_data.target_name()),
      ic_data.id(),
      kNumArgsTested));
  for (intptr_t i = 0; i < ic_data.NumberOfChecks(); i++) {
    const intptr_t class_id = ic_data.GetReceiverClassIdAt(i);
    intptr_t duplicate_class_id = -1;
    for (intptr_t k = 0; k < result.NumberOfChecks(); k++) {
      if (class_id == result.GetReceiverClassIdAt(k)) {
        duplicate_class_id = k;
        break;
      }
    }
    if (duplicate_class_id >= 0) {
      ASSERT(result.GetTargetAt(duplicate_class_id) == ic_data.GetTargetAt(i));
    } else {
      // This will make sure that Smi is first if it exists.
      result.AddReceiverCheck(class_id,
                              Function::Handle(ic_data.GetTargetAt(i)));
    }
  }
  return result.raw();
}


// Only unique implicit instance getters can be currently handled.
bool FlowGraphOptimizer::TryInlineInstanceGetter(InstanceCallComp* comp) {
  ASSERT(comp->HasICData());
  const ICData& ic_data = *comp->ic_data();
  if (ic_data.NumberOfChecks() == 0) {
    // No type feedback collected.
    return false;
  }
  Function& target = Function::Handle();
  GrowableArray<intptr_t> class_ids;
  ic_data.GetCheckAt(0, &class_ids, &target);
  ASSERT(class_ids.length() == 1);

  if (target.kind() == RawFunction::kImplicitGetter) {
    if (!HasOneTarget(ic_data)) {
      // TODO(srdjan): Implement for mutiple targets.
      return false;
    }
    // Inline implicit instance getter.
    const String& field_name =
        String::Handle(Field::NameFromGetter(comp->function_name()));
    const Field& field = Field::Handle(GetField(class_ids[0], field_name));
    ASSERT(!field.IsNull());
    LoadInstanceFieldComp* load = new LoadInstanceFieldComp(
        field, comp->InputAt(0), comp);
    load->set_ic_data(comp->ic_data());
    comp->ReplaceWith(load);
    return true;
  }

  // Not an implicit getter.
  MethodRecognizer::Kind recognized_kind =
      MethodRecognizer::RecognizeKind(target);

  // VM objects length getter.
  if ((recognized_kind == MethodRecognizer::kObjectArrayLength) ||
      (recognized_kind == MethodRecognizer::kImmutableArrayLength) ||
      (recognized_kind == MethodRecognizer::kGrowableArrayLength)) {
    if (!HasOneTarget(ic_data)) {
      // TODO(srdjan): Implement for mutiple targets.
      return false;
    }
    intptr_t length_offset = -1;
    switch (recognized_kind) {
      case MethodRecognizer::kObjectArrayLength:
      case MethodRecognizer::kImmutableArrayLength:
        length_offset = Array::length_offset();
        break;
      case MethodRecognizer::kGrowableArrayLength:
        length_offset = GrowableObjectArray::length_offset();
        break;
      default:
        UNREACHABLE();
    }
    LoadVMFieldComp* load = new LoadVMFieldComp(
        comp->InputAt(0),
        length_offset,
        Type::ZoneHandle(Type::IntInterface()));
    load->set_original(comp);
    load->set_ic_data(comp->ic_data());
    comp->ReplaceWith(load);
    return true;
  }

  if (recognized_kind == MethodRecognizer::kStringBaseLength) {
    ASSERT(HasOneTarget(ic_data));
    LoadVMFieldComp* load = new LoadVMFieldComp(
        comp->InputAt(0),
        String::length_offset(),
        Type::ZoneHandle(Type::IntInterface()));
    load->set_original(comp);
    load->set_ic_data(comp->ic_data());
    comp->ReplaceWith(load);
    return true;
  }
  return false;
}


// Inline only simple, frequently called core library methods.
bool FlowGraphOptimizer::TryInlineInstanceMethod(InstanceCallComp* comp) {
  ASSERT(comp->HasICData());
  const ICData& ic_data = *comp->ic_data();
  if ((ic_data.NumberOfChecks() == 0) || !HasOneTarget(ic_data)) {
    // No type feedback collected.
    return false;
  }
  Function& target = Function::Handle();
  GrowableArray<intptr_t> class_ids;
  ic_data.GetCheckAt(0, &class_ids, &target);
  MethodRecognizer::Kind recognized_kind =
      MethodRecognizer::RecognizeKind(target);

  ObjectKind from_kind;
  if (recognized_kind == MethodRecognizer::kDoubleToDouble) {
    from_kind = kDouble;
  } else if (recognized_kind == MethodRecognizer::kIntegerToDouble) {
    from_kind = kSmi;
  } else {
    return false;
  }

  if (class_ids[0] != from_kind) {
    return false;
  }
  ToDoubleComp* coerce = new ToDoubleComp(
      comp->InputAt(0), from_kind, comp);
  coerce->set_instr(comp->instr());
  comp->instr()->replace_computation(coerce);
  return true;
}




void FlowGraphOptimizer::VisitInstanceCall(InstanceCallComp* comp) {
  if (comp->HasICData() && (comp->ic_data()->NumberOfChecks() > 0)) {
    const Token::Kind op_kind = comp->token_kind();
    if (Token::IsBinaryToken(op_kind) &&
        TryReplaceWithBinaryOp(comp, op_kind)) {
      return;
    }
    if (Token::IsUnaryToken(op_kind) && TryReplaceWithUnaryOp(comp, op_kind)) {
      return;
    }
    if ((op_kind == Token::kGET) && TryInlineInstanceGetter(comp)) {
      return;
    }
    if (TryInlineInstanceMethod(comp)) {
      return;
    }
    const intptr_t kMaxChecks = 4;
    if (comp->ic_data()->num_args_tested() <= kMaxChecks) {
      PolymorphicInstanceCallComp* call = new PolymorphicInstanceCallComp(comp);
      ICData& unary_checks =
          ICData::Handle(ToUnaryClassChecks(*comp->ic_data()));
      call->set_ic_data(&unary_checks);
      comp->ReplaceWith(call);
    }
  }
}


void FlowGraphOptimizer::VisitStaticCall(StaticCallComp* comp) {
  MethodRecognizer::Kind recognized_kind =
      MethodRecognizer::RecognizeKind(comp->function());
  if (recognized_kind == MethodRecognizer::kMathSqrt) {
    comp->set_recognized(MethodRecognizer::kMathSqrt);
  }
}


bool FlowGraphOptimizer::TryInlineInstanceSetter(InstanceSetterComp* comp) {
  ASSERT(comp->HasICData());
  const ICData& ic_data = *comp->ic_data();
  if (ic_data.NumberOfChecks() == 0) {
    // No type feedback collected.
    return false;
  }
  if (!HasOneTarget(ic_data)) {
    // TODO(srdjan): Implement when not all targets are the sa,e.
    return false;
  }
  Function& target = Function::Handle();
  intptr_t class_id;
  ic_data.GetOneClassCheckAt(0, &class_id, &target);
  if (target.kind() != RawFunction::kImplicitSetter) {
    // Not an implicit setter.
    // TODO(srdjan): Inline special setters.
    return false;
  }
  // Inline implicit instance setter.
  const Field& field = Field::Handle(GetField(class_id, comp->field_name()));
  ASSERT(!field.IsNull());
  StoreInstanceFieldComp* store = new StoreInstanceFieldComp(
      field,
      comp->InputAt(0),
      comp->InputAt(1),
      comp);
  store->set_ic_data(comp->ic_data());
  comp->ReplaceWith(store);
  return true;
}



void FlowGraphOptimizer::VisitInstanceSetter(InstanceSetterComp* comp) {
  // TODO(srdjan): Add assigneable check node if --enable_type_checks.
  if (comp->HasICData() && !FLAG_enable_type_checks) {
    TryInlineInstanceSetter(comp);
  }
}


enum IndexedAccessType {
  kIndexedLoad,
  kIndexedStore
};


static intptr_t ReceiverClassId(Computation* comp) {
  if (!comp->HasICData()) return kIllegalObjectKind;

  const ICData& ic_data = *comp->ic_data();

  if (ic_data.NumberOfChecks() == 0) return kIllegalObjectKind;
  // TODO(vegorov): Add multiple receiver type support.
  if (ic_data.NumberOfChecks() != 1) return kIllegalObjectKind;
  ASSERT(HasOneTarget(ic_data));

  Function& target = Function::Handle();
  intptr_t class_id;
  ic_data.GetOneClassCheckAt(0, &class_id, &target);
  return class_id;
}


void FlowGraphOptimizer::VisitLoadIndexed(LoadIndexedComp* comp) {
  const intptr_t class_id = ReceiverClassId(comp);
  switch (class_id) {
    case kArray:
    case kImmutableArray:
    case kGrowableObjectArray:
      comp->set_receiver_type(static_cast<ObjectKind>(class_id));
  }
}


void FlowGraphOptimizer::VisitStoreIndexed(StoreIndexedComp* comp) {
  if (FLAG_enable_type_checks) return;

  const intptr_t class_id = ReceiverClassId(comp);
  switch (class_id) {
    case kArray:
    case kGrowableObjectArray:
      comp->set_receiver_type(static_cast<ObjectKind>(class_id));
  }
}


static void TryFuseComparisonWithBranch(ComparisonComp* comp) {
  Instruction* instr = comp->instr();
  Instruction* next_instr = instr->StraightLineSuccessor();
  if (next_instr != NULL && next_instr->IsBranch()) {
    BranchInstr* branch = next_instr->AsBranch();
    UseVal* use = branch->value()->AsUse();
    if (instr == use->definition()) {
      comp->MarkFusedWithBranch(branch);
      branch->MarkFusedWithComparison();
    }
  }
}


void FlowGraphOptimizer::VisitRelationalOp(RelationalOpComp* comp) {
  if (!comp->HasICData()) return;

  const ICData& ic_data = *comp->ic_data();
  if (ic_data.NumberOfChecks() == 0) return;
  // TODO(srdjan): Add multiple receiver type support.
  if (ic_data.NumberOfChecks() != 1) return;
  ASSERT(HasOneTarget(ic_data));

  if (HasTwoSmi(ic_data)) {
    comp->set_operands_class_id(kSmi);
  } else if (HasTwoDouble(ic_data)) {
    comp->set_operands_class_id(kDouble);
  } else {
    return;
  }

  // For smi and double comparisons if the next instruction is a conditional
  // branch that uses the value of this comparison mark them as fused together
  // to avoid materializing a boolean value.
  // TODO(vegorov): recognize the pattern with BooleanNegate between comparsion
  // and a branch.
  TryFuseComparisonWithBranch(comp);
}


void FlowGraphOptimizer::VisitStrictCompareComp(StrictCompareComp* comp) {
  // TODO(vegorov): recognize the pattern with BooleanNegate between comparsion
  // and a branch.
  TryFuseComparisonWithBranch(comp);
}


void FlowGraphOptimizer::VisitEqualityCompare(EqualityCompareComp* comp) {
  const intptr_t kMaxChecks = 4;
  if (comp->HasICData() && (comp->ic_data()->num_args_tested() <= kMaxChecks)) {
    // Replace binary checks with unary ones.
    ICData& unary_checks =
        ICData::Handle(ToUnaryClassChecks(*comp->ic_data()));
    comp->set_ic_data(&unary_checks);
  }

  // TODO(vegorov): recognize the pattern with BooleanNegate between comparsion
  // and a branch.
  TryFuseComparisonWithBranch(comp);
}


void FlowGraphOptimizer::VisitDo(DoInstr* instr) {
  instr->computation()->Accept(this);
}


void FlowGraphOptimizer::VisitBind(BindInstr* instr) {
  instr->computation()->Accept(this);
}


}  // namespace dart
