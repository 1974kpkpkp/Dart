// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.

interface FileReaderSync default _FileReaderSyncFactoryProvider {

  FileReaderSync();

  ArrayBuffer readAsArrayBuffer(Blob blob);

  String readAsBinaryString(Blob blob);

  String readAsDataURL(Blob blob);

  String readAsText(Blob blob, [String encoding]);
}
