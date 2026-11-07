// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2011 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Port of Noda Time's NodaTime.Test/Testing/FakeClockTest.cs: tests for the
// FakeClock class in the testing library. Noda Time's ticks (100ns) are
// microseconds here, as Time Machine has no ticks; AdvanceTicks is
// AdvanceMicroseconds.
import 'package:test/test.dart';
import 'package:time_machine2/testing.dart';
import 'package:time_machine2/time_machine2.dart';

void main() {
  test('DirectConstruction', DirectConstruction);
  test('ConstructionWithAdvance', ConstructionWithAdvance);
  test('ConstructionThenAdvance', ConstructionThenAdvance);
  test('UtcDateConstruction', UtcDateConstruction);
  test('UtcDateTimeConstruction', UtcDateTimeConstruction);
  test('Advance', Advance);
  test('AdvanceNanoseconds', AdvanceNanoseconds);
  test('AdvanceMicroseconds', AdvanceMicroseconds);
  test('AdvanceMilliseconds', AdvanceMilliseconds);
  test('AdvanceSeconds', AdvanceSeconds);
  test('AdvanceMinutes', AdvanceMinutes);
  test('AdvanceHours', AdvanceHours);
  test('AdvanceDays', AdvanceDays);
  test('Reset', Reset);
}

void DirectConstruction() {
  var instant = Instant.fromEpochMicroseconds(100);
  var clock = FakeClock(instant);
  expect(clock.getCurrentInstant(), instant);
}

void ConstructionWithAdvance() {
  var instant = Instant.fromEpochMicroseconds(100);
  var advance = Time(microseconds: 5);
  var clock = FakeClock(instant, advance);
  expect(clock.autoAdvance, advance);
  expect(clock.getCurrentInstant(), instant);
  expect(clock.getCurrentInstant(), instant + advance);
  expect(clock.getCurrentInstant(), instant + advance + advance);
}

void ConstructionThenAdvance() {
  var instant = Instant.fromEpochMicroseconds(100);
  var clock = FakeClock(instant);
  expect(clock.getCurrentInstant(), instant);
  expect(clock.getCurrentInstant(), instant);
  var advance = Time(microseconds: 5);
  clock.autoAdvance = advance;
  // Setting auto-advance doesn't actually change the clock...
  // but this call will.
  expect(clock.getCurrentInstant(), instant);
  expect(clock.getCurrentInstant(), instant + advance);
  expect(clock.getCurrentInstant(), instant + advance + advance);
}

void UtcDateConstruction() {
  var instant = Instant.utc(2010, 1, 1, 0, 0);
  var clock = FakeClock.fromUtc(2010, 1, 1);
  expect(clock.getCurrentInstant(), instant);
}

void UtcDateTimeConstruction() {
  var instant = Instant.utc(2010, 1, 1, 10, 30, 25);
  var clock = FakeClock.fromUtc(2010, 1, 1, 10, 30, 25);
  expect(clock.getCurrentInstant(), instant);
}

void Advance() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  var d = Time(microseconds: 25);
  clock.advance(d);
  expect(clock.getCurrentInstant().epochMicroseconds, 125);
}

void AdvanceNanoseconds() {
  var clock = FakeClock(Instant.fromEpochSeconds(1));
  clock.advanceNanoseconds(3);
  expect(clock.getCurrentInstant().epochNanoseconds, 1000000003);
}

/// Noda Time's AdvanceTicks.
void AdvanceMicroseconds() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  clock.advanceMicroseconds(3);
  expect(clock.getCurrentInstant().epochMicroseconds, 103);
}

void AdvanceMilliseconds() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  clock.advanceMilliseconds(3);
  expect(clock.getCurrentInstant().epochMicroseconds,
      100 + 3 * TimeConstants.microsecondsPerMillisecond);
}

void AdvanceSeconds() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  clock.advanceSeconds(3);
  expect(clock.getCurrentInstant().epochMicroseconds,
      100 + 3 * TimeConstants.microsecondsPerSecond);
}

void AdvanceMinutes() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  clock.advanceMinutes(3);
  expect(clock.getCurrentInstant().epochMicroseconds,
      100 + 3 * TimeConstants.microsecondsPerMinute);
}

void AdvanceHours() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  clock.advanceHours(3);
  expect(clock.getCurrentInstant().epochMicroseconds,
      100 + 3 * TimeConstants.microsecondsPerHour);
}

void AdvanceDays() {
  var clock = FakeClock(Instant.fromEpochMicroseconds(100));
  clock.advanceDays(3);
  expect(clock.getCurrentInstant().epochMicroseconds,
      100 + 3 * TimeConstants.microsecondsPerDay);
}

void Reset() {
  var instant1 = Instant.fromEpochMicroseconds(100);
  var instant2 = Instant.fromEpochMicroseconds(500);
  var clock = FakeClock(instant1);
  expect(clock.getCurrentInstant(), instant1);
  clock.reset(instant2);
  expect(clock.getCurrentInstant(), instant2);
}
