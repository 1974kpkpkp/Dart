// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.ast;

import com.google.dart.compiler.common.HasSymbol;
import com.google.dart.compiler.common.Symbol;
import com.google.dart.compiler.resolver.ConstructorElement;

import java.util.List;

/**
 * Redirected constructor invocation AST node.
 */
public class DartRedirectConstructorInvocation extends DartInvocation implements HasSymbol {

  private DartIdentifier name;
  private ConstructorElement symbol;

  public DartRedirectConstructorInvocation(DartIdentifier name, List<DartExpression> args) {
    super(args);
    this.name = becomeParentOf(name);
  }

  public DartIdentifier getName() {
    return name;
  }

  @Override
  public void setSymbol(Symbol symbol) {
    this.symbol = (ConstructorElement) symbol;
  }

  @Override
  public ConstructorElement getSymbol() {
    return symbol;
  }

  @Override
  public void visitChildren(ASTVisitor<?> visitor) {
    if (name != null) {
      name.accept(visitor);
    }
    visitor.visit(getArguments());
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitRedirectConstructorInvocation(this);
  }
}
