// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2019 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';

import 'time_machine_testing.dart';

void main() {
  // YearMonthTest.BasicProperties
  test('Properties', Properties);
  test('ToDateInterval', ToDateInterval);

  // YearMonthTest.Comparison
  test('Equals_EqualValues', Equals_EqualValues);
  test('Equals_DifferentMonths', Equals_DifferentMonths);
  test('Equals_DifferentCalendars', Equals_DifferentCalendars);
  test('Equals_DifferentToNull', Equals_DifferentToNull);
  test('Equals_DifferentToOtherType', Equals_DifferentToOtherType);
  test('CompareTo_SameCalendar', CompareTo_SameCalendar);
  test('CompareTo_DifferentCalendars_Throws',
      CompareTo_DifferentCalendars_Throws);
  test('IComparableCompareTo_SameCalendar', IComparableCompareTo_SameCalendar);
  test(
      'IComparableCompareTo_Null_Positive', IComparableCompareTo_Null_Positive);
  // IComparableCompareTo_WrongType_ArgumentException: not applicable, as
  // YearMonth is a Comparable<YearMonth>, so compareTo can't be passed
  // another type.

  // YearMonthTest.Construction
  parameterizedTest(
      'ValidConstruction',
      [
        [2000, 1],
        [2000, 12],
        [-9998, 1],
        [9999, 12],
      ],
      ValidConstruction,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'InvalidConstruction',
      [
        [-9999, 1],
        [10000, 1],
        [2000, 0],
        [2000, 13],
      ],
      InvalidConstruction,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'ValidConstruction_WithCalendar',
      [
        [2000, 1, CalendarSystem.iso],
        [2000, 12, CalendarSystem.iso],
        [-9998, 1, CalendarSystem.iso],
        [9999, 12, CalendarSystem.iso],
        [2000, 1, CalendarSystem.julian],
        [-9997, 1, CalendarSystem.julian],
        [9998, 12, CalendarSystem.julian],
        [5403, 1, CalendarSystem.hebrewCivil],
        [5403, 12, CalendarSystem.hebrewCivil],
        // 5404 is a leap year
        [5404, 1, CalendarSystem.hebrewCivil],
        [5404, 13, CalendarSystem.hebrewCivil],
      ],
      ValidConstruction_WithCalendar,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'InvalidConstruction_WithCalendar',
      [
        [-9999, 1, CalendarSystem.iso],
        [10000, 1, CalendarSystem.iso],
        [2000, 0, CalendarSystem.iso],
        [2000, 13, CalendarSystem.iso],
        // 5403 is *not* a leap year
        [5403, 13, CalendarSystem.hebrewCivil],
        [5404, 14, CalendarSystem.hebrewCivil],
        // The Time Machine Julian calendar system runs from -9997 to 9998
        [-9998, 12, CalendarSystem.julian],
        [9999, 11, CalendarSystem.julian],
      ],
      InvalidConstruction_WithCalendar,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'ValidConstruction_WithIsoEra',
      [
        [100, 1, Era.beforeCommon],
        [2000, 1, Era.common],
      ],
      ValidConstruction_WithIsoEra,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'InvalidConstruction_WithIsoEra',
      [
        [0, 1, Era.beforeCommon],
        [10000, 1, Era.beforeCommon],
        [10000, 1, Era.common],
        [100, 13, Era.common],
        [100, 1, Era.annoMundi],
      ],
      InvalidConstruction_WithIsoEra,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'ValidConstruction_WithEraAndCalendar',
      [
        [100, 1, Era.beforeCommon, CalendarSystem.iso],
        [2000, 1, Era.common, CalendarSystem.iso],
        [100, 1, Era.beforeCommon, CalendarSystem.julian],
        [2000, 1, Era.common, CalendarSystem.julian],
        [5403, 1, Era.annoMundi, CalendarSystem.hebrewCivil],
      ],
      ValidConstruction_WithEraAndCalendar,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'InvalidConstruction_WithEraAndCalendar',
      [
        [0, 1, Era.beforeCommon, CalendarSystem.iso],
        [10000, 1, Era.beforeCommon, CalendarSystem.iso],
        [10000, 1, Era.common, CalendarSystem.iso],
        [100, 13, Era.common, CalendarSystem.iso],
        [100, 1, Era.annoMundi, CalendarSystem.iso],
        [100, 1, Era.common, CalendarSystem.hebrewScriptural],
      ],
      InvalidConstruction_WithEraAndCalendar,
      customDescriptionBuilder: describeArguments);

  // YearMonthTest.Misc
  parameterizedTest(
      'OnDayOfMonth_Valid',
      [
        [CalendarSystem.iso, 1904, 2, 29],
        [CalendarSystem.julian, 1900, 2, 29],
        [CalendarSystem.hebrewCivil, 5402, 2, 30],
        [CalendarSystem.hebrewCivil, 5402, 3, 30],
        [CalendarSystem.hebrewScriptural, 5402, 8, 30],
        [CalendarSystem.hebrewScriptural, 5402, 9, 30],
      ],
      OnDayOfMonth_Valid,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'OnDayOfMonth_Invalid',
      [
        [CalendarSystem.iso, 1900, 2, 29],
        [CalendarSystem.julian, 1900, 2, 30],
        [CalendarSystem.hebrewCivil, 5401, 2, 30],
        [CalendarSystem.hebrewCivil, 5401, 3, 30],
        [CalendarSystem.hebrewScriptural, 5401, 8, 30],
        [CalendarSystem.hebrewScriptural, 5401, 9, 30],
      ],
      OnDayOfMonth_Invalid,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'PlusMonths',
      [
        [2014, 8, 4, 2014, 12],
        [2014, 8, 5, 2015, 1],
        [2014, 8, 0, 2014, 8],
        [2014, 8, -1, 2014, 7],
        [2014, 8, -8, 2013, 12],
      ],
      PlusMonths,
      customDescriptionBuilder: describeArguments);
  test('ToStringTest_Iso', ToStringTest_Iso);
  // ToStringBclEquality: not applicable (compares with the BCL's culture
  // year/month patterns).
  // YearMonthTest.XmlSerialization: not applicable (no XML serialization).

  // Not in Noda Time: Time Machine specifics.
  test('Comparison_Operators', Comparison_Operators);
  test('ComparisonOperators_DifferentCalendars_Throws',
      ComparisonOperators_DifferentCalendars_Throws);
  test('SubtractMonths', SubtractMonths);
  test('PlusMonths_NonIsoCalendar', PlusMonths_NonIsoCalendar);
  test('LocalDate_ToYearMonth', LocalDate_ToYearMonth);
  test('ToDateInterval_LeapYearAndNonIsoCalendar',
      ToDateInterval_LeapYearAndNonIsoCalendar);
}

