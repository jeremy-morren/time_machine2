// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';

import 'time_machine_testing.dart';

void main() {
  test('Construction_DifferentCalendars', Construction_DifferentCalendars);
  test('Construction_EndBeforeStart', Construction_EndBeforeStart);
  test('Construction_EqualStartAndEnd', Construction_EqualStartAndEnd);
  test('Construction_Properties', Construction_Properties);
  test('Equals_SameInstance', Equals_SameInstance);
  test('Equals_EqualValues', Equals_EqualValues);
  test('Equals_DifferentCalendars', Equals_DifferentCalendars);
  test('Equals_DifferentStart', Equals_DifferentStart);
  test('Equals_DifferentEnd', Equals_DifferentEnd);
  test('Equals_DifferentToOtherType', Equals_DifferentToOtherType);
  test('Equals', Equals);
  test('StringRepresentation', StringRepresentation);
  test('Length', Length);
  test('Calendar', Calendar);
  parameterizedTest(
      'Contains',
      [
        ['1999-12-31', false]
            .options(customDescriptionBuilder: (_, __, ___) => "Before start"),
        ['2000-01-01', true]
            .options(customDescriptionBuilder: (_, __, ___) => "On start"),
        ['2005-06-06', true]
            .options(customDescriptionBuilder: (_, __, ___) => "In middle"),
        ['2014-06-30', true]
            .options(customDescriptionBuilder: (_, __, ___) => "On end"),
        ['2014-07-01', false]
            .options(customDescriptionBuilder: (_, __, ___) => "After end"),
      ],
      Contains,
      customDescriptionBuilder: describeArguments);
  test('Contains_DifferentCalendar', Contains_DifferentCalendar);
  test('Contains_IntervalWithinAnotherCalendar_Throws',
      Contains_IntervalWithinAnotherCalendar_Throws);
  parameterizedTest(
      'Contains_IntervalOverload',
      [
        ['2014-03-07,2014-03-07', "2014-03-07,2014-03-07", true],
        ['2014-03-07,2014-03-10', "2015-01-01,2015-04-01", false],
        ['2015-01-01,2015-04-01', "2014-03-07,2014-03-10", false],
        ['2014-03-07,2014-03-31', "2014-03-07,2014-03-15", true],
        ['2014-03-07,2014-03-31', "2014-03-10,2014-03-31", true],
        ['2014-03-07,2014-03-31', "2014-03-10,2014-03-15", true],
        ['2014-03-07,2014-03-31', "2014-03-05,2014-03-09", false],
        ['2014-03-07,2014-03-31', "2014-03-20,2014-04-07", false],
        ['2014-11-01,2014-11-30', "2014-01-01,2014-12-31", false],
      ],
      Contains_IntervalOverload,
      customDescriptionBuilder: describeArguments);
  test('Intersection_IntervalInDifferentCalendar_Throws',
      Intersection_IntervalInDifferentCalendar_Throws);
  parameterizedTest(
      'Intersection',
      [
        [
          '2014-03-07,2014-03-07',
          "2014-03-07,2014-03-07",
          "2014-03-07,2014-03-07"
        ],
        ['2014-03-07,2014-03-10', "2015-01-01,2015-04-01", null],
        ['2015-01-01,2015-04-01', "2014-03-07,2014-03-10", null],
        [
          '2014-03-07,2014-03-31',
          "2014-03-07,2014-03-15",
          "2014-03-07,2014-03-15"
        ],
        [
          '2014-03-07,2014-03-31',
          "2014-03-10,2014-03-31",
          "2014-03-10,2014-03-31"
        ],
        [
          '2014-03-07,2014-03-31',
          "2014-03-10,2014-03-15",
          "2014-03-10,2014-03-15"
        ],
        [
          '2014-03-07,2014-03-31',
          "2014-03-05,2014-03-09",
          "2014-03-07,2014-03-09"
        ],
        [
          '2014-03-07,2014-03-31',
          "2014-03-20,2014-04-07",
          "2014-03-20,2014-03-31"
        ],
        [
          '2014-11-01,2014-11-30',
          "2014-01-01,2014-12-31",
          "2014-11-01,2014-11-30"
        ],
      ],
      Intersection,
      customDescriptionBuilder: describeArguments);
  test('Union_DifferentCalendar_Throws', Union_DifferentCalendar_Throws);
  parameterizedTest(
      'Union',
      [
        ['2014-03-07,2014-03-20', "2015-03-07,2015-03-20", null].options(
            customDescriptionBuilder: (_, __, ___) => "Disjointed intervals"),
        [
          '2014-03-07,2014-03-20',
          "2014-03-21,2014-03-30",
          "2014-03-07,2014-03-30"
        ].options(
            customDescriptionBuilder: (_, __, ___) => "Abutting intervals"),
        [
          '2014-03-07,2014-03-20',
          "2014-03-07,2014-03-20",
          "2014-03-07,2014-03-20"
        ].options(customDescriptionBuilder: (_, __, ___) => "Equal intervals"),
        [
          '2014-03-07,2014-03-20',
          "2014-03-15,2014-03-23",
          "2014-03-07,2014-03-23"
        ].options(
            customDescriptionBuilder: (_, __, ___) => "Overlapping intervals"),
        [
          '2014-03-07,2014-03-20',
          "2014-03-10,2014-03-15",
          "2014-03-07,2014-03-20"
        ].options(
            customDescriptionBuilder: (_, __, ___) =>
                "Interval completely contained in another"),
      ],
      Union,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'Iteration',
      [
        [
          '2018-05-04,2018-05-06',
          ['2018-05-04', '2018-05-05', '2018-05-06']
        ].options(customDescriptionBuilder: (_, __, ___) => 'Multi-day'),
        [
          '2018-05-04,2018-05-04',
          ['2018-05-04']
        ].options(customDescriptionBuilder: (_, __, ___) => 'Single date'),
        [
          '9999-12-29,9999-12-31',
          ['9999-12-29', '9999-12-30', '9999-12-31']
        ].options(customDescriptionBuilder: (_, __, ___) => 'Max dates'),
      ],
      Iteration,
      customDescriptionBuilder: describeArguments);
  // Not in Noda Time: DateInterval is an Iterable<LocalDate>.
  test('Iterable_Length', Iterable_Length);
  test('Iterable_IsNeverEmpty', Iterable_IsNeverEmpty);
  test('Iterable_FirstAndLast', Iterable_FirstAndLast);
  test('Iterable_ElementAt', Iterable_ElementAt);
  test('Iterable_ElementAt_OutOfRange', Iterable_ElementAt_OutOfRange);
  test('Iterable_Contains_NonLocalDate', Iterable_Contains_NonLocalDate);
  test('Iterable_SingleDay', Iterable_SingleDay);
  test('Iterable_EndingAtMaxIsoValue', Iterable_EndingAtMaxIsoValue);
  test('Iterable_StartingAtMinIsoValue', Iterable_StartingAtMinIsoValue);
  test('Iterable_NonIsoCalendar', Iterable_NonIsoCalendar);
  test('Iterable_Repeatable', Iterable_Repeatable);
}

