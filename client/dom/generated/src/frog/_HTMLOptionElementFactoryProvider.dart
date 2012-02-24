// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class _HTMLOptionElementFactoryProvider {
  factory HTMLOptionElement([String data = null, String value = null,
                             bool defaultSelected = null, bool selected = null])
      native
'''
if (data == null) return new Option();
if (value == null) return new Option(data);
if (defaultSelected == null) return new Option(data, value);
if (selected == null) return new Option(data, value, defaultSelected);
return new Option(data, value, defaultSelected, selected);
''';
}
