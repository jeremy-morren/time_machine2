// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
// import 'package:matcher/matcher.dart';

import 'time_machine_testing.dart';

void main() {
  setUpAll(TimeMachineTest.initialize);

  test('DefaultConstructor', DefaultConstructor);
  test('CombinationWithTime', CombinationWithTime);
  test('MaxIsoValue', MaxIsoValue);
  test('MinIsoValue', MinIsoValue);
  test('PeriodUntil', PeriodUntil);
  test('Today', Today);
  test('Today_WithCalendar', Today_WithCalendar);
  test('YearMonthDayCalendar', YearMonthDayCalendar_Internal);
}

void PeriodUntil() {
  var start = LocalDate(2011, 3, 5);
  var end = LocalDate(2012, 2, 4);
  expect(start.periodUntil(end), const Period(months: 10, days: 30));
  expect(start.periodUntil(end), Period.differenceBetweenDates(start, end));
  expect(end.periodUntil(start), Period.differenceBetweenDates(end, start));
}

/// Runs [body] with [Clock.current] fixed at [instant].
void _withClock(Instant instant, void Function() body) {
  var previous = Clock.current;
  Clock.current = FakeClock(instant);
  try {
    body();
  } finally {
    Clock.current = previous;
  }
}

void Today() {
  var instant = Instant.utc(2020, 6, 1, 13, 45, 30);
  _withClock(instant, () {
    expect(LocalDate.today(), instant.inLocalZone().calendarDate);
  });
}

void Today_WithCalendar() {
  var instant = Instant.utc(2020, 6, 1, 13, 45, 30);
  _withClock(instant, () {
    var today = LocalDate.today(CalendarSystem.julian);
    expect(today.calendar, CalendarSystem.julian);
    expect(today,
        instant.inLocalZone().calendarDate.withCalendar(CalendarSystem.julian));
  });
}

void YearMonthDayCalendar_Internal() {
  var date = LocalDate(2014, 3, 28, CalendarSystem.julian);
  var ymdc = ILocalDate.yearMonthDayCalendar(date);
  expect(ymdc.toYearMonthDay(), const YearMonthDay(2014, 3, 28));
  expect(ymdc.calendarOrdinal, CalendarOrdinal.julian);
}

/// Using the default constructor is equivalent to January 1st 1970, UTC, ISO calendar
void DefaultConstructor() {
  // todo: new LocalDate()
  var actual = LocalDate(1, 1, 1);
  expect(LocalDate(1, 1, 1), actual);
}

void CombinationWithTime() {
  // Test all three approaches in the same test - they're logically equivalent.
  var calendar = CalendarSystem.julian;
  LocalDate date = LocalDate(2014, 3, 28, calendar);
  LocalTime time = LocalTime(20, 17, 30);
  LocalDateTime expected =
      LocalDateTime(2014, 3, 28, 20, 17, 30, calendar: calendar);
  // expect(expected, date + time);
  expect(expected, date.at(time));
  expect(expected, time.atDate(date));
}

/* null is the default calendar argument (so we can have less constructors) and defaults to an iso calendar
@Test()
void Construction_NullCalendar_Throws()
{
  expect(() => new LocalDate(2017, 11, 7, null), throwsArgumentError, reason: 'Basic construction.');
  expect(() => new LocalDate.forEra(Era.common, 2017, 11, 7, null), throwsArgumentError, reason: 'Construction including era.');
}*/

void MaxIsoValue() {
  var value = LocalDate.maxIsoValue;
  expect(CalendarSystem.iso, value.calendar);
  expect(() => value.addDays(1), throwsRangeError);
}

void MinIsoValue() {
  var value = LocalDate.minIsoValue;
  expect(CalendarSystem.iso, value.calendar);
  expect(() => value.addDays(-1), throwsRangeError);
}