final CalendarSystem JulianCalendar = CalendarSystem.julian;

void Construction_DifferentCalendars() {
  LocalDate start = LocalDate(1600, 1, 1);
  LocalDate end = LocalDate(1800, 1, 1, JulianCalendar);
  expect(() => DateInterval(start, end), throwsArgumentError);
// Assert.Throws<ArgumentException>(() => new DateInterval(start, end));
}

void Construction_EndBeforeStart() {
  LocalDate start = LocalDate(1600, 1, 1);
  LocalDate end = LocalDate(1500, 1, 1);
  expect(() => DateInterval(start, end), throwsArgumentError);
// Assert.Throws<ArgumentException>(() => new DateInterval(start, end));
}

void Construction_EqualStartAndEnd() {
  LocalDate start = LocalDate(2000, 1, 1);
  // Assert.DoesNotThrow(() => new DateInterval(start, start));
  expect(() => DateInterval(start, start), isNotNull);
}

void Construction_Properties() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval = DateInterval(start, end);
  expect(start, interval.start);
  expect(end, interval.end);
}

void Equals_SameInstance() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval = DateInterval(start, end);

  expect(interval, interval);
  expect(interval.hashCode, interval.hashCode);
  // CS1718: Comparison made to same variable.  This is intentional to test operator ==.
  //#pragma warning disable 1718
  expect(interval == interval, isTrue);
  expect(interval != interval, isFalse);
  //#pragma warning restore 1718
  expect(interval.equals(interval), isTrue); // IEquatable implementation
}

