// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';

void main() {
  test('IsUsed_NoMatch', IsUsed_NoMatch);
  test('IsUsed_SingleValueMatch', IsUsed_SingleValueMatch);
  test('IsFieldUsed_MultiValueMatch', IsFieldUsed_MultiValueMatch);
  test('AllAreUsed_NoMatch', AllAreUsed_NoMatch);
  test('AllAreUsed_PartialMatch', AllAreUsed_PartialMatch);
  test('AllAreUsed_CompleteMatch', AllAreUsed_CompleteMatch);
  test('AllAreUsed_CompleteMatchWithMore', AllAreUsed_CompleteMatchWithMore);
  test('ToString', PatternFields_ToString);
  test('Parse', PatternFields_Parse);
  test('Operators', PatternFields_Operators);
  test('Union', PatternFields_Union);
  test('CompoundValues', PatternFields_CompoundValues);
}

void IsUsed_NoMatch() {
  expect(
      (PatternFields.hours12 | PatternFields.minutes)
          .hasAny(PatternFields.hours24),
      isFalse);
}

void IsUsed_SingleValueMatch() {
  expect(PatternFields.hours24.hasAny(PatternFields.hours24), isTrue);
}

void IsFieldUsed_MultiValueMatch() {
  expect(
      (PatternFields.hours24 | PatternFields.minutes)
          .hasAny(PatternFields.hours24),
      isTrue);
}

void AllAreUsed_NoMatch() {
  expect(
      (PatternFields.hours12 | PatternFields.minutes)
          .hasAll(PatternFields.hours24 | PatternFields.seconds),
      isFalse);
}

void AllAreUsed_PartialMatch() {
  expect(
      (PatternFields.hours12 | PatternFields.minutes)
          .hasAll(PatternFields.hours12 | PatternFields.seconds),
      isFalse);
}

void AllAreUsed_CompleteMatch() {
  expect(
      (PatternFields.hours12 | PatternFields.minutes)
          .hasAll(PatternFields.hours12 | PatternFields.minutes),
      isTrue);
}

void AllAreUsed_CompleteMatchWithMore() {
  expect(
      (PatternFields.hours24 | PatternFields.minutes | PatternFields.hours12)
          .hasAll(PatternFields.hours24 | PatternFields.minutes),
      isTrue);
}

final Map<PatternFields, String> _names = {
  PatternFields.none: 'None',
  PatternFields.sign: 'Sign',
  PatternFields.hours12: 'Hours12',
  PatternFields.hours24: 'Hours24',
  PatternFields.minutes: 'Minutes',
  PatternFields.seconds: 'Seconds',
  PatternFields.fractionalSeconds: 'FractionalSeconds',
  PatternFields.amPm: 'AmPm',
  PatternFields.year: 'Year',
  PatternFields.yearTwoDigits: 'YearTwoDigits',
  PatternFields.yearOfEra: 'YearOfEra',
  PatternFields.monthOfYearNumeric: 'MonthOfYearNumeric',
  PatternFields.monthOfYearText: 'MonthOfYearText',
  PatternFields.dayOfMonth: 'DayOfMonth',
  PatternFields.dayOfWeek: 'DayOfWeek',
  PatternFields.era: 'Era',
  PatternFields.calendar: 'Calendar',
  PatternFields.zone: 'Zone',
  PatternFields.zoneAbbreviation: 'ZoneAbbreviation',
  PatternFields.embeddedOffset: 'EmbeddedOffset',
  PatternFields.totalTime: 'TotalTime',
  PatternFields.embeddedDate: 'EmbeddedDate',
  PatternFields.embeddedTime: 'EmbeddedTime',
  PatternFields.allTimeFields: 'AllTimeFields',
  PatternFields.allDateFields: 'AllDateFields',
};

void PatternFields_ToString() {
  _names.forEach((field, name) => expect(field.toString(), name));
  // A combination with no name.
  expect(
      (PatternFields.hours24 | PatternFields.minutes).toString(), 'undefined');
}

void PatternFields_Parse() {
  _names.forEach((field, name) {
    expect(PatternFields.none.parse(name), field, reason: name);
  });
  // Case-insensitive, ignoring surrounding whitespace.
  expect(PatternFields.none.parse(' hours24 '), PatternFields.hours24);
  expect(PatternFields.none.parse('FRACTIONALSECONDS'),
      PatternFields.fractionalSeconds);
  expect(PatternFields.none.parse('Weeks'), isNull);
}

void PatternFields_Operators() {
  expect(PatternFields.hours12 < PatternFields.hours24, isTrue);
  expect(PatternFields.hours24 < PatternFields.hours12, isFalse);
  expect(PatternFields.hours12 <= PatternFields.hours12, isTrue);
  expect(PatternFields.hours24 <= PatternFields.hours12, isFalse);
  expect(PatternFields.hours24 > PatternFields.hours12, isTrue);
  expect(PatternFields.hours12 > PatternFields.hours24, isFalse);
  expect(PatternFields.hours24 >= PatternFields.hours24, isTrue);
  expect(PatternFields.hours12 >= PatternFields.hours24, isFalse);
  expect(PatternFields.hours24 - PatternFields.hours12, 2);
  expect(PatternFields.hours24 + PatternFields.hours12, 6);
  expect(
      PatternFields.allTimeFields & ~PatternFields.amPm,
      PatternFields.union(const [
        PatternFields.hours12,
        PatternFields.hours24,
        PatternFields.minutes,
        PatternFields.seconds,
        PatternFields.fractionalSeconds,
        PatternFields.embeddedTime
      ]));
  // A PatternFields is also equal to its numeric value.
  // ignore: unrelated_type_equality_checks
  expect(PatternFields.hours24 == 4, isTrue);
  expect(PatternFields.hours24.hashCode, const PatternFields(4).hashCode);
}

void PatternFields_Union() {
  expect(PatternFields.union(const []), PatternFields.none);
  expect(PatternFields.union(const [PatternFields.sign, PatternFields.hours12]),
      const PatternFields(3));
}

void PatternFields_CompoundValues() {
  // As in Noda Time's PatternFields.
  expect(
      PatternFields.allTimeFields,
      PatternFields.union(const [
        PatternFields.hours12,
        PatternFields.hours24,
        PatternFields.minutes,
        PatternFields.seconds,
        PatternFields.fractionalSeconds,
        PatternFields.amPm,
        PatternFields.embeddedTime
      ]));
  expect(
      PatternFields.allDateFields,
      PatternFields.union(const [
        PatternFields.year,
        PatternFields.yearTwoDigits,
        PatternFields.yearOfEra,
        PatternFields.monthOfYearNumeric,
        PatternFields.monthOfYearText,
        PatternFields.dayOfMonth,
        PatternFields.dayOfWeek,
        PatternFields.era,
        PatternFields.calendar,
        PatternFields.embeddedDate
      ]));
}
