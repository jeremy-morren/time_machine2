// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';

void main() {
  test('PlusHours_Simple', PlusHours_Simple);
  test('PlusHours_CrossingDayBoundary', PlusHours_CrossingDayBoundary);
  test('PlusHours_CrossingSeveralDaysBoundary',
      PlusHours_CrossingSeveralDaysBoundary);
  test('PlusMinutes_Simple', PlusMinutes_Simple);
  test('PlusSeconds_Simple', PlusSeconds_Simple);
  test('PlusMilliseconds_Simple', PlusMilliseconds_Simple);
  test('PlusMicroseconds_Simple', PlusMicroseconds_Simple);
  test('PlusTicks_Long', PlusTicks_Long);
  test('With', With);
  test('PlusMinutes_WouldOverflowNaively', PlusMinutes_WouldOverflowNaively);
  test('SubtractUnits', SubtractUnits);
}

/// The subtractXxx methods are the same as adding the negated value, so wrap
/// around midnight in the same way.
void SubtractUnits() {
  LocalTime start = LocalTime(0, 0, 0, ns: 500);
  expect(start.subtractHours(2), LocalTime(22, 0, 0, ns: 500));
  expect(start.subtractHours(-2), LocalTime(2, 0, 0, ns: 500));
  expect(start.subtractMinutes(90), LocalTime(22, 30, 0, ns: 500));
  expect(start.subtractSeconds(90), LocalTime(23, 58, 30, ns: 500));
  expect(start.subtractMilliseconds(1), LocalTime(23, 59, 59, ns: 999000500));
  expect(start.subtractMicroseconds(1), LocalTime(23, 59, 59, ns: 999999500));
  expect(start.subtractNanoseconds(501), LocalTime(23, 59, 59, ns: 999999999));
  expect(start.subtractNanoseconds(500), LocalTime.midnight);
  for (var amount in [0, 1, 25, -1000]) {
    expect(start.subtractHours(amount), start.addHours(-amount));
    expect(start.subtractMinutes(amount), start.addMinutes(-amount));
    expect(start.subtractSeconds(amount), start.addSeconds(-amount));
    expect(start.subtractMilliseconds(amount), start.addMilliseconds(-amount));
    expect(start.subtractMicroseconds(amount), start.addMicroseconds(-amount));
    expect(start.subtractNanoseconds(amount), start.addNanoseconds(-amount));
  }
}

void PlusHours_Simple() {
  LocalTime start = LocalTime(12, 15, 8);
  LocalTime expectedForward = LocalTime(14, 15, 8);
  LocalTime expectedBackward = LocalTime(10, 15, 8);
  expect(expectedForward, start.addHours(2));
  expect(expectedBackward, start.addHours(-2));
}

void PlusHours_CrossingDayBoundary() {
  LocalTime start = LocalTime(12, 15, 8);
  LocalTime expected = LocalTime(8, 15, 8);
  expect(expected, start.addHours(20));
  expect(start, start.addHours(20).addHours(-20));
}

void PlusHours_CrossingSeveralDaysBoundary() {
  // Christmas day + 10 days and 1 hour
  LocalTime start = LocalTime(12, 15, 8);
  LocalTime expected = LocalTime(13, 15, 8);
  expect(expected, start.addHours(241));
  expect(start, start.addHours(241).addHours(-241));
}

// Having tested that hours cross boundaries correctly, the other time unit
// tests are straightforward
void PlusMinutes_Simple() {
  LocalTime start = LocalTime(12, 15, 8);
  LocalTime expectedForward = LocalTime(12, 17, 8);
  LocalTime expectedBackward = LocalTime(12, 13, 8);
  expect(expectedForward, start.addMinutes(2));
  expect(expectedBackward, start.addMinutes(-2));
}

void PlusSeconds_Simple() {
  LocalTime start = LocalTime(12, 15, 8);
  LocalTime expectedForward = LocalTime(12, 15, 18);
  LocalTime expectedBackward = LocalTime(12, 14, 58);
  expect(expectedForward, start.addSeconds(10));
  expect(expectedBackward, start.addSeconds(-10));
}

void PlusMilliseconds_Simple() {
  LocalTime start = LocalTime(12, 15, 8, ms: 300);
  LocalTime expectedForward = LocalTime(12, 15, 8, ms: 700);
  LocalTime expectedBackward = LocalTime(12, 15, 7, ms: 900);
  expect(expectedForward, start.addMilliseconds(400));
  expect(expectedBackward, start.addMilliseconds(-400));
}

void PlusMicroseconds_Simple() {
  LocalTime start = LocalTime(12, 15, 8, us: 300750);
  LocalTime expectedForward = LocalTime(12, 15, 8, us: 301150);
  LocalTime expectedBackward = LocalTime(12, 15, 8, us: 300350);
  expect(expectedForward, start.addMicroseconds(400));
  expect(expectedBackward, start.addMicroseconds(-400));
}

void PlusTicks_Long() {
  expect(TimeConstants.microsecondsPerDay > Platform.int32MaxValue, isTrue);
  LocalTime start = LocalTime(12, 15, 8);
  LocalTime expectedForward = LocalTime(12, 15, 9);
  LocalTime expectedBackward = LocalTime(12, 15, 7);
  expect(
      start.addMicroseconds(TimeConstants.microsecondsPerDay +
          TimeConstants.microsecondsPerSecond),
      expectedForward);
  expect(
      start.addMicroseconds(-TimeConstants.microsecondsPerDay -
          TimeConstants.microsecondsPerSecond),
      expectedBackward);
}

void With() {
  LocalTime start = LocalTime(12, 15, 8,
      ns: 100 * TimeConstants.nanosecondsPerMillisecond + 1234 * 100);
  LocalTime expected = LocalTime(12, 15, 8);
  expect(expected, start.adjust(TimeAdjusters.truncateToSecond));
}

void PlusMinutes_WouldOverflowNaively() {
  LocalTime start = LocalTime(12, 34, 56);
  // Very big value, which just wraps round a *lot* and adds one minute.
  // There's no way we could compute that many nanoseconds.
  // note: left-shifting on Web caps at 32 bit and doesn't work here, and the max-int-value is much lower
  int value = Platform.isVM
      ? (TimeConstants.nanosecondsPerDay << 15) + 1
      : (TimeConstants.nanosecondsPerDay * 100) + 1;
  LocalTime expected = LocalTime(12, 35, 56);
  LocalTime actual = start.addMinutes(value);
  expect(actual, expected);
}
