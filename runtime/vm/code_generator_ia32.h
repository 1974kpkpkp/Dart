// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_CODE_GENERATOR_IA32_H_
#define VM_CODE_GENERATOR_IA32_H_

#ifndef VM_CODE_GENERATOR_H_
#error Do not include code_generator_ia32.h directly; use code_generator.h.
#endif

#include "vm/assembler.h"
#include "vm/ast.h"
#include "vm/growable_array.h"
#include "vm/parser.h"

namespace dart {

// Forward declarations.
class Assembler;
class AstNode;
class CodeGenerator;
class DescriptorList;
class ExceptionHandlerList;
class SourceLabel;
class StackmapBuilder;


class CodeGeneratorState : public StackResource {
 public:
  explicit CodeGeneratorState(CodeGenerator* codegen);
  virtual ~CodeGeneratorState();

  CodeGeneratorState* parent() const { return parent_; }

  AstNode* root_node() const { return root_node_; }
  void set_root_node(AstNode* value) { root_node_ = value; }
  bool IsRootNode(AstNode* node) const {
    return root_node_ == node;
  }

  int try_index() const { return current_try_index_; }
  void set_try_index(int value) {
    current_try_index_ = value;
  }

 private:
  CodeGenerator* codegen_;
  CodeGeneratorState* parent_;
  AstNode* root_node_;

  // We identify each try block in this function with an unique 'try index'
  // value.
  // The 'try index' is used to match the try blocks with the corresponding
  // catch block (if one exists). The PC descriptors generated for
  // statements in the try block use this index so that it can be matched
  // to the appropriate catch block.
  // The 'try index' value is generated by incrementing the try_index_
  // variable in the CodeGenerator object.
  // We store the 'try index' of the block of code that we are
  // currently generating code for in the current_try_index_ variable.
  int current_try_index_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(CodeGeneratorState);
};


class CodeGenerator : public AstNodeVisitor {
 public:
  CodeGenerator(Assembler* assembler, const ParsedFunction& parsed_function);
  virtual ~CodeGenerator() { }

  // Accessors.
  Assembler* assembler() const { return assembler_; }

  const ParsedFunction& parsed_function() const { return parsed_function_; }

  void GenerateCode();
  virtual void GenerateDeferredCode();

#define DEFINE_VISITOR_FUNCTION(type, name)                                    \
  virtual void Visit##type(type* node);
NODE_LIST(DEFINE_VISITOR_FUNCTION)
#undef DEFINE_VISITOR_FUNCTION

  CodeGeneratorState* state() const { return state_; }
  void set_state(CodeGeneratorState* state) { state_ = state; }

  // Add exception handler table to code.
  void FinalizeExceptionHandlers(const Code& code);

  // Add pc descriptors to code.
  void FinalizePcDescriptors(const Code& code);

  // Add stack maps to code.
  void FinalizeStackmaps(const Code& code);

  // Add local variable descriptors to code.
  void FinalizeVarDescriptors(const Code& code);

  // Allocate and return an arguments descriptor.
  // Let 'num_names' be the length of 'optional_arguments_names'.
  // Treat the first 'num_arguments - num_names' arguments as positional and
  // treat the following 'num_names' arguments as named optional arguments.
  static const Array& ArgumentsDescriptor(
      int num_arguments,
      const Array& optional_arguments_names);

  virtual bool IsOptimizing() const {
    return false;
  }

  void GenerateReturnEpilog(ReturnNode* node);

  // Return true if the VM may optimize functions.
  static bool CanOptimize();

 private:
  // TODO(srdjan): Remove the friendship once the two compilers are properly
  // structured.
  friend class OptimizingCodeGenerator;

  // Return true if intrinsification succeeded and no more code is needed.
  // Returns false if either no intrinsification occured or if intrinsified
  // code needs the rest for slow case execution.
  bool TryIntrinsify();

  void IntrinsifyGetter();
  void IntrinsifySetter();