// YearMonthTest.BasicProperties

void Properties() {
  // Some of these are covered in other tests too, but it doesn't hurt
  // to repeat ourselves here.
  var yearMonth = YearMonth(2000, 1);
  expect(yearMonth.year, 2000);
  expect(yearMonth.month, 1);
  expect(yearMonth.calendar, CalendarSystem.iso);
  expect(yearMonth.yearOfEra, 2000);
  expect(yearMonth.era, Era.common);

  // Noda Time's StartDate and EndDate are internal; Time Machine's are too.
  expect(IYearMonth.startDate(yearMonth), LocalDate(2000, 1, 1));
  expect(IYearMonth.endDate(yearMonth), LocalDate(2000, 1, 31));
}

void ToDateInterval() {
  var yearMonth = YearMonth(2000, 1);

  var interval = DateInterval(LocalDate(2000, 1, 1), LocalDate(2000, 1, 31));
  expect(yearMonth.toDateInterval(), interval);
}

// YearMonthTest.Comparison
// These tests were copied from LocalDateTest and then modified for YearMonth.

void Equals_EqualValues() {
  CalendarSystem calendar = CalendarSystem.julian;
  YearMonth yearMonth1 = YearMonth(2011, 1, calendar);
  YearMonth yearMonth2 = YearMonth(2011, 1, calendar);
  expect(yearMonth1, yearMonth2);
  expect(yearMonth1.hashCode, yearMonth2.hashCode);
  expect(yearMonth1 == yearMonth2, isTrue);
  expect(yearMonth1 != yearMonth2, isFalse);
  expect(yearMonth1.equals(yearMonth2), isTrue); // IEquatable implementation
}

