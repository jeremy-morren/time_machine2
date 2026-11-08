// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
// import 'package:matcher/matcher.dart';

void main() {
  test('Max', Max);
  test('Min', Min);
  test('DefaultConstructor', DefaultConstructor);
  test('MinMaxValue', MinMaxValue);
  test('TestToString', TestToString);
  test('ToDuration', ToDuration);
  test('ToTime', ToTime);
  test('FromDuration_OutOfRange', FromDuration_OutOfRange);
  test('FromDuration_Truncation', FromDuration_Truncation);
  test('FromDuration_Simple', FromDuration_Simple);
  test('FromTime_OutOfRange', FromTime_OutOfRange);
  test('FromTime_Truncation', FromTime_Truncation);
  test('FromTime_Simple', FromTime_Simple);
}

// Noda Time's ToTimeSpan and FromTimeSpan tests, for Dart's Duration and
// for Time.

void ToDuration() {
  expect(Offset(1234).toDuration(), const Duration(seconds: 1234));
  expect(Offset(-1234).toDuration(), const Duration(seconds: -1234));
}

void ToTime() {
  expect(Offset(1234).toTime(), Time(seconds: 1234));
  expect(Offset(-1234).toTime(), Time(seconds: -1234));
}

void FromDuration_OutOfRange() {
  for (var hours in [-24, 24]) {
    expect(() => Offset.duration(Duration(hours: hours)), throwsRangeError);
  }
}

void FromDuration_Truncation() {
  expect(Offset.duration(const Duration(milliseconds: 1000 + 200)), Offset(1));
  expect(
      Offset.duration(const Duration(milliseconds: -1000 - 200)), Offset(-1));
}

void FromDuration_Simple() {
  expect(Offset.duration(const Duration(hours: 2)), Offset.hours(2));
}

void FromTime_OutOfRange() {
  for (var hours in [-24, 24]) {
    expect(() => Offset.time(Time(hours: hours)), throwsRangeError);
  }
}

void FromTime_Truncation() {
  expect(Offset.time(Time(milliseconds: 1000 + 200)), Offset(1));
  // Truncated towards zero, as in Noda Time (not floored).
  expect(Offset.time(Time(milliseconds: -1000 - 200)), Offset(-1));
  expect(Offset.time(Time(nanoseconds: -1)), Offset.zero);
}

void FromTime_Simple() {
  expect(Offset.time(Time(hours: 2)), Offset.hours(2));
  expect(Offset.time(Time(hours: -18)), Offset.minValue);
}

void Max() {
  Offset x = Offset(100);
  Offset y = Offset(200);
  expect(y, Offset.max(x, y));
  expect(y, Offset.max(y, x));
  expect(x, Offset.max(x, Offset.minValue));
  expect(x, Offset.max(Offset.minValue, x));
  expect(Offset.maxValue, Offset.max(Offset.maxValue, x));
  expect(Offset.maxValue, Offset.max(x, Offset.maxValue));
}

void Min() {
  Offset x = Offset(100);
  Offset y = Offset(200);
  expect(x, Offset.min(x, y));
  expect(x, Offset.min(y, x));
  expect(Offset.minValue, Offset.min(x, Offset.minValue));
  expect(Offset.minValue, Offset.min(Offset.minValue, x));
  expect(x, Offset.min(Offset.maxValue, x));
  expect(x, Offset.min(x, Offset.maxValue));
}

/* todo: redo for dart:core Duration
@Test()
void ToTimeSpan()
{
  TimeSpan ts = new Offset.fromSeconds(1234).ToTimeSpan();
  expect(ts, TimeSpan.FromSeconds(1234));
}

@Test()
void FromTimeSpan_OutOfRange([Values(-24, 24)] int hours)
{
TimeSpan ts = TimeSpan.FromHours(hours);
expect(() => Offset.FromTimeSpan(ts), throwsRangeError);
}

@Test()
void FromTimeSpan_Truncation()
{
  TimeSpan ts = TimeSpan.FromMilliseconds(1000 + 200);
  expect(new Offset.fromSeconds(1), Offset.FromTimeSpan(ts));
}

@Test()
void FromTimeSpan_Simple()
{
  TimeSpan ts = TimeSpan.FromHours(2);
  expect(Offset.FromHours(2), Offset.FromTimeSpan(ts));
}*/

///   Using the default constructor is equivalent to Offset.Zero
void DefaultConstructor() {
  var actual = Offset();
  expect(Offset.zero, actual);
}

// TestHelper.AssertMinMaxValue(Offset.MinValue, Offset.MaxValue)
void MinMaxValue() {
  expect(Offset.minValue, Offset.hours(-18));
  expect(Offset.maxValue, Offset.hours(18));
  expect(Offset.minValue < Offset.maxValue, isTrue);
  expect(Offset.minValue.compareTo(Offset.maxValue), lessThan(0));
  expect(() => Offset(Offset.minValue.inSeconds - 1), throwsRangeError);
  expect(() => Offset(Offset.maxValue.inSeconds + 1), throwsRangeError);
}

void TestToString() {
  var offset = Offset.hoursAndMinutes(5, 30);
  expect(offset.toString(), offset.toString(null, null));
}
