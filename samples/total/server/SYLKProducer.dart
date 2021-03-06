// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class SYLKProducer {
  const SYLKProducer();

  String listSamples() {
    return '''[
"empty",
"mortgage",
"insertTest",
"collatz",
]''';
  }

  String makeExample(String id) {
    switch (id) {
    case 'mortgage':
      return Strings.join(_makeMortgageExample(), '\n');

    case 'insertTest':
      return Strings.join(_makeInsertTest(), '\n');

    case 'collatz':
      return Strings.join(_makeCollatzTest(), '\n');

    default:
      return Strings.join(_makeEmpty(), '\n');
    }
  }

  List<String> _makeEmpty() {
    List<String> sylk = new List<String>();
    sylk.add('ID;P');
    return sylk;
  }

  List<String> _makeCollatzTest() {
    List<String> sylk = new List<String>();
    sylk.add('ID;P');
    sylk.add('B;X1;Y180');
    sylk.add("C;X1;Y1;K871");
    for (int row = 2; row < 180; row++) {
      // x even ==> x / 2
      // x odd ==> 3 * x + 1
      // Note that (x - 2*trunc(x/2)) is 0 when x is even and 1 when x is odd
      sylk.add("C;X1;Y${row};K=(R[-1]C-2*TRUNC(R[-1]C/2))*(3*R[-1]C+1)+(1-(R[-1]C-2*TRUNC(R[-1]C/2)))*(R[-1]C/2)");
    }
    return sylk;
  }

  List<String> _makeInsertTest() {
    List<String> sylk = new List<String>();

    sylk.add('ID;P');
    sylk.add('B;X6;Y3');

    sylk.add('C;Y1;X1;K"InsertTest"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y2;X1;K"Absolute"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y3;X1;K"Relative"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X2;K"Fixed"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X3;K"NS to NS"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X4;K"NS to S"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X5;K"S to NS"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X6;K"S to S"');
    sylk.add('F;SD;FD0C');

    sylk.add('C;Y2;X2;K1');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y3;X2;K2');
    sylk.add('F;P1;FD0C');

    sylk.add('C;Y2;X3;K=(R2C2+10)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y3;X3;K=(R[0]C[-1] + 10)');
    sylk.add('F;P1;FD0C');

    sylk.add('C;Y2;X4;K=(R2C5-1000)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y3;X4;K=(R[0]C[1] - 1000)');
    sylk.add('F;P1;FD0C');

    sylk.add('C;Y2;X5;K=(R2C3+1100)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y3;X5;K=(R[0]C[-2] + 1100)');
    sylk.add('F;P1;FD0C');

    sylk.add('C;Y2;X6;K=(R2C5+10000)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y3;X6;K=(R[0]C[-1] + 10000)');
    sylk.add('F;P1;FD0C');

    sylk.add('C;Y4;X1;K"Sums Relative"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y4;X2;K=SUM(R[-2]C[0]:R[-1]C[0])');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y4;X3;K=SUM(R[-2]C[0]:R[-1]C[0])');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y4;X4;K=SUM(R[-2]C[0]:R[-1]C[0])');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y4;X5;K=SUM(R[-2]C[0]:R[-1]C[0])');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y4;X6;K=SUM(R[-2]C[0]:R[-1]C[0])');
    sylk.add('F;P1;FD0C');

    sylk.add('C;Y5;X1;K"Sums Absolute"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y5;X2;K=SUM(B2:B3)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y5;X3;K=SUM(C2:C3)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y5;X4;K=SUM(D2:D3)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y5;X5;K=SUM(E2:E3)');
    sylk.add('F;P1;FD0C');
    sylk.add('C;Y5;X6;K=SUM(F2:F3)');
    sylk.add('F;P1;FD0C');

    return sylk;
  }

  List<String> _makeMortgageExample() {
    int years = 8;
    int payments = years * 12;
    List<String> sylk = new List<String>();
    sylk.add('ID;P');
    sylk.add('B;X4;Y${payments + 4}');
    sylk.add('C;Y1;X1;K"Loan Amount"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X2;K"Interest Rate"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X3;K"Years"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y1;X4;K"\$/Month"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y2;X1;K30000');
    sylk.add('F;P5;F\$2R');
    sylk.add('C;Y2;X2;K.05375');
    sylk.add('F;P8;F%3R');
    sylk.add('C;Y2;X3;K${years}');
    sylk.add('F;P2;FD0R');
    sylk.add('C;Y2;X4;K=ROUND((R2C1 * ((R2C2/12)/(1 - POWER((1 + (R2C2/12)), (-12 * R2C3))))), 2)');
    sylk.add('F;P5;F\$2R');
    sylk.add('C;Y3;X1;K"Payment #"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y3;X2;K"Balance"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y3;X3;K"Interest"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y3;X4;K"Principal"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y4;X1;K1');
    sylk.add('F;P2;FD0C');
    sylk.add('C;Y4;X2;K=R2C1');
    sylk.add('F;P5;F\$2R');
    sylk.add('C;Y4;X3;K=(RC[-1] * R2C2)/12');
    sylk.add('F;P5;F\$2R');
    sylk.add('C;Y4;X4;K=R2C4 - RC[-1]');
    sylk.add('F;P5;F\$2R');
    for (int j = 5; j < payments + 4; j++) {
      sylk.add('C;Y${j};X1;K=R[-1]C + 1');
      sylk.add('F;P2;FD0C');
      sylk.add('C;Y${j};X2;K=R[-1]C - R[-1]C[2]');
      sylk.add('F;P5;F\$2R');
      sylk.add('C;Y${j};X3;K=(RC[-1] * R2C2)/12');
      sylk.add('F;P5;F\$2R');
      sylk.add('C;Y${j};X4;K=R2C4 - RC[-1]');
      sylk.add('F;P5;F\$2R');
    }

    int p3 = payments + 3;
    int p4 = payments + 4;
    sylk.add('C;Y${p4};X1;K"Totals"');
    sylk.add('F;SD;FD0C');
    sylk.add('C;Y${p4};X2;K=C${p4} + D${p4}');
    sylk.add('F;P5;F\$2R');
    sylk.add('C;Y${p4};X3;K=SUM(C4:C${p3})');
    sylk.add('F;P5;F\$2R');
    sylk.add('C;Y${p4};X4;K=SUM(D4:D${p3})');
    sylk.add('F;P5;F\$2R');
    return sylk;
  }
}
