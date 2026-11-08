// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';
import 'time_machine_testing.dart';

void main() {
  parameterizedTest('MaxDate', SupportedCalendars, MaxDate,
      customDescriptionBuilder: describeArguments);
  parameterizedTest('MinDate', SupportedCalendars, MinDate,
      customDescriptionBuilder: describeArguments);
  test('GetDaysInYear', GetDaysInYear);
  test('GetDaysInYear_Invalid', GetDaysInYear_Invalid);
  test('ValidateYearMonthDay', ValidateYearMonthDay);
  test('CalendarOrdinal_Operators', CalendarOrdinal_Operators);
  test('CalendarOrdinal_ToStringAndParse', CalendarOrdinal_ToStringAndParse);
}

void GetDaysInYear() {
  expect(CalendarSystem.iso.getDaysInYear(2000), 366);
  expect(CalendarSystem.iso.getDaysInYear(1900), 365);
  expect(CalendarSystem.iso.getDaysInYear(2001), 365);
  // 1900 is a leap year in the Julian calendar.
  expect(CalendarSystem.julian.getDaysInYear(1900), 366);
  // Coptic leap years are those where year % 4 == 3.
  expect(CalendarSystem.coptic.getDaysInYear(1736), 365);
  expect(CalendarSystem.coptic.getDaysInYear(1739), 366);
}

void GetDaysInYear_Invalid() {
  var iso = CalendarSystem.iso;
  expect(() => iso.getDaysInYear(iso.maxYear + 1), throwsRangeError);
  expect(() => iso.getDaysInYear(iso.minYear - 1), throwsRangeError);
}

void ValidateYearMonthDay() {
  var iso = CalendarSystem.iso;
  ICalendarSystem.validateYearMonthDay_(iso, const YearMonthDay(2000, 2, 29));
  expect(
      () => ICalendarSystem.validateYearMonthDay_(
          iso, const YearMonthDay(2001, 2, 29)),
      throwsRangeError);
}

void CalendarOrdinal_Operators() {
  expect(CalendarOrdinal.iso < CalendarOrdinal.julian, isTrue);
  expect(CalendarOrdinal.julian < CalendarOrdinal.iso, isFalse);
  expect(CalendarOrdinal.iso <= CalendarOrdinal.iso, isTrue);
  expect(CalendarOrdinal.julian <= CalendarOrdinal.iso, isFalse);
  expect(CalendarOrdinal.julian > CalendarOrdinal.iso, isTrue);
  expect(CalendarOrdinal.iso > CalendarOrdinal.julian, isFalse);
  expect(CalendarOrdinal.iso >= CalendarOrdinal.iso, isTrue);
  expect(CalendarOrdinal.iso >= CalendarOrdinal.julian, isFalse);
  expect(CalendarOrdinal.julian - CalendarOrdinal.gregorian, 1);
  expect(CalendarOrdinal.julian + CalendarOrdinal.gregorian, 3);
  // ignore: unrelated_type_equality_checks
  expect(CalendarOrdinal.julian == 2, isTrue);
}

void CalendarOrdinal_ToStringAndParse() {
  expect(CalendarOrdinal.iso.toString(), 'Iso');
  expect(CalendarOrdinal.badi.toString(), 'Badi');
  expect(const CalendarOrdinal(100).toString(), 'undefined');
  expect(CalendarOrdinal.parse(' umalqura '), CalendarOrdinal.umAlQura);
  expect(CalendarOrdinal.parse('Julian'), CalendarOrdinal.julian);
  expect(CalendarOrdinal.parse('Lunar'), isNull);
}

final Iterable<String> SupportedIds = CalendarSystem.ids.toList();
final List<CalendarSystem> SupportedCalendars =
    SupportedIds.map(CalendarSystem.forId).toList();

void MaxDate(CalendarSystem calendar) {
  // Construct the largest LocalDate we can, and validate that all the properties can be fetched without
  // issues.
  ValidateProperties(
      calendar, ICalendarSystem.maxDays(calendar), calendar.maxYear);
}

void MinDate(CalendarSystem calendar) {
  // Construct the smallest LocalDate we can, and validate that all the properties can be fetched without
  // issues.
  ValidateProperties(
      calendar, ICalendarSystem.minDays(calendar), calendar.minYear);
}

void ValidateProperties(
    CalendarSystem calendar, int daysSinceEpoch, int expectedYear) {
  var localDate = LocalDate.fromEpochDay(daysSinceEpoch, calendar);
  expect(localDate.year, expectedYear);

  // Fetch every public instance property of LocalDate, as Noda Time does by
  // reflection (listed here so the test also runs without dart:mirrors).
  for (var property in <Object Function()>[
    () => localDate.calendar,
    () => localDate.year,
    () => localDate.monthOfYear,
    () => localDate.dayOfMonth,
    () => localDate.epochDay,
    () => localDate.dayOfWeek,
    () => localDate.yearOfEra,
    () => localDate.era,
    () => localDate.dayOfYear,
    () => localDate.yearMonthDayCalendar,
    () => localDate.hashCode,
  ]) {
    property();
  }
}
