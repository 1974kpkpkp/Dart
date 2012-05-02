// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library("sample_extension");

#import("dart-ext:sample_extension");

// The simplest way to call native code: top-level static methods.
int systemRand() native "SystemRand";
void systemSrand(int seed) native "SystemSrand";

class RandomArray {
  static SendPort _port;
  void randomArray(int seed, int length, void callback(List result)) {
    var args = new List(2);
    args[0] = seed;
    args[1] = length;
    _getPort().call(args).then((result) {
      if (result != null) {
        callback(result);
      } else {
        throw new Exception("Random array creation failed");
      }
    });
  }

  SendPort _getPort() {
    if (_port == null) {
      _port = _getServerPort();
    }
    return _port;
  }

  SendPort _getServerPort() native "RandomArray_ServicePort";
}
