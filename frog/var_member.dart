// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/** A dynamic member stub. */
class VarMember {
  final String name;

  VarMember(this.name);

  abstract void generate(CodeWriter code);

  Type get returnType() => world.varType;

  Value invoke(MethodGenerator context, Node node, Value target, Arguments args) {
    return new Value(returnType,
      '${target.code}.$name(${args.getCode()})', node.span);
  }
}

/**
 * This function generates a dynamic call stub for functions. It's part of a
 * series of steps described below. Most of the code is generated by
 * gen.dart, with some helpers in core.js
 *
 * Given a call site in Dart like:
 *   f(1, 2, capture:true);
 *
 * We compile to JS like:
 *   f.call$2$capture(1, 2, true);
 *
 * And then generate this function:
 *   Function.prototype.call$2$capture = function($0, $1, capture) {
 *     this.call$2$capture = this.$genStub(3, ['capture']);
 *     return this.call$2$capture($0, $1, capture);
 *   }
 *
 * Or for a fixed-arity function, generate this:
 *   Function.prototype.call$2 = function($0, $1) {
 *     return this.to$call$2()($0, $1);
 *   }
 *   Function.prototype.to$call$2 = function() {
 *     this.call$2 = this.$genStub(2);
 *     this.to$call$2 = function() { return this.call$2; }
 *     return this.to$call$2();
 *   }
 * We use .to$call$2 to convert to a typed function.
 *
 * For each method that can be passed as a function, such as a "get" on the
 * method or is a lambda, generate optional argument info. Given a function
 * like:
 *   class SomeType {
 *     void add(x, y, [bubbles = true, capture = false]) { ... }
 *     ... }
 *
 * The generated argument info looks like:
 *  SomeType.prototype.add.$optional = ['bubbles','capture', 'true','false'];
 */
// TODO(jmesserly): we don't currently put $optional on lambdas.
// Also, maybe a string encoding would perform better?
// TODO(jmesserly): $genStub is a hole in the run-time type checker.
// It bypasses the checks we would do at the callsite for methods.
// Also, it won't work properly for native JS functions (those don't have
// an accurate .length)
class VarFunctionStub extends VarMember {
  final Arguments args;

  VarFunctionStub(String name, Arguments callArgs)
    : super(name), args = callArgs.toCallStubArgs() {
    world.gen.corejs.useGenStub = true;
  }

  void generate(CodeWriter code) {
    if (args.hasNames) {
      generateNamed(code);
    } else {
      generatePositional(code);
    }
  }

  void generatePositional(CodeWriter w) {
    // Positional arg functions can be converted from "var" to a fixed arity
    // function type. So emit a to$N stub as well as the call$N stub.
    int arity = args.length;
    w.enterBlock('Function.prototype.to\$$name = function() {');
    w.writeln('this.$name = this.\$genStub($arity);');
    w.writeln('this.to\$$name = function() { return this.$name; };');
    w.writeln('return this.$name;');
    w.exitBlock('};');
    var argsCode = args.getCode();
    w.enterBlock('Function.prototype.$name = function(${argsCode}) {');
    w.writeln('return this.to\$$name()($argsCode);');
    w.exitBlock('};');

    // TODO(jmesserly): HACK, we couldn't allocate temps from Value, so we
    // needed this stub to check for null.
    w.writeln('function to\$$name(f) { return f && f.to\$$name(); }');
  }

  void generateNamed(CodeWriter w) {
    // Named functions use simpler stubs, because we never convert to a named
    // stub type.
    var named = Strings.join(args.getNames(), '", "');
    var argsCode = args.getCode();
    w.enterBlock('Function.prototype.$name = function(${argsCode}) {');
    w.writeln('this.$name = this.\$genStub(${args.length}, ["$named"]);');
    w.writeln('return this.$name($argsCode);');
    w.exitBlock('}');
  }
}

class VarMethodStub extends VarMember {
  final Member member;
  final Arguments args;
  final String body;

  VarMethodStub(String name, this.member, this.args, this.body): super(name);

  bool get isHidden() =>
      member != null ? member.declaringType.isHiddenNativeType : false;

  Type get returnType() =>
      member != null ? member.returnType : world.varType;

  Type get declaringType() =>
      member != null ? member.declaringType : world.objectType;

