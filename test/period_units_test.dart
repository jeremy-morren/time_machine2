// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';

/// Tests for [PeriodUnits], the equivalent of Noda Time's [Flags] enum.
void main() {
  test('Values', Values);
  test('CompoundValues', CompoundValues);
  test('Equality', Equality);
  test('Comparison', Comparison);
  test('Arithmetic', Arithmetic);
  test('BitwiseOperators', BitwiseOperators);
  test('Union', Union);
  test('ToString', ToString);
  test('Parse', Parse);
}

void Values() {
  // These match Noda Time's PeriodUnits values.
  expect(PeriodUnits.none.value, 0);
  expect(PeriodUnits.years.value, 1);
  expect(PeriodUnits.months.value, 2);
  expect(PeriodUnits.weeks.value, 4);
  expect(PeriodUnits.days.value, 8);
  expect(PeriodUnits.hours.value, 16);
  expect(PeriodUnits.minutes.value, 32);
  expect(PeriodUnits.seconds.value, 64);
  expect(PeriodUnits.milliseconds.value, 128);
  expect(PeriodUnits.microseconds.value, 256);
  expect(PeriodUnits.nanoseconds.value, 512);
  expect(PeriodUnits.values.length, 17);
}

void CompoundValues() {
  expect(
      PeriodUnits.allDateUnits,
      PeriodUnits.years |
          PeriodUnits.months |
          PeriodUnits.weeks |
          PeriodUnits.days);
  expect(PeriodUnits.yearMonthDay,
      PeriodUnits.years | PeriodUnits.months | PeriodUnits.days);
  expect(PeriodUnits.hourMinuteSecond,
      PeriodUnits.hours | PeriodUnits.minutes | PeriodUnits.seconds);
  expect(
      PeriodUnits.allTimeUnits,
      PeriodUnits.hours |
          PeriodUnits.minutes |
          PeriodUnits.seconds |
          PeriodUnits.milliseconds |
          PeriodUnits.microseconds |
          PeriodUnits.nanoseconds);
  expect(PeriodUnits.dateAndTime,
      PeriodUnits.yearMonthDay | PeriodUnits.allTimeUnits);
  expect(PeriodUnits.allUnits,
      PeriodUnits.allDateUnits | PeriodUnits.allTimeUnits);
}

void Equality() {
  expect(PeriodUnits.days, const PeriodUnits(8));
  expect(PeriodUnits.days == PeriodUnits.weeks, isFalse);
  expect(PeriodUnits.days.hashCode, const PeriodUnits(8).hashCode);
  // A PeriodUnits is also equal to its numeric value.
  // ignore: unrelated_type_equality_checks
  expect(PeriodUnits.days == 8, isTrue);
  // ignore: unrelated_type_equality_checks
  expect(PeriodUnits.days == 4, isFalse);
}

void Comparison() {
  expect(PeriodUnits.years < PeriodUnits.months, isTrue);
  expect(PeriodUnits.months < PeriodUnits.years, isFalse);
  expect(PeriodUnits.years <= PeriodUnits.years, isTrue);
  expect(PeriodUnits.months <= PeriodUnits.years, isFalse);
  expect(PeriodUnits.nanoseconds > PeriodUnits.hours, isTrue);
  expect(PeriodUnits.hours > PeriodUnits.nanoseconds, isFalse);
  expect(PeriodUnits.hours >= PeriodUnits.hours, isTrue);
  expect(PeriodUnits.hours >= PeriodUnits.nanoseconds, isFalse);
}

void Arithmetic() {
  expect(PeriodUnits.days - PeriodUnits.years, 7);
  expect(PeriodUnits.days + PeriodUnits.years, 9);
}

void BitwiseOperators() {
  expect((PeriodUnits.years | PeriodUnits.days).value, 9);
  expect(PeriodUnits.yearMonthDay & PeriodUnits.days, PeriodUnits.days);
  expect(PeriodUnits.yearMonthDay & PeriodUnits.weeks, PeriodUnits.none);
}

void Union() {
  expect(PeriodUnits.union(const []), PeriodUnits.none);
  expect(
      PeriodUnits.union(
          const [PeriodUnits.years, PeriodUnits.months, PeriodUnits.days]),
      PeriodUnits.yearMonthDay);
  expect(PeriodUnits.union(PeriodUnits.values), PeriodUnits.allUnits);
}

void ToString() {
  expect(PeriodUnits.none.toString(), 'None');
  expect(PeriodUnits.years.toString(), 'Years');
  expect(PeriodUnits.allDateUnits.toString(), 'AllDateUnits');
  expect(PeriodUnits.nanoseconds.toString(), 'Nanoseconds');
  expect(PeriodUnits.allUnits.toString(), 'AllUnits');
  // A combination with no name.
  expect((PeriodUnits.years | PeriodUnits.hours).toString(), 'undefined');
}

void Parse() {
  for (var units in PeriodUnits.values) {
    expect(PeriodUnits.none.parse(units.toString()), units);
  }
  // Case-insensitive, ignoring surrounding whitespace.
  expect(PeriodUnits.none.parse(' hourMinuteSecond '),
      PeriodUnits.hourMinuteSecond);
  expect(PeriodUnits.none.parse('DAYS'), PeriodUnits.days);
  expect(PeriodUnits.none.parse('Fortnights'), isNull);
}
