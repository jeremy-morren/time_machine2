// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Tests for SingleTransitionDateTimeZone. Noda Time has no tests of its own
// for this class (it's exercised by other tests, as it is here too); these
// check the behaviour of NodaTime.Testing.TimeZones.SingleTransitionDateTimeZone.
import 'package:test/test.dart';
import 'package:time_machine2/testing.dart';
import 'package:time_machine2/time_machine2.dart';

void main() {
  test('Construction', Construction);
  test('Construction_Hours', Construction_Hours);
  test('GetZoneInterval', GetZoneInterval);
  test('MapLocal', MapLocal);
}

final Instant _transition = Instant.utc(2000, 1, 1, 0, 0);

void Construction() {
  var zone = SingleTransitionDateTimeZone(
      _transition, Offset.hours(3), Offset.hours(-2), 'Custom');
  expect(zone.id, 'Custom');
  expect(zone.transition, _transition);
  expect(zone.minOffset, Offset.hours(-2));
  expect(zone.maxOffset, Offset.hours(3));

  var early = zone.earlyInterval;
  expect(early.name, 'Custom-Early');
  expect(early.hasStart, isFalse);
  expect(early.end, _transition);
  expect(early.wallOffset, Offset.hours(3));
  expect(early.savings, Offset.zero);

  var late = zone.lateInterval;
  expect(late.name, 'Custom-Late');
  expect(late.start, _transition);
  expect(late.hasEnd, isFalse);
  expect(late.wallOffset, Offset.hours(-2));
  expect(late.savings, Offset.zero);
}

void Construction_Hours() {
  var zone = SingleTransitionDateTimeZone.hours(_transition, -3, 4);
  expect(zone.id, 'Single');
  expect(zone.transition, _transition);
  expect(zone.earlyInterval.name, 'Single-Early');
  expect(zone.earlyInterval.wallOffset, Offset.hours(-3));
  expect(zone.lateInterval.name, 'Single-Late');
  expect(zone.lateInterval.wallOffset, Offset.hours(4));
}

void GetZoneInterval() {
  var zone = SingleTransitionDateTimeZone.hours(_transition, -3, 4);
  expect(zone.getZoneInterval(Instant.minValue), same(zone.earlyInterval));
  expect(zone.getZoneInterval(_transition - Time.epsilon),
      same(zone.earlyInterval));
  expect(zone.getZoneInterval(_transition), same(zone.lateInterval));
  expect(zone.getZoneInterval(Instant.maxValue), same(zone.lateInterval));
  expect(
      zone.getZoneIntervalsFromTo(Instant.minValue, Instant.maxValue).toList(),
      [zone.earlyInterval, zone.lateInterval]);
}

void MapLocal() {
  // From UTC-3 to UTC+4: a 7 hour gap from 21:00 to 04:00 local time.
  var zone = SingleTransitionDateTimeZone.hours(_transition, -3, 4);
  expect(zone.mapLocal(LocalDateTime(1999, 12, 31, 20, 59, 0)).count, 1);
  expect(zone.mapLocal(LocalDateTime(1999, 12, 31, 21, 0, 0)).count, 0);
  expect(zone.mapLocal(LocalDateTime(2000, 1, 1, 3, 59, 0)).count, 0);
  expect(zone.mapLocal(LocalDateTime(2000, 1, 1, 4, 0, 0)).count, 1);

  // From UTC+4 to UTC-3: a 7 hour overlap from 21:00 to 04:00 local time.
  zone = SingleTransitionDateTimeZone.hours(_transition, 4, -3);
  expect(zone.mapLocal(LocalDateTime(1999, 12, 31, 20, 59, 0)).count, 1);
  expect(zone.mapLocal(LocalDateTime(1999, 12, 31, 21, 0, 0)).count, 2);
  expect(zone.mapLocal(LocalDateTime(2000, 1, 1, 3, 59, 0)).count, 2);
  expect(zone.mapLocal(LocalDateTime(2000, 1, 1, 4, 0, 0)).count, 1);
}
