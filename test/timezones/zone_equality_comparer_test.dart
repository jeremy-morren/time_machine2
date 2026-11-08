// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'dart:async';

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
import 'package:time_machine2/time_machine2.dart';

import '../time_machine_testing.dart';

void main() {
  setUpAll(TimeMachineTest.initialize);

  test('Various', Various);
  test('ElidedTransitions', ElidedTransitions);
  test('ForInterval', ForInterval);
  test('WithOptions', WithOptions);
  test('ElidedTransitions_Degenerate', ElidedTransitions_Degenerate);
  test('ReferenceComparison', ReferenceComparison);
  test('InvalidOptions', InvalidOptions);
  test('Options_Operators', Options_Operators);
  test('Options_ToStringAndParse', Options_ToStringAndParse);
  test('Options_Union', Options_Union);
}

void Options_Operators() {
  const names = ZoneEqualityComparerOptions.matchNames;
  const offsets = ZoneEqualityComparerOptions.matchOffsetComponents;
  expect(offsets < names, isTrue);
  expect(names < offsets, isFalse);
  expect(names <= names, isTrue);
  expect(names <= offsets, isFalse);
  expect(names > offsets, isTrue);
  expect(offsets > names, isFalse);
  expect(names >= names, isTrue);
  expect(offsets >= names, isFalse);
  expect(names - offsets, 1);
  expect(names + offsets, 3);
  expect(names | offsets, const ZoneEqualityComparerOptions(3));
  expect(names | 1, const ZoneEqualityComparerOptions(3));
  expect(ZoneEqualityComparerOptions.strictestMatch & names, names);
  expect(ZoneEqualityComparerOptions.strictestMatch & 2, names);
  expect(() => names | 'x', throwsArgumentError);
  expect(() => names & 'x', throwsArgumentError);
  expect(~names, ~2);
  // An option is also equal to its numeric value.
  // ignore: unrelated_type_equality_checks
  expect(names == 2, isTrue);
}

void Options_ToStringAndParse() {
  const all = [
    ZoneEqualityComparerOptions.onlyMatchWallOffset,
    ZoneEqualityComparerOptions.matchOffsetComponents,
    ZoneEqualityComparerOptions.matchNames,
    ZoneEqualityComparerOptions.matchAllTransitions,
    ZoneEqualityComparerOptions.matchStartAndEndTransitions,
    ZoneEqualityComparerOptions.strictestMatch,
  ];
  const names = [
    'OnlyMatchWallOffset',
    'MatchOffsetComponents',
    'MatchNames',
    'MatchAllTransitions',
    'MatchStartAndEndTransitions',
    'StrictestMatch',
  ];
  for (int i = 0; i < all.length; i++) {
    expect(all[i].toString(), names[i]);
    expect(all[i].parse(names[i].toUpperCase()), all[i]);
  }
  expect(
      (ZoneEqualityComparerOptions.matchNames |
              ZoneEqualityComparerOptions.matchAllTransitions)
          .toString(),
      'undefined');
  expect(
      ZoneEqualityComparerOptions.matchNames.parse('MatchEverything'), isNull);
}

void Options_Union() {
  expect(ZoneEqualityComparerOptions.union(const []),
      ZoneEqualityComparerOptions.onlyMatchWallOffset);
  expect(
      ZoneEqualityComparerOptions.union(const [
        ZoneEqualityComparerOptions.matchOffsetComponents,
        ZoneEqualityComparerOptions.matchNames,
        ZoneEqualityComparerOptions.matchAllTransitions,
        ZoneEqualityComparerOptions.matchStartAndEndTransitions,
      ]),
      ZoneEqualityComparerOptions.strictestMatch);
}

// Sample instants for use in tests. They're on January 1st 2000...2009, midnight UTC.
List<Instant> Instants = (Iterable.generate(10, (i) => (i + 2000)))
    .map((year) => Instant.utc(year, 1, 1, 0, 0))
    .toList(growable: false);

