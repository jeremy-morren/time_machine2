// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
//import 'package:matcher/matcher.dart';

import 'time_machine_testing.dart';

void main() {
  setUpAll(TimeMachineTest.initialize);

  test('PeriodUntil', PeriodUntil);
  test('Difference', Difference);
  test('EqualsMethod', EqualsMethod);
  test('CurrentClockTime', CurrentClockTime);
  test('MinValueEqualToMidnight', MinValueEqualToMidnight);
  test('MaxValue', MaxValue);
  test('ClockHourOfHalfDay', ClockHourOfHalfDay);
  test('DefaultConstructor', DefaultConstructor);
  test('Max', Max);
  test('Min', Min);
  test('WithOffset', WithOffset);
  test('TestToString', TestToString);
}

void PeriodUntil() {
  var start = LocalTime(10, 0, 0);
  var end = LocalTime(12, 30, 15, ms: 5);
  expect(start.periodUntil(end),
      const Period(hours: 2, minutes: 30, seconds: 15, milliseconds: 5));
  expect(end.periodUntil(start),
      const Period(hours: -2, minutes: -30, seconds: -15, milliseconds: -5));
  expect(start.periodUntil(start), Period.zero);
}

void Difference() {
  var start = LocalTime(10, 0, 0);
  var end = LocalTime(12, 30, 0);
  // Like Noda Time's `end - start`.
  expect(LocalTime.difference(end, start), const Period(hours: 2, minutes: 30));
  expect(
      LocalTime.difference(start, end), const Period(hours: -2, minutes: -30));
}

void EqualsMethod() {
  expect(LocalTime(1, 2, 3).equals(LocalTime(1, 2, 3)), isTrue);
  expect(LocalTime(1, 2, 3).equals(LocalTime(1, 2, 4)), isFalse);
}

void CurrentClockTime() {
  var instant = Instant.utc(2020, 6, 1, 13, 45, 30);
  var previous = Clock.current;
  Clock.current = FakeClock(instant);
  try {
    expect(LocalTime.currentClockTime(), instant.inLocalZone().clockTime);
  } finally {
    Clock.current = previous;
  }
}

void MinValueEqualToMidnight() {
  expect(LocalTime.midnight, LocalTime.minValue);
}

void MaxValue() {
  expect(TimeConstants.nanosecondsPerDay - 1,
      LocalTime.maxValue.timeSinceMidnight.inNanoseconds);
}

void ClockHourOfHalfDay() {
  expect(12, LocalTime(0, 0, 0).hourOf12HourClock);
  expect(1, LocalTime(1, 0, 0).hourOf12HourClock);
  expect(12, LocalTime(12, 0, 0).hourOf12HourClock);
  expect(1, LocalTime(13, 0, 0).hourOf12HourClock);
  expect(11, LocalTime(23, 0, 0).hourOf12HourClock);
}

///   Using the default constructor is equivalent to midnight
void DefaultConstructor() {
  // todo: new LocalTime();
  var actual = LocalTime(0, 0, 0);
  expect(LocalTime.midnight, actual);
}

void Max() {
  LocalTime x = LocalTime(5, 10, 0);
  LocalTime y = LocalTime(6, 20, 0);
  expect(y, LocalTime.max(x, y));
  expect(y, LocalTime.max(y, x));
  expect(x, LocalTime.max(x, LocalTime.minValue));
  expect(x, LocalTime.max(LocalTime.minValue, x));
  expect(LocalTime.maxValue, LocalTime.max(LocalTime.maxValue, x));
  expect(LocalTime.maxValue, LocalTime.max(x, LocalTime.maxValue));
}

void Min() {
  LocalTime x = LocalTime(5, 10, 0);
  LocalTime y = LocalTime(6, 20, 0);
  expect(x, LocalTime.min(x, y));
  expect(x, LocalTime.min(y, x));
  expect(LocalTime.minValue, LocalTime.min(x, LocalTime.minValue));
  expect(LocalTime.minValue, LocalTime.min(LocalTime.minValue, x));
  expect(x, LocalTime.min(LocalTime.maxValue, x));
  expect(x, LocalTime.min(x, LocalTime.maxValue));
}

void WithOffset() {
  var time = LocalTime(3, 45, 12, ms: 34);
  var offset = Offset.hours(5);
  var expected = OffsetTime(time, offset);
  expect(expected, time.withOffset(offset));
}

void TestToString() {
  // As in Noda Time, this is the OffsetTime's ToString.
  var value = LocalTime(3, 45, 12, ms: 34).withOffset(Offset.hours(5));
  expect(value.toString(), value.toString(null, null));
  // Not in Noda Time: the LocalTime's own.
  var time = LocalTime(3, 45, 12, ms: 34);
  expect(time.toString(), time.toString(null, null));
}