  virtual void GeneratePreEntryCode();
  void GenerateLegacyEntryCode();
  void GenerateEntryCode();
  void GenerateLoadVariable(Register dst, const LocalVariable& local);
  void GeneratePushVariable(const LocalVariable& variable, Register scratch);
  void GenerateStoreVariable(const LocalVariable& local,
                             Register src,
                             Register scratch);
  void GenerateLogicalNotOp(UnaryOpNode* node);
  void GenerateLogicalAndOrOp(BinaryOpNode* node);
  void GenerateInstanceGetterCall(intptr_t node_id,
                                  intptr_t token_index,
                                  const String& field_name);
  void GenerateInstanceSetterCall(intptr_t node_id,
                                  intptr_t token_index,
                                  const String& field_name);
  void GenerateBinaryOperatorCall(intptr_t node_id,
                                  intptr_t token_index,
                                  const char* operator_name);
  void GenerateStaticGetterCall(intptr_t token_index,
                                const Class& field_class,
                                const String& field_name);
  void GenerateStaticSetterCall(intptr_t token_index,
                                const Class& field_class,
                                const String& field_name);
  void GenerateLoadIndexed(intptr_t node_id, intptr_t token_index);
  void GenerateStoreIndexed(intptr_t node_id,
                            intptr_t token_index,
                            bool preserve_value);

  // Invokes funtion via an inline cache stub. 'num_args_checked' specifies
  // the number of call arguments that are being checked in the inline cache.
  void GenerateInstanceCall(intptr_t node_id,
                            intptr_t token_index,
                            const String& function_name,
                            int num_arguments,
                            const Array& optional_arguments_names,
                            intptr_t num_args_checked);

  void GenerateInstanceOf(intptr_t node_id,
                          intptr_t token_index,
                          AstNode* value,
                          const AbstractType& type,
                          bool negate_result);
  void GenerateAssertAssignable(intptr_t node_id,
                                intptr_t token_index,
                                AstNode* value,
                                const AbstractType& dst_type,
                                const String& dst_name);
  void GenerateArgumentTypeChecks();
  void GenerateConditionTypeCheck(intptr_t node_id, intptr_t token_index);

  void GenerateInstantiatorTypeArguments(intptr_t token_index);
  void GenerateTypeArguments(ConstructorCallNode* node,
                             bool is_cls_parameterized);

  intptr_t locals_space_size() const { return locals_space_size_; }
  void set_locals_space_size(intptr_t value) { locals_space_size_ = value; }

  bool IsResultNeeded(AstNode* node) const;

  void GenerateCall(intptr_t token_index,
                    const ExternalLabel* ext_label,
                    PcDescriptors::Kind desc_kind);
  void GenerateCallRuntime(intptr_t node_id,
                           intptr_t token_index,
                           const RuntimeEntry& entry);

  void GenerateInlinedFinallyBlocks(SourceLabel* label);

  void GenerateInlineInstanceof(intptr_t node_id,
                                intptr_t token_index,
                                const AbstractType& type,
                                Label* is_instance_lbl,
                                Label* is_not_instance_lbl);

  void GenerateInstantiatedTypeWithArgumentsTest(intptr_t node_id,
                                                 intptr_t token_index,
                                                 const AbstractType& dst_type,
                                                 Label* is_instance_lbl,
                                                 Label* is_not_instance_lbl);
  void GenerateInstantiatedTypeNoArgumentsTest(intptr_t node_id,
                                               intptr_t token_index,
                                               const AbstractType& dst_type,
                                               Label* is_instance_lbl,
                                               Label* is_not_instance_lbl);
  void GenerateUninstantiatedTypeTest(const AbstractType& dst_type,
                                      intptr_t token_index,
                                      Label* is_instance_lbl);
  void GenerateClassTestCache(intptr_t node_id,
                              intptr_t token_index,
                              const Class& type_class,
                              Label* is_instance_lbl,
                              Label* is_not_instance_lbl);

  void HandleBackwardBranch(intptr_t loop_id, intptr_t token_index);

  void ErrorMsg(intptr_t token_index, const char* format, ...);

  int generate_next_try_index() { return try_index_ += 1; }

  void MarkDeoptPoint(intptr_t node_id, intptr_t token_index);
  void AddCurrentDescriptor(PcDescriptors::Kind kind,
                            intptr_t node_id,
                            intptr_t token_index);

  void set_context_level(intptr_t value) { context_level_ = value; }
  intptr_t context_level() const { return context_level_; }

  Assembler* assembler_;
  const ParsedFunction& parsed_function_;
  intptr_t locals_space_size_;
  CodeGeneratorState* state_;
  DescriptorList* pc_descriptors_list_;
  StackmapBuilder* stackmap_builder_;
  ExceptionHandlerList* exception_handlers_list_;
  int try_index_;
  // The runtime context level is only incremented when a new context is
  // allocated and chained to the list of contexts.
  intptr_t context_level_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(CodeGenerator);
};

}  // namespace dart

#endif  // VM_CODE_GENERATOR_IA32_H_