void Equals_EqualValues() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval1 = DateInterval(start, end);
  var interval2 = DateInterval(start, end);

  expect(interval1, interval2);
  expect(interval1.hashCode, interval2.hashCode);
  expect(interval1 == interval2, isTrue);
  expect(interval1 != interval2, isFalse);
  expect(interval1.equals(interval2), isTrue); // IEquatable implementation
}

void Equals_DifferentCalendars() {
  LocalDate start1 = LocalDate(2000, 1, 1);
  LocalDate end1 = LocalDate(2001, 6, 19);
  // This is a really, really similar calendar to ISO, but we do distinguish.
  LocalDate start2 = start1.withCalendar(CalendarSystem.gregorian);
  LocalDate end2 = end1.withCalendar(CalendarSystem.gregorian);
  var interval1 = DateInterval(start1, end1);
  var interval2 = DateInterval(start2, end2);

  expect(interval1, isNot(interval2));
  expect(interval1.hashCode, isNot(interval2.hashCode));
  expect(interval1 == interval2, isFalse);
  expect(interval1 != interval2, isTrue);
  expect(interval1.equals(interval2), isFalse); // IEquatable implementation
}

void Equals_DifferentStart() {
  LocalDate start1 = LocalDate(2000, 1, 1);
  LocalDate start2 = LocalDate(2000, 1, 2);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval1 = DateInterval(start1, end);
  var interval2 = DateInterval(start2, end);

  expect(interval1, isNot(interval2));
  expect(interval1.hashCode, isNot(interval2.hashCode));
  expect(interval1 == interval2, isFalse);
  expect(interval1 != interval2, isTrue);
  expect(interval1.equals(interval2), isFalse); // IEquatable implementation
}

void Equals_DifferentEnd() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end1 = LocalDate(2001, 6, 19);
  LocalDate end2 = LocalDate(2001, 6, 20);
  var interval1 = DateInterval(start, end1);
  var interval2 = DateInterval(start, end2);

  expect(interval1, isNot(interval2));
  expect(interval1.hashCode, isNot(interval2.hashCode));
  expect(interval1 == interval2, isFalse);
  expect(interval1 != interval2, isTrue);
  expect(interval1.equals(interval2), isFalse); // IEquatable implementation
}

void Equals_DifferentToOtherType() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval = DateInterval(start, end);
  // expect(interval.equals(new Instant.fromUnixTimeTicks(0)), isFalse);
  // ignore: unrelated_type_equality_checks
  expect(interval == Instant.fromEpochMicroseconds(0), isFalse);
}

void StringRepresentation() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval = DateInterval(start, end);
  expect(interval.toString(), '[2000-01-01, 2001-06-19]');
}

void Length() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2000, 2, 10);
  var interval = DateInterval(start, end);
  expect(41, interval.length);
}

void Calendar() {
  var calendar = CalendarSystem.julian;
  LocalDate start = LocalDate(2000, 1, 1, calendar);
  LocalDate end = LocalDate(2000, 2, 10, calendar);
  var interval = DateInterval(start, end);
  expect(calendar, interval.calendar);
}

