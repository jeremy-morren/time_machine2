// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';

/// Tests for the integer helpers in utilities.dart.
void main() {
  test('ArithmeticMod', ArithmeticMod);
  test('EpochArithmeticMod', EpochArithmeticMod);
  test('BigArithmeticMod', BigArithmeticMod);
  test('EpochBigArithmeticMod', EpochBigArithmeticMod);
  test('SafeRightShift', SafeRightShift);
  test('SafeLeftShift', SafeLeftShift);
  test('Platform', PlatformChecks);
}

const List<int> _xs = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5];

void ArithmeticMod() {
  // The remainder has the sign of x, as for durations.
  expect(_xs.map((x) => arithmeticMod(x, 3)).toList(),
      [-2, -1, 0, -2, -1, 0, 1, 2, 0, 1, 2]);
}

void EpochArithmeticMod() {
  // The remainder is never negative, as for days since an epoch.
  expect(_xs.map((x) => epochArithmeticMod(x, 3)).toList(),
      [1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2]);
}

void BigArithmeticMod() {
  expect(
      _xs
          .map((x) => bigArithmeticMod(BigInt.from(x), BigInt.from(3)).toInt())
          .toList(),
      [-2, -1, 0, -2, -1, 0, 1, 2, 0, 1, 2]);
}

void EpochBigArithmeticMod() {
  expect(
      _xs
          .map((x) =>
              epochBigArithmeticMod(BigInt.from(x), BigInt.from(3)).toInt())
          .toList(),
      [1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2]);
}

// The shifts are arithmetic (sign-preserving) on every platform, so a right
// shift is a division rounding towards negative infinity, and a left shift a
// multiplication. (Values are kept within 32 bits, as JavaScript's shifts are.)
const List<int> _shiftValues = [
  -100000,
  -257,
  -5,
  -2,
  -1,
  0,
  1,
  2,
  5,
  257,
  100000
];

void SafeRightShift() {
  for (var x in _shiftValues) {
    for (var y in [0, 1, 3, 8]) {
      var expected = (x / (1 << y)).floor();
      expect(safeRightShift(x, y), expected, reason: '$x >> $y');
      if (x < 0) {
        expect(negRightShift(x, y), expected, reason: '$x >> $y');
      }
    }
  }
}

void SafeLeftShift() {
  for (var x in _shiftValues) {
    for (var y in [0, 1, 3, 8]) {
      var expected = x * (1 << y);
      expect(safeLeftShift(x, y), expected, reason: '$x << $y');
      if (x < 0) {
        expect(negLeftShift(x, y), expected, reason: '$x << $y');
      }
    }
  }
}

void PlatformChecks() {
  // Exactly one of these holds, and doubles print as on the platform.
  expect(Platform.isVM, isNot(Platform.isWeb));
  expect(Platform.isVM, 1.0.toString() == '1.0');
  expect(Platform.dirtyCheck(), isNull);
  expect(Platform.isVM, 1.0.toString() == '1.0');
  expect(Platform.intMaxValue,
      Platform.isVM ? Platform.int64MaxValue : Platform.intMaxValueJS);
  expect(Platform.intMinValue,
      Platform.isVM ? Platform.int64MinValue : Platform.intMinValueJS);
}
