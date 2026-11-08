// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:test/test.dart';

void main() {
  test('AtMidnight', AtMidnight);
  test('WithCalendar', WithCalendar);
  test('WithOffset', WithOffset);
  test('ToDateTimeUnspecified', ToDateTimeUnspecified);
  test('WithCalendar_OutOfRange', WithCalendar_OutOfRange);
  test('FromDateTime', FromDateTime);
  test('FromDateTime_WithCalendar', FromDateTime_WithCalendar);
  test('FromDateTime_BeforeEpoch', FromDateTime_BeforeEpoch);
}

void AtMidnight() {
  LocalDate date = LocalDate(2011, 6, 29);
  LocalDateTime expected = LocalDateTime(2011, 6, 29, 0, 0, 0);
  expect(date.atMidnight(), expected);
}

void WithCalendar() {
  LocalDate isoEpoch = LocalDate(1970, 1, 1);
  LocalDate julianEpoch = isoEpoch.withCalendar(CalendarSystem.julian);
  expect(1969, julianEpoch.year);
  expect(12, julianEpoch.monthOfYear);
  expect(19, julianEpoch.dayOfMonth);
}

void WithOffset() {
  var date = LocalDate(2011, 6, 29);
  var offset = Offset.hours(5);
  var expected = OffsetDate(date, offset);
  expect(expected, date.withOffset(offset));
}

void ToDateTimeUnspecified() {
  LocalDate noda = LocalDate(2015, 4, 2);
  DateTime bcl = DateTime(2015, 4, 2, 0, 0, 0); //, DateTimeKind.Unspecified);
  // todo: this needs to be redefined as toDateTimeUtc or toDateTimeLocal or something?
  expect(bcl, noda.toDateTimeUnspecified());
}

// Noda Time's DateTimeKind loop is over UTC and local DateTimes here: the
// date is the one the DateTime shows, without any time zone conversion.
void FromDateTime() {
  var expected = LocalDate(2011, 08, 18);
  for (var dateTime in [
    DateTime.utc(2011, 08, 18, 20, 53, 0),
    DateTime(2011, 08, 18, 20, 53, 0)
  ]) {
    expect(LocalDate.dateTime(dateTime), expected);
  }
}

void FromDateTime_WithCalendar() {
  // Julian calendar is 13 days behind Gregorian calendar in the 21st century
  var expected = LocalDate(2011, 08, 05, CalendarSystem.julian);
  for (var dateTime in [
    DateTime.utc(2011, 08, 18, 20, 53, 0),
    DateTime(2011, 08, 18, 20, 53, 0)
  ]) {
    expect(LocalDate.dateTime(dateTime, CalendarSystem.julian), expected);
  }
}

void FromDateTime_BeforeEpoch() {
  // The time of day must not move the date on: before the Unix epoch the
  // number of days has to be rounded down, not towards zero.
  for (var dateTime in [
    DateTime.utc(1966, 08, 18, 20, 53, 0),
    DateTime(1966, 08, 18, 20, 53, 0),
    DateTime.utc(1969, 12, 31, 23, 59, 59, 999),
  ]) {
    expect(LocalDate.dateTime(dateTime),
        LocalDate(dateTime.year, dateTime.month, dateTime.day));
  }
  expect(
      LocalDate.dateTime(DateTime.utc(1966, 08, 18)), LocalDate(1966, 8, 18));
}

void WithCalendar_OutOfRange() {
  LocalDate start = LocalDate(1, 1, 1);
  // Assert.Throws<ArgumentOutOfRangeException>
  expect(
      () => start.withCalendar(CalendarSystem.persianSimple), throwsRangeError);
}
