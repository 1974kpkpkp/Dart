// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.resolver;

import com.google.dart.compiler.ast.DartIdentifier;
import com.google.dart.compiler.ast.DartMethodDefinition;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartParameterizedTypeNode;
import com.google.dart.compiler.ast.DartPropertyAccess;

class ConstructorElementImplementation extends MethodElementImplementation
    implements ConstructorNodeElement {
  private final ClassElement constructorType;
  private final String rawName;
  private ConstructorElement defaultConstructor;

  private ConstructorElementImplementation(DartMethodDefinition node,
                             String name,
                             ClassElement declaringClass,
                             ClassElement constructorType) {
    super(node, name, declaringClass);
    this.constructorType = constructorType;
    this.rawName = getRawName(node.getName());
  }

  private static String getRawName(DartNode name) {
    if (name instanceof DartIdentifier) {
      return ((DartIdentifier) name).getName();
    } else if (name instanceof DartParameterizedTypeNode) {
      return getRawName(((DartParameterizedTypeNode) name).getExpression());
    } else {
      DartPropertyAccess propertyAccess = (DartPropertyAccess) name;
      return getRawName(propertyAccess.getQualifier()) + "." + getRawName(propertyAccess.getName());
    }
  }

  public ClassElement getConstructorType() {
    return constructorType;
  }
  
  @Override
  public String getRawName() {
    return rawName;
  }

  @Override
  public ElementKind getKind() {
    return ElementKind.CONSTRUCTOR;
  }

  @Override
  public boolean isConstructor() {
    return true;
  }
  
  @Override
  public boolean isSynthetic() {
    return false;
  }

  @Override
  public ConstructorElement getDefaultConstructor() {
    return defaultConstructor;
  }

  @Override
  public void setDefaultConstructor(ConstructorElement defaultConstructor) {
    this.defaultConstructor = defaultConstructor;
  }

  public static ConstructorElementImplementation fromMethodNode(DartMethodDefinition node,
                                                  String name,
                                                  ClassElement declaringClass,
                                                  ClassElement constructorType) {
    return new ConstructorElementImplementation(node, name, declaringClass, constructorType);
  }
}
