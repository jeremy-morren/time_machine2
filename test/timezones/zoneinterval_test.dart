// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:test/test.dart';

import '../time_machine_testing.dart';

void main() {
  test('PassthroughProperties', PassthroughProperties);
  test('ComputedProperties', ComputedProperties);
  test('Contains_Instant_Normal', Contains_Instant_Normal);
  test('Contains_Instant_WholeOfTime_ViaNullity',
      Contains_Instant_WholeOfTime_ViaNullity);
  test('Contains_Instant_WholeOfTime_ViaSpecialInstants',
      Contains_Instant_WholeOfTime_ViaSpecialInstants);
  test('Contains_LocalInstant_WholeOfTime', Contains_LocalInstant_WholeOfTime);
  test('Contains_OutsideLocalInstantange', Contains_OutsideLocalInstantange);
  test('IsoLocalStartAndEnd_Infinite', IsoLocalStartAndEnd_Infinite);
  test('IsoLocalStartAndEnd_OutOfRange', IsoLocalStartAndEnd_OutOfRange);
  test('Equality', Equality);
  test('EqualityOperators', EqualityOperators);
  test('ZoneIntervalToString', ZoneIntervalToString);
}

final Instant SampleStart = Instant.utc(2011, 6, 3, 10, 15);
final Instant SampleEnd = Instant.utc(2011, 8, 2, 13, 45);

final ZoneInterval SampleInterval = IZoneInterval.newZoneInterval(
    'TestTime', SampleStart, SampleEnd, Offset.hours(9), Offset.hours(1));

void PassthroughProperties() {
  expect('TestTime', SampleInterval.name);
  expect(Offset.hours(8), SampleInterval.standardOffset);
  expect(Offset.hours(1), SampleInterval.savings);
  expect(Offset.hours(9), SampleInterval.wallOffset);
  expect(SampleStart, SampleInterval.start);
  expect(SampleEnd, SampleInterval.end);
}

// Having one test per property feels like a waste of time to me (Jon)...
// If any of them fail, I'm going to be looking here anyway, and they're
// fairly interrelated anyway.
void ComputedProperties() {
  LocalDateTime start = LocalDateTime(2011, 6, 3, 19, 15, 0);
  LocalDateTime end = LocalDateTime(2011, 8, 2, 22, 45, 0);
  expect(start, SampleInterval.isoLocalStart);
  expect(end, SampleInterval.isoLocalEnd);
  expect(SampleStart.timeUntil(SampleEnd), SampleInterval.totalTime);
}

void Contains_Instant_Normal() {
  expect(SampleInterval.contains(SampleStart), isTrue);
  expect(SampleInterval.contains(SampleEnd), isFalse);
  expect(SampleInterval.contains(Instant.minValue), isFalse);
  expect(SampleInterval.contains(Instant.maxValue), isFalse);
}

void Contains_Instant_WholeOfTime_ViaNullity() {
  ZoneInterval interval = IZoneInterval.newZoneInterval(
      'All Time', null, null, Offset.hours(9), Offset.hours(1));
  expect(interval.contains(SampleStart), isTrue);
  expect(interval.contains(Instant.minValue), isTrue);
  expect(interval.contains(Instant.maxValue), isTrue);
}

void Contains_Instant_WholeOfTime_ViaSpecialInstants() {
  ZoneInterval interval = IZoneInterval.newZoneInterval(
      'All Time',
      IInstant.beforeMinValue,
      IInstant.afterMaxValue,
      Offset.hours(9),
      Offset.hours(1));
  expect(interval.contains(SampleStart), isTrue);
  expect(interval.contains(Instant.minValue), isTrue);
  expect(interval.contains(Instant.maxValue), isTrue);
}

void Contains_LocalInstant_WholeOfTime() {
  ZoneInterval interval = IZoneInterval.newZoneInterval(
      'All Time',
      IInstant.beforeMinValue,
      IInstant.afterMaxValue,
      Offset.hours(9),
      Offset.hours(1));
  expect(
      IZoneInterval.containsLocal(
          interval, IInstant.plusOffset(SampleStart, Offset.zero)),
      isTrue);
  expect(
      IZoneInterval.containsLocal(
          interval, IInstant.plusOffset(Instant.minValue, Offset.zero)),
      isTrue);
  expect(
      IZoneInterval.containsLocal(
          interval, IInstant.plusOffset(Instant.maxValue, Offset.zero)),
      isTrue);
}

