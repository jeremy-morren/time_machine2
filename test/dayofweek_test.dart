// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';

/// Tests for [DayOfWeek], the equivalent of Noda Time's IsoDayOfWeek enum.
void main() {
  test('Values', Values);
  test('Equality', Equality);
  test('Comparison', Comparison);
  test('Arithmetic', Arithmetic);
  test('ToString', ToString);
  test('Parse', Parse);
}

const List<DayOfWeek> _days = [
  DayOfWeek.none,
  DayOfWeek.monday,
  DayOfWeek.tuesday,
  DayOfWeek.wednesday,
  DayOfWeek.thursday,
  DayOfWeek.friday,
  DayOfWeek.saturday,
  DayOfWeek.sunday,
];

void Values() {
  // ISO-8601 numbering: Monday is 1, Sunday is 7.
  for (int i = 0; i < _days.length; i++) {
    expect(_days[i].value, i);
  }
}

void Equality() {
  expect(DayOfWeek.monday, const DayOfWeek(1));
  expect(DayOfWeek.monday == DayOfWeek.tuesday, isFalse);
  expect(DayOfWeek.monday.hashCode, const DayOfWeek(1).hashCode);
  // A DayOfWeek is also equal to its numeric value.
  // ignore: unrelated_type_equality_checks
  expect(DayOfWeek.sunday == 7, isTrue);
  // ignore: unrelated_type_equality_checks
  expect(DayOfWeek.sunday == 6, isFalse);
}

void Comparison() {
  expect(DayOfWeek.monday < DayOfWeek.tuesday, isTrue);
  expect(DayOfWeek.tuesday < DayOfWeek.monday, isFalse);
  expect(DayOfWeek.monday < DayOfWeek.monday, isFalse);
  expect(DayOfWeek.monday <= DayOfWeek.monday, isTrue);
  expect(DayOfWeek.tuesday <= DayOfWeek.monday, isFalse);
  expect(DayOfWeek.sunday > DayOfWeek.saturday, isTrue);
  expect(DayOfWeek.saturday > DayOfWeek.sunday, isFalse);
  expect(DayOfWeek.sunday >= DayOfWeek.sunday, isTrue);
  expect(DayOfWeek.saturday >= DayOfWeek.sunday, isFalse);
}

void Arithmetic() {
  expect(DayOfWeek.friday - DayOfWeek.monday, 4);
  expect(DayOfWeek.monday - DayOfWeek.friday, -4);
  expect(DayOfWeek.tuesday + DayOfWeek.wednesday, 5);
}

void ToString() {
  expect(DayOfWeek.none.toString(), 'None');
  expect(DayOfWeek.monday.toString(), 'Monday');
  expect(DayOfWeek.wednesday.toString(), 'Wednesday');
  expect(DayOfWeek.sunday.toString(), 'Sunday');
}

void Parse() {
  for (var day in _days) {
    expect(DayOfWeek.parse(day.toString()), day);
  }
  // Case-insensitive, ignoring surrounding whitespace.
  expect(DayOfWeek.parse('  FRIDAY '), DayOfWeek.friday);
  expect(DayOfWeek.parse('saturday'), DayOfWeek.saturday);
  expect(DayOfWeek.parse('Funday'), isNull);
  expect(DayOfWeek.parse(''), isNull);
}