void Equals_DifferentMonths() {
  CalendarSystem calendar = CalendarSystem.julian;
  YearMonth yearMonth1 = YearMonth(2011, 1, calendar);
  YearMonth yearMonth2 = YearMonth(2011, 2, calendar);
  expect(yearMonth1, isNot(yearMonth2));
  expect(yearMonth1.hashCode, isNot(yearMonth2.hashCode));
  expect(yearMonth1 == yearMonth2, isFalse);
  expect(yearMonth1 != yearMonth2, isTrue);
  expect(yearMonth1.equals(yearMonth2), isFalse); // IEquatable implementation
}

void Equals_DifferentCalendars() {
  CalendarSystem calendar = CalendarSystem.julian;
  YearMonth yearMonth1 = YearMonth(2011, 1, calendar);
  YearMonth yearMonth2 = YearMonth(2011, 1, CalendarSystem.iso);
  expect(yearMonth1, isNot(yearMonth2));
  expect(yearMonth1.hashCode, isNot(yearMonth2.hashCode));
  expect(yearMonth1 == yearMonth2, isFalse);
  expect(yearMonth1 != yearMonth2, isTrue);
  expect(yearMonth1.equals(yearMonth2), isFalse); // IEquatable implementation
}

void Equals_DifferentToNull() {
  YearMonth date = YearMonth(2011, 1);
  YearMonth? nullYearMonth;
  expect(date == nullYearMonth, isFalse);
}

void Equals_DifferentToOtherType() {
  YearMonth date = YearMonth(2011, 1);
  // ignore: unrelated_type_equality_checks
  expect(date == Instant.fromEpochMicroseconds(0), isFalse);
}

void CompareTo_SameCalendar() {
  YearMonth yearMonth1 = YearMonth(2011, 1);
  YearMonth yearMonth2 = YearMonth(2011, 1);
  YearMonth yearMonth3 = YearMonth(2011, 2);

  // TestHelper.TestOperatorComparisonEquality(yearMonth1, yearMonth2, yearMonth3);
  TestHelper.TestCompareToStruct(yearMonth1, yearMonth2, [yearMonth3]);

  expect(yearMonth1 == yearMonth2, isTrue);
  expect(yearMonth1 != yearMonth2, isFalse);
  expect(yearMonth1 == yearMonth3, isFalse);
  expect(yearMonth1 != yearMonth3, isTrue);

  expect(yearMonth1 < yearMonth2, isFalse);
  expect(yearMonth1 < yearMonth3, isTrue);
  expect(yearMonth3 < yearMonth1, isFalse);
  expect(yearMonth1 <= yearMonth2, isTrue);
  expect(yearMonth1 <= yearMonth3, isTrue);
  expect(yearMonth3 <= yearMonth1, isFalse);
  expect(yearMonth1 > yearMonth2, isFalse);
  expect(yearMonth1 > yearMonth3, isFalse);
  expect(yearMonth3 > yearMonth1, isTrue);
  expect(yearMonth1 >= yearMonth2, isTrue);
  expect(yearMonth1 >= yearMonth3, isFalse);
  expect(yearMonth3 >= yearMonth1, isTrue);
}

void CompareTo_DifferentCalendars_Throws() {
  CalendarSystem islamic = CalendarSystem.getIslamicCalendar(
      IslamicLeapYearPattern.base15, IslamicEpoch.astronomical);
  YearMonth yearMonth1 = YearMonth(2011, 1);
  YearMonth yearMonth2 = YearMonth(1500, 1, islamic);

  // Assert.Throws<ArgumentException>
  expect(() => yearMonth1.compareTo(yearMonth2), throwsArgumentError);
  expect(() => (yearMonth1 as Comparable).compareTo(yearMonth2),
      throwsArgumentError);
  expect(() => (yearMonth1 > yearMonth2).toString(), throwsArgumentError);
}