// Various tests using a pair of zones which can demonstrate a number of
// different features.
void Various() {
  // Names, some offsets, and first transition are all different.
  var zone1 = (MultiTransitionDateTimeZoneBuilder()
        ..add(Instants[0], 1, 0, 'xx')
        ..add(Instants[2], 3, 0, '1b')
        ..add(Instants[4], 2, 1, '1c')
        ..add(Instants[6], 4, 0, '1d'))
      .build();

  var zone2 = (MultiTransitionDateTimeZoneBuilder()
        ..add(Instants[1], 1, 0, 'xx')
        ..add(Instants[2], 3, 0, '2b')
        ..add(Instants[4], 1, 2, '2c')
        ..add(Instants[6], 5, 0, '2d'))
      .build();

  // Even though the first transition point is different, by default that's fine if
  // the start point is 'inside' both.
  AssertEqual(zone1, zone2, Instants[1], Instants[5],
      ZoneEqualityComparerOptions.onlyMatchWallOffset);
  // When we extend backwards a bit, we can see the difference between the two.
  AssertNotEqual(zone1, zone2, Instants[1] - Time.epsilon, Instants[5],
      ZoneEqualityComparerOptions.onlyMatchWallOffset);
  // Or if we force the start and end transitions to be exact...
  AssertNotEqual(zone1, zone2, Instants[1], Instants[5],
      ZoneEqualityComparerOptions.matchStartAndEndTransitions);

  // The first two transitions have the same split between standard and saving...
  AssertEqual(zone1, zone2, Instants[1], Instants[4],
      ZoneEqualityComparerOptions.matchOffsetComponents);
  // The third one (at Instants[4]) doesn't...
  AssertNotEqual(zone1, zone2, Instants[1], Instants[5],
      ZoneEqualityComparerOptions.matchOffsetComponents);

  // The first transition has the same name for the zone interval...
  AssertEqual(zone1, zone2, Instants[1], Instants[2],
      ZoneEqualityComparerOptions.matchNames);
  // The second transition (at Instants[2]) doesn't...
  AssertNotEqual(zone1, zone2, Instants[1], Instants[3],
      ZoneEqualityComparerOptions.matchNames);
}

void ElidedTransitions() {
  var zone1 = (MultiTransitionDateTimeZoneBuilder()
        ..add(Instants[3], 0, 0, 'a')
        ..add(Instants[4], 1, 2, 'b')
        ..add(Instants[5], 2, 1, 'b')
        ..add(Instants[6], 1, 0, 'd')
        ..add(Instants[7], 1, 0, 'e')
        ..add(Instants[8], 0, 0, 'x'))
      .build();

  var zone2 = (MultiTransitionDateTimeZoneBuilder()
        ..add(Instants[3], 0, 0, 'a')
        ..add(Instants[4], 3, 0, 'b')
        // Instants[5] isn't included here: wall offset is the same; components change in zone1
        ..add(Instants[6], 1, 0, 'd')
        // Instants[7] isn't included here: offset components are the same; names change in zone1
        ..add(Instants[8], 0, 0, 'x'))
      .build();

  AssertEqual(zone1, zone2, Instant.minValue, Instant.maxValue,
      ZoneEqualityComparerOptions.onlyMatchWallOffset);
  // BOT-Instants[6] will elide transitions when ignoring components, even if we match names
  AssertEqual(zone1, zone2, Instant.minValue, Instants[6],
      ZoneEqualityComparerOptions.matchNames);
  AssertNotEqual(zone1, zone2, Instant.minValue, Instants[6],
      ZoneEqualityComparerOptions.matchOffsetComponents);
  // Instants[6]-EOT will elide transitions when ignoring names, even if we match components
  AssertEqual(zone1, zone2, Instants[6], Instant.maxValue,
      ZoneEqualityComparerOptions.matchOffsetComponents);
  AssertNotEqual(zone1, zone2, Instants[6], Instant.maxValue,
      ZoneEqualityComparerOptions.matchNames);

  // But if we require the exact transitions, both fail
  AssertNotEqual(zone1, zone2, Instant.minValue, Instants[6],
      ZoneEqualityComparerOptions.matchAllTransitions);
  AssertNotEqual(zone1, zone2, Instants[6], Instant.maxValue,
      ZoneEqualityComparerOptions.matchAllTransitions);
}

