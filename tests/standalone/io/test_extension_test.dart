// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library("test_extension_test");

#import('test_extension.dart');

main() {
  Expect.equals('cat 13', new Cat(13).toString(), 'new Cat(13).toString()');

  Expect.equals(3, Cat.ifNull(null, 3), 'Cat.ifNull(null, 3)');
  Expect.equals(4, Cat.ifNull(4, null), 'Cat.ifNull(4, null)');
  Expect.equals(5, Cat.ifNull(5, 9), 'Cat.ifNull(5, 9)');
  Expect.isNull(Cat.ifNull(null, null), 'Cat.ifNull(null, null)');
}