void Contains_OutsideLocalInstantange() {
  ZoneInterval veryEarly = IZoneInterval.newZoneInterval(
      'Very early',
      IInstant.beforeMinValue,
      Instant.minValue + Time(hours: 8),
      Offset.hours(-9),
      Offset.zero);
  ZoneInterval veryLate = IZoneInterval.newZoneInterval(
      'Very late',
      Instant.maxValue - Time(hours: 8),
      IInstant.afterMaxValue,
      Offset.hours(9),
      Offset.zero);
  // The instants are contained...
  expect(veryEarly.contains(Instant.minValue + Time(hours: 4)), isTrue);
  expect(veryLate.contains(Instant.maxValue - Time(hours: 4)), isTrue);
  // But there are no valid local instants
  expect(
      IZoneInterval.containsLocal(
          veryEarly, IInstant.plusOffset(Instant.minValue, Offset.zero)),
      isFalse);
  expect(
      IZoneInterval.containsLocal(
          veryLate, IInstant.plusOffset(Instant.maxValue, Offset.zero)),
      isFalse);
}

void IsoLocalStartAndEnd_Infinite() {
  var interval = IZoneInterval.newZoneInterval(
      'All time', null, null, Offset.zero, Offset.zero);
  // Assert.Throws<InvalidOperationException>
  expect(() => interval.isoLocalStart.toString(), throwsStateError);
  expect(() => interval.isoLocalEnd.toString(), throwsStateError);
}

void IsoLocalStartAndEnd_OutOfRange() {
  var interval = IZoneInterval.newZoneInterval(
      'All time', Instant.minValue, null, Offset.hours(-1), Offset.zero);
  // Assert.Throws<OverflowException>
  expect(() => interval.isoLocalStart.toString(), throwsRangeError);
  interval = IZoneInterval.newZoneInterval(
      'All time', null, Instant.maxValue, Offset.hours(11), Offset.zero);
  expect(() => interval.isoLocalEnd.toString(), throwsRangeError);
}

void Equality() {
  TestHelper.TestEqualsClass(
      // Equal values
      IZoneInterval.newZoneInterval(
          'name', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(2)),
      IZoneInterval.newZoneInterval(
          'name', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(2)),
      // Unequal values
      [
        IZoneInterval.newZoneInterval(
            'name2', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(2)),
        IZoneInterval.newZoneInterval('name', SampleStart.add(Time.epsilon),
            SampleEnd, Offset.hours(1), Offset.hours(2)),
        IZoneInterval.newZoneInterval('name', SampleStart,
            SampleEnd.add(Time.epsilon), Offset.hours(1), Offset.hours(2)),
        IZoneInterval.newZoneInterval(
            'name', SampleStart, SampleEnd, Offset.hours(2), Offset.hours(2)),
        IZoneInterval.newZoneInterval(
            'name', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(3))
      ]);
}

void EqualityOperators() {
  ZoneInterval val1 = IZoneInterval.newZoneInterval(
      'name', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(2));
  ZoneInterval val2 = IZoneInterval.newZoneInterval(
      'name', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(2));
  ZoneInterval val3 = IZoneInterval.newZoneInterval(
      'name2', SampleStart, SampleEnd, Offset.hours(1), Offset.hours(2));
  // (Not a literal null, which the analyzer would know is null.)
  ZoneInterval? val4 = _noZoneInterval();

  expect(val1 == val2, isTrue);
  expect(val1 == val3, isFalse);
  expect(val1 == val4, isFalse);
  expect(val4 == val1, isFalse);
  expect(val4 == null, isTrue);
  expect(null == val4, isTrue);

  expect(val1 != val2, isFalse);
  expect(val1 != val3, isTrue);
  expect(val1 != val4, isTrue);
  expect(val4 != val1, isTrue);
  expect(val4 != null, isFalse);
  expect(null != val4, isFalse);
}

ZoneInterval? _noZoneInterval() => null;

void ZoneIntervalToString() {
  // Noda Time sets the invariant culture; Time Machine's toString() doesn't
  // depend on the culture.
  expect(SampleInterval.toString(),
      'TestTime: [2011-06-03T10:15:00Z, 2011-08-02T13:45:00Z) +09 (+01)');
}