/// IComparable.CompareTo works properly with YearMonth inputs with same calendar.
void IComparableCompareTo_SameCalendar() {
  var instance = YearMonth(2012, 3);
  Comparable i_instance = instance;

  var later = YearMonth(2012, 6);
  var earlier = YearMonth(2012, 1);
  var same = YearMonth(2012, 3);

  expect(i_instance.compareTo(later), lessThan(0));
  expect(i_instance.compareTo(earlier), greaterThan(0));
  expect(i_instance.compareTo(same), 0);
}

/// IComparable.CompareTo returns a positive number for a null input.
void IComparableCompareTo_Null_Positive() {
  var instance = YearMonth(2012, 3);
  var result = instance.compareTo(null);
  expect(result, greaterThan(0));
}

// YearMonthTest.Construction

void ValidConstruction(int year, int month) {
  var yearMonth = YearMonth(year, month);
  expect(yearMonth.year, year);
  expect(yearMonth.month, month);
  expect(yearMonth.calendar, CalendarSystem.iso);
}

void InvalidConstruction(int year, int month) {
  // Assert.Throws<ArgumentOutOfRangeException>
  expect(() => YearMonth(year, month), throwsRangeError);
}

void ValidConstruction_WithCalendar(
    int year, int month, CalendarSystem calendar) {
  var yearMonth = YearMonth(year, month, calendar);
  expect(yearMonth.year, year);
  expect(yearMonth.month, month);
  expect(yearMonth.calendar, calendar);
}

void InvalidConstruction_WithCalendar(
    int year, int month, CalendarSystem calendar) {
  // Assert.Throws<ArgumentOutOfRangeException>
  expect(() => YearMonth(year, month, calendar), throwsRangeError);
}

void ValidConstruction_WithIsoEra(int yearOfEra, int month, Era era) {
  var yearMonth = YearMonth(yearOfEra, month, null, era);
  expect(yearMonth.era, era);
  expect(yearMonth.yearOfEra, yearOfEra);
  expect(yearMonth.month, month);
  expect(yearMonth.calendar, CalendarSystem.iso);
}

void InvalidConstruction_WithIsoEra(int yearOfEra, int month, Era era) {
  // We'll assume it throws the correct exact exception type. It varies by test case.
  // (Assert.That(..., Throws.InstanceOf<ArgumentException>()); RangeError is
  // an ArgumentError.)
  expect(() => YearMonth(yearOfEra, month, null, era), throwsArgumentError);
}

void ValidConstruction_WithEraAndCalendar(
    int yearOfEra, int month, Era era, CalendarSystem calendar) {
  var yearMonth = YearMonth(yearOfEra, month, calendar, era);
  expect(yearMonth.era, era);
  expect(yearMonth.yearOfEra, yearOfEra);
  expect(yearMonth.month, month);
  expect(yearMonth.calendar, calendar);
}

void InvalidConstruction_WithEraAndCalendar(
    int yearOfEra, int month, Era era, CalendarSystem calendar) {
  // We'll assume it throws the correct exact exception type. It varies by test case.
  expect(() => YearMonth(yearOfEra, month, calendar, era), throwsArgumentError);
}

// YearMonthTest.Misc

void OnDayOfMonth_Valid(CalendarSystem calendar, int year, int month, int day) {
  var yearMonth = YearMonth(year, month, calendar);
  var actualDate = yearMonth.onDayOfMonth(day);
  var expectedDate = LocalDate(year, month, day, calendar);
  expect(actualDate, expectedDate);
}

void OnDayOfMonth_Invalid(
    CalendarSystem calendar, int year, int month, int day) {
  var yearMonth = YearMonth(year, month, calendar);
  // Assert.Throws<ArgumentOutOfRangeException>
  expect(() => yearMonth.onDayOfMonth(day), throwsRangeError);
}

void PlusMonths(
    int year, int month, int monthsToAdd, int expectedYear, int expectedMonth) {
  var yearMonth = YearMonth(year, month);
  var expected = YearMonth(expectedYear, expectedMonth);
  expect(yearMonth.addMonths(monthsToAdd), expected);
}

