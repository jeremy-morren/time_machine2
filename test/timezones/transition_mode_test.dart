// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';

/// Tests for [TransitionMode], the equivalent of Noda Time's enum.
void main() {
  test('Values', Values);
  test('FromValue', FromValue);
  test('FromValue_Invalid', FromValue_Invalid);
  test('Equality', Equality);
  test('Comparison', Comparison);
  test('Arithmetic', Arithmetic);
  test('ToString', ToString);
  test('Parse', Parse);
}

const List<TransitionMode> _modes = [
  TransitionMode.utc,
  TransitionMode.wall,
  TransitionMode.standard,
];

void Values() {
  expect(TransitionMode.utc.value, 0);
  expect(TransitionMode.wall.value, 1);
  expect(TransitionMode.standard.value, 2);
}

void FromValue() {
  for (var mode in _modes) {
    expect(identical(TransitionMode.fromValue(mode.value), mode), isTrue);
  }
}

void FromValue_Invalid() {
  expect(() => TransitionMode.fromValue(3), throwsArgumentError);
  expect(() => TransitionMode.fromValue(-1), throwsArgumentError);
}

void Equality() {
  expect(TransitionMode.wall, const TransitionMode(1));
  expect(TransitionMode.wall == TransitionMode.utc, isFalse);
  expect(TransitionMode.wall.hashCode, const TransitionMode(1).hashCode);
}

void Comparison() {
  expect(TransitionMode.utc < TransitionMode.wall, isTrue);
  expect(TransitionMode.wall < TransitionMode.utc, isFalse);
  expect(TransitionMode.wall <= TransitionMode.wall, isTrue);
  expect(TransitionMode.standard <= TransitionMode.wall, isFalse);
  expect(TransitionMode.standard > TransitionMode.wall, isTrue);
  expect(TransitionMode.utc > TransitionMode.wall, isFalse);
  expect(TransitionMode.utc >= TransitionMode.utc, isTrue);
  expect(TransitionMode.utc >= TransitionMode.wall, isFalse);
}

void Arithmetic() {
  expect(TransitionMode.standard - TransitionMode.wall, 1);
  expect(TransitionMode.standard + TransitionMode.wall, 3);
}

void ToString() {
  expect(TransitionMode.utc.toString(), 'Utc');
  expect(TransitionMode.wall.toString(), 'Wall');
  expect(TransitionMode.standard.toString(), 'Standard');
  expect(const TransitionMode(5).toString(), 'undefined:5');
}

void Parse() {
  for (var mode in _modes) {
    expect(TransitionMode.utc.parse(mode.toString()), mode);
  }
  // Case-insensitive, ignoring surrounding whitespace.
  expect(TransitionMode.utc.parse(' STANDARD '), TransitionMode.standard);
  expect(TransitionMode.utc.parse('local'), isNull);
}