void Contains(String candidateText, bool expected) {
  var start = LocalDate(2000, 1, 1);
  var end = LocalDate(2014, 06, 30);
  var candidate = LocalDatePattern.iso.parse(candidateText).value;
  var interval = DateInterval(start, end);
  expect(expected, interval.contains(candidate));
}

void Contains_DifferentCalendar() {
  var start = LocalDate(2000, 1, 1);
  var end = LocalDate(2014, 06, 30);
  var interval = DateInterval(start, end);
  var candidate = LocalDate(2000, 1, 1, JulianCalendar);
  // Assert.Throws<ArgumentException>(() => interval.Contains(candidate));
  expect(() => interval.contains(candidate), throwsArgumentError);
}

//@Test()
//void Deconstruction()
//{
//  var start = new LocalDate(2017, 11, 6);
//  var end = new LocalDate(2017, 11, 10);
//  var value = new DateInterval(start, end);
//
//  var (actualStart, actualEnd) = value;
//
//Assert.Multiple(() {
//  expect(start, actualStart);
//  expect(end, actualEnd);
//  });
//}

// Contains_NullInterval_Throws: not applicable. Noda Time's Contains(null)
// throws ArgumentNullException, but DateInterval.contains is
// Iterable.contains, which returns false for null (see
// Iterable_Contains_NonLocalDate).

void Contains_IntervalWithinAnotherCalendar_Throws() {
  var value = DateInterval(LocalDate(2017, 11, 6, CalendarSystem.gregorian),
      LocalDate(2017, 11, 10, CalendarSystem.gregorian));

  var other = DateInterval(LocalDate(2017, 11, 6, CalendarSystem.coptic),
      LocalDate(2017, 11, 10, CalendarSystem.coptic));

  // Assert.Throws<ArgumentException>(() => value.Contains(other));
  expect(() => value.containsInterval(other), throwsArgumentError);
}

void Contains_IntervalOverload(
    String firstInterval, String secondInterval, bool expectedResult) {
  DateInterval value = ParseInterval(firstInterval);
  DateInterval other = ParseInterval(secondInterval);
  expect(expectedResult, value.containsInterval(other));
}

// @Test()
// void Intersection_NullInterval_Throws()
// {
//   var value = DateInterval(LocalDate.fromEpochDay(100), LocalDate.fromEpochDay(200));
//   // Assert.Throws<ArgumentNullException>(() => value.Intersection(null));
//   expect(() => value.intersection(null), throwsArgumentError);
// }

void Intersection_IntervalInDifferentCalendar_Throws() {
  var value = DateInterval(LocalDate(2017, 11, 6, CalendarSystem.gregorian),
      LocalDate(2017, 11, 10, CalendarSystem.gregorian));

  var other = DateInterval(LocalDate(2017, 11, 6, CalendarSystem.coptic),
      LocalDate(2017, 11, 10, CalendarSystem.coptic));

  // Assert.Throws<ArgumentException>(() => value.Intersection(other));
  expect(() => value.intersection(other), throwsArgumentError);
}

void Intersection(
    String firstInterval, String secondInterval, String? expectedInterval) {
  var value = ParseInterval(firstInterval);
  var other = ParseInterval(secondInterval);
  var expectedResult = ParseIntervalOrNull(expectedInterval);
  expect(expectedResult, value.intersection(other));
}

// @Test()
// void Union_NullInterval_Throws()
// {
//   var value = DateInterval(LocalDate.fromEpochDay(100), LocalDate.fromEpochDay(200));
//   // Assert.Throws<ArgumentNullException>(() => value.Union(null));
//   expect(() => value.union(null), throwsArgumentError);
// }

void Union_DifferentCalendar_Throws() {
  var value = DateInterval(LocalDate(2017, 11, 6, CalendarSystem.gregorian),
      LocalDate(2017, 11, 10, CalendarSystem.gregorian));

  var other = DateInterval(LocalDate(2017, 11, 6, CalendarSystem.coptic),
      LocalDate(2017, 11, 10, CalendarSystem.coptic));

  // Assert.Throws<ArgumentException>(() => value.Union(other));
  expect(() => value.union(other), throwsArgumentError);
}

