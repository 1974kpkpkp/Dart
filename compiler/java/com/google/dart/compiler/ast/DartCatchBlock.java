// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.ast;

/**
 * Represents a Dart 'catch' block.
 */
public class DartCatchBlock extends DartStatement {
  private DartParameter exception;
  private DartParameter stackTrace;
  private DartBlock block;

  public DartCatchBlock(DartBlock block,
                        DartParameter exception,
                        DartParameter stackTrace) {
    this.block = becomeParentOf(block);
    this.exception = becomeParentOf(exception);
    this.stackTrace = becomeParentOf(stackTrace);
  }

  public DartParameter getException() {
    return exception;
  }

  public DartParameter getStackTrace() {
    return stackTrace;
  }

  public DartBlock getBlock() {
    return block;
  }

  @Override
  public void visitChildren(ASTVisitor<?> visitor) {
    exception.accept(visitor);
    if (stackTrace != null) {
      stackTrace.accept(visitor);
    }
    block.accept(visitor);
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitCatchBlock(this);
  }
}