  void generate(CodeWriter code) {
    code.write(world.gen._prototypeOf(declaringType, name) + ' = ');
    if (!isHidden && _useDirectCall(args)) {
      code.writeln(world.gen._prototypeOf(declaringType, member.jsname) + ';');
    } else if (_needsExactTypeCheck()) {
      code.enterBlock('function(${args.getCode()}) {');
      code.enterBlock(
        'if (Object.getPrototypeOf(this).hasOwnProperty("$name")) {');
      code.writeln('$body;');
      code.exitBlock('}');
      String argsCode = args.getCode();
      if (argsCode != '') argsCode = ', ' + argsCode;
      code.writeln('return Object.prototype.$name.call(this$argsCode);');
      code.exitBlock('};');
    } else {
      code.enterBlock('function(${args.getCode()}) {');
      code.writeln('$body;');
      code.exitBlock('};');
    }
  }

  /**
   * If we have a native method overridden by a hidden native method, we need to
   * make sure the base one has an exact type test. Otherwise we don't need
   * this.
   */
  bool _needsExactTypeCheck() {
    if (member == null || member.declaringType.isObject) return false;

    var members = member.declaringType.resolveMember(member.name).members;
    return members.filter((m) => m != member
        && m.declaringType.isHiddenNativeType).length >= 1;
  }

  bool _useDirectCall(Arguments args) {
    // Create direct stubs when we can. We don't do this in some cases, such as
    // types that have native subtypes (like Object), otherwise things like
    // Object.prototype.toString$0 end up calling the toString on Object instead
    // of on the derived type.
    if (member is MethodMember && !member.declaringType.hasNativeSubtypes) {
      MethodMember method = member;
      if (method.needsArgumentConversion(args)) {
        return false;
      }

      // If we have the right number of parameters, or all defaults would be
      // filled in as "undefined" anyway, we can just call the method directly.
      for (int i = args.length; i < method.parameters.length; i++) {
        if (method.parameters[i].value.code != 'null') {
          return false;
        }
      }
      return method.namesInOrder(args);
    } else {
      return false;
    }
  }
}

/**
 * A special member with a mangled name that represents a dynamic call
 * (i.e. a call with multiple valid targets). We generate this if we have
 * a dynamic call that needs different implementation methods for different
 * members.
 */
class VarMethodSet extends VarMember {
  final String baseName;
  final List<Member> members;
  final Type returnType;
  final Arguments args;

  bool invoked = false;

  VarMethodSet(this.baseName, String name, this.members, Arguments callArgs,
               this.returnType)
    : super(name), args = callArgs.toCallStubArgs() {
  }

  Value invoke(MethodGenerator context, Node node, Value target,
      Arguments args) {
    _invokeMembers(context, node);
    return super.invoke(context, node, target, args);
  }

  /** Invokes members to ensure they're generated. */
  _invokeMembers(MethodGenerator context, Node node) {
    if (invoked) return;
    invoked = true;

    bool hasObjectType = false;
    for (var member in members) {
      // Invoke the member with the stub args (this gives us the method body),
      // then create the stub method.
      final type = member.declaringType;
      final target = new Value(type, 'this', node.span);
      var result = member.invoke(context, node, target, args, isDynamic:true);
      var stub = new VarMethodStub(name, member, args, 'return ' + result.code);
      type.varStubs[stub.name] = stub;

      if (type.isObject) hasObjectType = true;
    }

    // Create a noSuchMethod fallback on Object if needed.
    // Some methods, like toString and == already have a fallback on Object.
    if (!hasObjectType) {
      final target = new Value(world.objectType, 'this', node.span);
      var result = target.invokeNoSuchMethod(context, baseName, node, args);
      var stub = new VarMethodStub(name, null, args, 'return ' + result.code);
      world.objectType.varStubs[stub.name] = stub;
    }
  }

  // TODO(jmesserly): get rid of this as it's unused now
  void generate(CodeWriter code) {}
}

String _getCallStubName(String name, Arguments args) {
  final nameBuilder = new StringBuffer('${name}\$${args.bareCount}');
  for (int i = args.bareCount; i < args.length; i++) {
    nameBuilder.add('\$').add(args.getName(i));
  }
  return nameBuilder.toString();
}
