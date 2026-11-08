// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/time_machine2.dart';

import 'time_machine_testing.dart';

void main() {
  setUpAll(TimeMachineTest.initialize);

  test('GetCurrent', GetCurrent);
  test('Properties', Properties);
  test('InZone_NoCalendar', InZone_NoCalendar);
  test('InUtc', InUtc);
  test('InTzdbSystemDefaultZone', InTzdbSystemDefaultZone);
  test('CurrentDefaultsToSystemClock', CurrentDefaultsToSystemClock);
}

// ClockExtensionsTest

void InZone_NoCalendar() {
  var clock = FakeClock(TimeConstants.unixEpoch);
  var zoned = clock.inZone(SampleZone);
  expect(identical(zoned.clock, clock), isTrue);
  expect(identical(zoned.zone, SampleZone), isTrue);
  expect(identical(zoned.calendar, CalendarSystem.iso), isTrue);
}

void InUtc() {
  var clock = FakeClock(TimeConstants.unixEpoch);
  var zoned = clock.inUtc();
  expect(identical(zoned.clock, clock), isTrue);
  expect(identical(zoned.zone, DateTimeZone.utc), isTrue);
  expect(identical(zoned.calendar, CalendarSystem.iso), isTrue);
  expect(zoned.getCurrentLocalDateTime(), LocalDateTime(1970, 1, 1, 0, 0, 0));
}

Future InTzdbSystemDefaultZone() async {
  var clock = FakeClock(TimeConstants.unixEpoch);
  var zoned = await clock.inTzdbSystemDefaultZone();
  var expectedZone =
      await (await DateTimeZoneProviders.tzdb).getSystemDefault();
  expect(identical(zoned.clock, clock), isTrue);
  expect(zoned.zone, expectedZone);
  expect(identical(zoned.calendar, CalendarSystem.iso), isTrue);
}

void CurrentDefaultsToSystemClock() {
  expect(identical(Clock.current, SystemClock.instance), isTrue);
}

final DateTimeZone SampleZone =
    SingleTransitionDateTimeZone.hours(TimeConstants.unixEpoch, 1, 2);

void GetCurrent() {
  var julian = CalendarSystem.julian;
  FakeClock underlyingClock = FakeClock(TimeConstants.unixEpoch);
  ZonedClock zonedClock = underlyingClock.inZone(SampleZone, julian);
  expect(TimeConstants.unixEpoch, zonedClock.getCurrentInstant());
  expect(ZonedDateTime(underlyingClock.getCurrentInstant(), SampleZone, julian),
      zonedClock.getCurrentZonedDateTime());
  expect(LocalDateTime(1969, 12, 19, 2, 0, 0, calendar: julian),
      zonedClock.getCurrentLocalDateTime());
  expect(
      LocalDateTime(1969, 12, 19, 2, 0, 0, calendar: julian)
          .withOffset(Offset.hours(2)),
      zonedClock.getCurrentOffsetDateTime());
  expect(LocalDate(1969, 12, 19, julian), zonedClock.getCurrentDate());
  expect(LocalTime(2, 0, 0), zonedClock.getCurrentTimeOfDay());
}

void Properties() {
  var calendar = CalendarSystem.julian;
  var clock = FakeClock(TimeConstants.unixEpoch);
  var zonedClock = clock.inZone(SampleZone, calendar);
  expect(identical(zonedClock.clock, clock), isTrue);
  expect(identical(zonedClock.calendar, calendar), isTrue);
  expect(identical(zonedClock.zone, SampleZone), isTrue);
}
