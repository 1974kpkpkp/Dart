// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

final x = true;
final g1 = !true;
final g2 = !g1;

main() {
  Expect.equals(false, g1);
  Expect.equals(true, g2);
}