void Union(String first, String second, String? expected) {
  DateInterval firstInterval = ParseInterval(first);
  DateInterval secondInterval = ParseInterval(second);
  DateInterval? expectedResult = ParseIntervalOrNull(expected);

  expect(expectedResult, firstInterval.union(secondInterval),
      reason: 'First union failed.');
  expect(expectedResult, secondInterval.union(firstInterval),
      reason: 'Second union failed.');
}

DateInterval? ParseIntervalOrNull(String? textualInterval) =>
    textualInterval == null ? null : ParseInterval(textualInterval);

DateInterval ParseInterval(String textualInterval) {
  var parts = textualInterval.split(','); //new char[] { ',' });
  var start = LocalDatePattern.iso.parse(parts[0]).value;
  var end = LocalDatePattern.iso.parse(parts[1]).value;

  return DateInterval(start, end);
}

void Equals() {
  LocalDate start = LocalDate(2000, 1, 1);
  LocalDate end = LocalDate(2001, 6, 19);
  var interval = DateInterval(start, end);
  var equalInterval = DateInterval(start, end);
  var unequalIntervals = [
    DateInterval(start.addDays(1), end),
    DateInterval(start, end.addDays(1)),
    // This is a really, really similar calendar to ISO, but we do distinguish.
    // (The calendar system has to be the same for the start and end, so we don't
    // need to perform start-different vs end-different equality tests.)
    DateInterval(start.withCalendar(CalendarSystem.gregorian),
        end.withCalendar(CalendarSystem.gregorian)),
  ];
  TestHelper.TestEqualsClass(interval, equalInterval, unequalIntervals);

  expect(interval == equalInterval, isTrue);
  expect(interval != equalInterval, isFalse);

  DateInterval? nullInterval;
  expect(interval == nullInterval, isFalse);
  expect(interval != nullInterval, isTrue);
  expect(nullInterval == interval, isFalse);
  expect(nullInterval != interval, isTrue);

  for (var unequalInterval in unequalIntervals) {
    expect(interval == unequalInterval, isFalse);
    expect(interval != unequalInterval, isTrue);
  }
}

void Iteration(String intervalText, List<String> expectedDatesText) {
  var interval = ParseInterval(intervalText);
  var expected = expectedDatesText
      .map((x) => LocalDatePattern.iso.parse(x).value)
      .toList();
  var actual = interval.toList();
  expect(actual, expected);

  // Noda Time also tests the non-generic IEnumerable; the closest Dart
  // equivalent is driving the Iterator directly.
  var iterator = interval.iterator;
  actual = [];
  while (iterator.moveNext()) {
    actual.add(iterator.current);
  }
  expect(actual, expected);
}

void Iterable_Length() {
  var interval = DateInterval(LocalDate(2000, 1, 1), LocalDate(2000, 2, 10));
  expect(interval.length, 41);
  expect(interval.toList().length, 41);
  // Across a leap day.
  var leap = DateInterval(LocalDate(2000, 2, 28), LocalDate(2000, 3, 1));
  expect(leap.length, 3);
  expect(leap.toList(),
      [LocalDate(2000, 2, 28), LocalDate(2000, 2, 29), LocalDate(2000, 3, 1)]);
}

void Iterable_IsNeverEmpty() {
  var interval = DateInterval(LocalDate(2000, 1, 1), LocalDate(2000, 1, 1));
  expect(interval.isEmpty, isFalse);
  expect(interval.isNotEmpty, isTrue);
}

void Iterable_FirstAndLast() {
  var start = LocalDate(2000, 1, 1);
  var end = LocalDate(2000, 2, 10);
  var interval = DateInterval(start, end);
  expect(interval.first, start);
  expect(interval.last, end);
}

