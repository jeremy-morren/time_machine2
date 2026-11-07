// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2016 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Port of Noda Time's NodaTime.Test/Testing/Extensions/DurationConstructionTest.cs,
// for the TimeConstruction extension (Noda Time's DurationConstruction).
// Dart has a single int type, so Noda Time's separate `long` assertions
// (2L.Minutes()) are the same as the int ones. Noda Time's Ticks test isn't
// ported, as Time Machine has no ticks; Microseconds tests the equivalent.
import 'package:test/test.dart';
import 'package:time_machine2/testing.dart';
import 'package:time_machine2/time_machine2.dart';

void main() {
  test('Days', Days);
  test('Hours', Hours);
  test('Minutes', Minutes);
  test('Seconds', Seconds);
  test('Milliseconds', Milliseconds);
  test('Microseconds', Microseconds);
  test('Nanoseconds', Nanoseconds);
}

void Days() {
  expect(2.days, Time(days: 2));
  expect(2.5.days, Time(days: 2.5));
}

void Hours() {
  expect(2.hours, Time(hours: 2));
  expect(2.5.hours, Time(hours: 2.5));
}

void Minutes() {
  expect(2.minutes, Time(minutes: 2));
  expect(2.5.minutes, Time(minutes: 2.5));
}

void Seconds() {
  expect(2.seconds, Time(seconds: 2));
  expect(2.5.seconds, Time(seconds: 2.5));
}

void Milliseconds() {
  expect(2.milliseconds, Time(milliseconds: 2));
  expect(2.5.milliseconds, Time(milliseconds: 2.5));
}

/// In place of Noda Time's Ticks test.
void Microseconds() {
  expect(2.microseconds, Time(microseconds: 2));
  expect(2.5.microseconds, Time(microseconds: 2.5));
}

void Nanoseconds() {
  expect(2.nanoseconds, Time(nanoseconds: 2));
  expect(2.5.nanoseconds, Time(nanoseconds: 2.5));
}