void ForInterval() {
  var interval = Interval(Instants[3], Instants[5]);
  var comparer = ZoneEqualityComparer.forInterval(interval);
  expect(ZoneEqualityComparerOptions.onlyMatchWallOffset,
      IZoneEqualityComparer.optionsForTest(comparer));
  expect(interval, IZoneEqualityComparer.intervalForTest(comparer));
}

void WithOptions() {
  var interval = Interval(Instants[3], Instants[5]);
  var firstComparer = ZoneEqualityComparer.forInterval(interval);
  var secondComparer =
      firstComparer.withOptions(ZoneEqualityComparerOptions.matchNames);

  expect(ZoneEqualityComparerOptions.matchNames,
      IZoneEqualityComparer.optionsForTest(secondComparer));
  expect(interval, IZoneEqualityComparer.intervalForTest(secondComparer));

  // Validate that the first comparer hasn't changed
  expect(ZoneEqualityComparerOptions.onlyMatchWallOffset,
      IZoneEqualityComparer.optionsForTest(firstComparer));
  expect(interval, IZoneEqualityComparer.intervalForTest(firstComparer));
}

void ElidedTransitions_Degenerate() {
  // Transitions with *nothing* that we care about. (Normally
  // these wouldn't even be generated, but we could imagine some
  // sort of zone interval in the future which had another property...)
  var zone1 = (MultiTransitionDateTimeZoneBuilder()
        ..add(Instants[3], 1, 0, 'a')
        ..add(Instants[4], 1, 0, 'a')
        ..add(Instants[5], 1, 0, 'a')
        ..add(Instants[6], 0))
      .build();
  var zone2 = (MultiTransitionDateTimeZoneBuilder()
        ..add(Instants[3], 1, 0, 'a')
        ..add(Instants[6], 0))
      .build();

  // We can match *everything* except exact transitions...
  var match = ZoneEqualityComparerOptions.matchNames |
      ZoneEqualityComparerOptions.matchOffsetComponents |
      ZoneEqualityComparerOptions.matchStartAndEndTransitions;
  AssertEqual(zone1, zone2, Instant.minValue, Instant.maxValue, match);
  // But not the exact transitions...
  AssertNotEqual(zone1, zone2, Instant.minValue, Instant.maxValue,
      ZoneEqualityComparerOptions.matchAllTransitions);
}

Future ReferenceComparison() async {
  var comparer =
      ZoneEqualityComparer.forInterval(Interval(Instants[0], Instants[2]));
  var zone = await DateTimeZoneProviders.defaultProvider?['Europe/London'];
  expect(comparer.equals(zone!, zone), isTrue);
}

void InvalidOptions() {
  var comparer =
      ZoneEqualityComparer.forInterval(Interval(Instants[0], Instants[2]));
  expect(() => comparer.withOptions(const ZoneEqualityComparerOptions(9999)),
      throwsArgumentError);
}

void AssertEqual(DateTimeZone first, DateTimeZone second, Instant start,
    Instant end, ZoneEqualityComparerOptions options) {
  var comparer = ZoneEqualityComparer.forInterval(Interval(start, end))
      .withOptions(options);
  expect(comparer.equals(first, second), isTrue);
  expect(comparer.getHashCode(first), comparer.getHashCode(second));
}

void AssertNotEqual(DateTimeZone first, DateTimeZone second, Instant start,
    Instant end, ZoneEqualityComparerOptions options) {
  var comparer = ZoneEqualityComparer.forInterval(Interval(start, end))
      .withOptions(options);
  expect(comparer.equals(first, second), isFalse);
  // If this fails, the code *could* still be correct - but it's unlikely...
  expect(comparer.getHashCode(first), isNot(comparer.getHashCode(second)));
}