void ToStringTest_Iso() {
  // Noda Time formats with the culture's year/month pattern by default (and
  // tests this for every culture); Time Machine's culture data has no
  // year/month pattern, so the default is the ISO pattern, uuuu'-'MM.
  var yearMonth = YearMonth(2022, 1);
  expect(yearMonth.toString(), '2022-01');
  expect(yearMonth.toString(), yearMonth.toString("uuuu'-'MM"));
  expect(yearMonth.toString(null, Culture.invariant), '2022-01');
  expect(YearMonth(-5, 12).toString(), '-0005-12');
}

// Not in Noda Time

void Comparison_Operators() {
  YearMonth yearMonth1 = YearMonth(2011, 1);
  YearMonth yearMonth2 = YearMonth(2011, 1);
  YearMonth yearMonth3 = YearMonth(2011, 5);
  YearMonth yearMonth4 = YearMonth(2012, 2);

  expect(yearMonth1 < yearMonth2, isFalse);
  expect(yearMonth1 < yearMonth3, isTrue);
  expect(yearMonth3 < yearMonth4, isTrue);
  expect(yearMonth3 < yearMonth1, isFalse);

  expect(yearMonth1 <= yearMonth2, isTrue);
  expect(yearMonth1 <= yearMonth3, isTrue);
  expect(yearMonth3 <= yearMonth1, isFalse);

  expect(yearMonth1 > yearMonth2, isFalse);
  expect(yearMonth1 > yearMonth3, isFalse);
  expect(yearMonth4 > yearMonth3, isTrue);

  expect(yearMonth1 >= yearMonth2, isTrue);
  expect(yearMonth1 >= yearMonth3, isFalse);
  expect(yearMonth3 >= yearMonth1, isTrue);
}

void ComparisonOperators_DifferentCalendars_Throws() {
  YearMonth yearMonth1 = YearMonth(2011, 1);
  YearMonth yearMonth2 = YearMonth(2011, 1, CalendarSystem.julian);

  expect(() => (yearMonth1 < yearMonth2).toString(), throwsArgumentError);
  expect(() => (yearMonth1 <= yearMonth2).toString(), throwsArgumentError);
  expect(() => (yearMonth1 > yearMonth2).toString(), throwsArgumentError);
  expect(() => (yearMonth1 >= yearMonth2).toString(), throwsArgumentError);
}

void SubtractMonths() {
  var yearMonth = YearMonth(2014, 8);
  expect(yearMonth.subtractMonths(8), YearMonth(2013, 12));
  expect(yearMonth.subtractMonths(-5), YearMonth(2015, 1));
  expect(yearMonth.subtractMonths(0), yearMonth);
  expect(yearMonth.subtractMonths(3), yearMonth.addMonths(-3));
}

void PlusMonths_NonIsoCalendar() {
  var calendar = CalendarSystem.hebrewCivil;
  // 5404 is a leap year (13 months); 5403 isn't.
  expect(YearMonth(5404, 12, calendar).addMonths(1),
      YearMonth(5404, 13, calendar));
  expect(
      YearMonth(5403, 12, calendar).addMonths(1), YearMonth(5404, 1, calendar));
  expect(YearMonth(5404, 13, calendar).addMonths(1).calendar, calendar);
}

void LocalDate_ToYearMonth() {
  var calendar = CalendarSystem.julian;
  var date = LocalDate(2011, 2, 28, calendar);
  var yearMonth = date.toYearMonth();
  expect(yearMonth, YearMonth(2011, 2, calendar));
  expect(yearMonth.calendar, calendar);
  expect(yearMonth.onDayOfMonth(28), date);
}

void ToDateInterval_LeapYearAndNonIsoCalendar() {
  expect(YearMonth(2000, 2).toDateInterval(),
      DateInterval(LocalDate(2000, 2, 1), LocalDate(2000, 2, 29)));
  expect(YearMonth(1900, 2).toDateInterval().length, 28);
  var julian = CalendarSystem.julian;
  var interval = YearMonth(1900, 2, julian).toDateInterval();
  expect(interval.start, LocalDate(1900, 2, 1, julian));
  expect(interval.end, LocalDate(1900, 2, 29, julian));
}
