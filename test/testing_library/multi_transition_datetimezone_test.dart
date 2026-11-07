// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2013 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Port of Noda Time's NodaTime.Test/Testing/TimeZones/MultiTransitionDateTimeZoneTest.cs.
// Test as much to demonstrate a couple of extremes of building as much as
// anything else...
//
// Noda Time's ticks are microseconds here. BuilderGetEnumerator_Throws isn't
// ported: the Dart builder isn't iterable (Noda Time's is IEnumerable only so
// it can use collection initializers), so Dart uses cascades instead.
import 'package:test/test.dart';
import 'package:time_machine2/testing.dart';
import 'package:time_machine2/time_machine2.dart';
// Internal: ZoneInterval has no public constructor, and the raw start/end and
// the instants before/after the time line aren't public.
import 'package:time_machine2/src/time_machine_internal.dart'
    show IInstant, IZoneInterval;

void main() {
  test('SimpleBuilding', SimpleBuilding);
  test('Transitions', Transitions);
  test('ComplexBuilding', ComplexBuilding);
  test('BuildTwice', BuildTwice);
  test('AddAfterBuild', AddAfterBuild);
  test('Id', Id);
  test('NoTransitions', NoTransitions);
}

final Instant _transition1 = Instant.fromEpochMicroseconds(0);
final Instant _transition2 = Instant.fromEpochMicroseconds(100000);

void SimpleBuilding() {
  var zone = (MultiTransitionDateTimeZoneBuilder()
        ..add(_transition1, 5)
        ..add(_transition2, 3))
      .build();
  var intervals = zone
      .getZoneIntervalsFromTo(
          _transition1 - Time.epsilon, _transition2 + Time.epsilon)
      .toList();
  expect(intervals.length, 3);
  expect(intervals[0].wallOffset, Offset.zero);
  expect(IZoneInterval.rawStart(intervals[0]), IInstant.beforeMinValue);
  expect(intervals[0].end, _transition1);

  expect(intervals[1].wallOffset, Offset.hours(5));
  expect(intervals[1].start, _transition1);
  expect(intervals[1].end, _transition2);

  expect(intervals[2].wallOffset, Offset.hours(3));
  expect(intervals[2].start, _transition2);
  expect(IZoneInterval.rawEnd(intervals[2]), IInstant.afterMaxValue);
}

void Transitions() {
  var zone = (MultiTransitionDateTimeZoneBuilder()
        ..add(_transition1, 5)
        ..add(_transition2, 3))
      .build();
  expect(zone.transitions, [_transition1, _transition2]);
}

void ComplexBuilding() {
  var zone = (MultiTransitionDateTimeZoneBuilder(2, 1, 'X')
        ..add(_transition1, 2, 0, 'Y')
        ..add(_transition2, 1, 1, 'Z'))
      .build();
  var actual = zone
      .getZoneIntervalsFromTo(
          _transition1 - Time.epsilon, _transition2 + Time.epsilon)
      .toList();
  // ZoneInterval uses wall offset and savings...
  var expected = [
    IZoneInterval.newZoneInterval('X', IInstant.beforeMinValue, _transition1,
        Offset.hours(3), Offset.hours(1)),
    IZoneInterval.newZoneInterval(
        'Y', _transition1, _transition2, Offset.hours(2), Offset.hours(0)),
    IZoneInterval.newZoneInterval('Z', _transition2, IInstant.afterMaxValue,
        Offset.hours(2), Offset.hours(1)),
  ];
  expect(actual, expected);
  expect(zone.intervals, expected);
}

void BuildTwice() {
  var builder = MultiTransitionDateTimeZoneBuilder();
  builder.build();
  expect(builder.build, throwsStateError);
}

/// Not in Noda Time: a builder can't be added to after it's built either.
void AddAfterBuild() {
  var builder = MultiTransitionDateTimeZoneBuilder();
  builder.build();
  expect(() => builder.add(_transition1, 1), throwsStateError);
}

/// Not in Noda Time: the ID is "MultiZone" unless the builder sets it; the
/// generated interval names, the minimum and maximum offsets.
void Id() {
  expect(MultiTransitionDateTimeZoneBuilder().build().id, 'MultiZone');
  var zone = (MultiTransitionDateTimeZoneBuilder.withName(-1, 'First')
        ..id = 'Custom'
        ..add(_transition1, 4))
      .build();
  expect(zone.id, 'Custom');
  expect(zone.intervals.map((x) => x.name),
      ['First', 'Interval from $_transition1']);
  expect(zone.minOffset, Offset.hours(-1));
  expect(zone.maxOffset, Offset.hours(4));
}

/// Not in Noda Time: a builder with no transitions builds a zone with a single
/// interval covering the whole time line.
void NoTransitions() {
  var zone = MultiTransitionDateTimeZoneBuilder(2, 1).build();
  expect(zone.transitions, isEmpty);
  expect(zone.intervals, [
    IZoneInterval.newZoneInterval(
        'First', null, null, Offset.hours(3), Offset.hours(1))
  ]);
  expect(zone.getUtcOffset(Instant.minValue), Offset.hours(3));
  expect(zone.getUtcOffset(Instant.maxValue), Offset.hours(3));
}