void Iterable_ElementAt() {
  var interval = DateInterval(LocalDate(2000, 1, 30), LocalDate(2000, 3, 2));
  expect(interval.elementAt(0), LocalDate(2000, 1, 30));
  expect(interval.elementAt(1), LocalDate(2000, 1, 31));
  expect(interval.elementAt(2), LocalDate(2000, 2, 1));
  expect(interval.elementAt(interval.length - 1), LocalDate(2000, 3, 2));
  var list = interval.toList();
  for (var i = 0; i < list.length; i++) {
    expect(interval.elementAt(i), list[i]);
  }
}

void Iterable_ElementAt_OutOfRange() {
  var interval = DateInterval(LocalDate(2000, 1, 1), LocalDate(2000, 1, 3));
  expect(() => interval.elementAt(-1), throwsRangeError);
  expect(() => interval.elementAt(3), throwsRangeError);
  // The index is checked before any date arithmetic, even at the end of time.
  var max = DateInterval(LocalDate.maxIsoValue, LocalDate.maxIsoValue);
  expect(() => max.elementAt(1), throwsRangeError);
}

void Iterable_Contains_NonLocalDate() {
  var interval = DateInterval(LocalDate(2000, 1, 1), LocalDate(2000, 1, 3));
  // Iterable.contains takes any object (deliberately unrelated types here).
  // ignore: collection_methods_unrelated_type
  expect(interval.contains(null), isFalse);
  // ignore: collection_methods_unrelated_type
  expect(interval.contains('2000-01-02'), isFalse);
  // ignore: collection_methods_unrelated_type
  expect(interval.contains(LocalDateTime(2000, 1, 2, 0, 0, 0)), isFalse);
  expect(interval.contains(LocalDate(2000, 1, 2)), isTrue);
}

void Iterable_SingleDay() {
  var date = LocalDate(2018, 5, 4);
  var interval = DateInterval(date, date);
  expect(interval.length, 1);
  expect(interval.toList(), [date]);
  expect(interval.single, date);
  expect(interval.first, date);
  expect(interval.last, date);
}

void Iterable_EndingAtMaxIsoValue() {
  var end = LocalDate.maxIsoValue;
  var interval = DateInterval(end.subtractDays(2), end);
  // Iteration must stop at the end date without computing the day after it
  // (which is out of range).
  expect(interval.toList(), [end.subtractDays(2), end.subtractDays(1), end]);
  expect(interval.length, 3);
  expect(interval.last, end);
  expect(interval.elementAt(2), end);
  expect(DateInterval(end, end).toList(), [end]);
}

void Iterable_StartingAtMinIsoValue() {
  var start = LocalDate.minIsoValue;
  var interval = DateInterval(start, start.addDays(2));
  expect(interval.toList(), [start, start.addDays(1), start.addDays(2)]);
  expect(interval.first, start);
}

void Iterable_NonIsoCalendar() {
  var calendar = CalendarSystem.julian;
  // February 1900 has 29 days in the Julian calendar.
  var interval = DateInterval(
      LocalDate(1900, 2, 28, calendar), LocalDate(1900, 3, 1, calendar));
  expect(interval.toList(), [
    LocalDate(1900, 2, 28, calendar),
    LocalDate(1900, 2, 29, calendar),
    LocalDate(1900, 3, 1, calendar)
  ]);
  expect(interval.every((date) => date.calendar == calendar), isTrue);
}

void Iterable_Repeatable() {
  var interval = DateInterval(LocalDate(2000, 1, 1), LocalDate(2000, 1, 5));
  // Each iteration starts again from the start date.
  expect(interval.toList(), interval.toList());
  expect(interval.map((date) => date.dayOfMonth).toList(), [1, 2, 3, 4, 5]);
  expect(interval.where((date) => date.dayOfWeek == DayOfWeek.monday).toList(),
      [LocalDate(2000, 1, 3)]);
}
