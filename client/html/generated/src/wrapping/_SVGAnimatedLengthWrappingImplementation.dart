// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.

class SVGAnimatedLengthWrappingImplementation extends DOMWrapperBase implements SVGAnimatedLength {
  SVGAnimatedLengthWrappingImplementation._wrap(ptr) : super._wrap(ptr) {}

  SVGLength get animVal() { return LevelDom.wrapSVGLength(_ptr.animVal); }

  SVGLength get baseVal() { return LevelDom.wrapSVGLength(_ptr.baseVal); }
}
