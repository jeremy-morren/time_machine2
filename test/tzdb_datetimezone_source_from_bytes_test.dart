// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2012 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Tests of TzdbDateTimeZoneSource.fromBytes, Noda Time's
// TzdbDateTimeZoneSource.FromStream. These read lib/data/tzdb/tzdb.bin (the
// data embedded in Time Machine) with dart:io, so they only run on the VM.
// FromBytes_LoadAndExercise is based on Noda Time's
// CanLoadNodaTimeResourceFromOnePointOneRelease (which loads a Noda Time 1.1
// resource, in a format Time Machine doesn't read).
@TestOn('vm')
library;

import 'dart:io' as io;
import 'dart:typed_data';

import 'package:archive/archive.dart' show XZDecoder;
import 'package:test/test.dart';
import 'package:time_machine2/time_machine2.dart';

import 'time_machine_testing.dart';

void main() {
  // This runs first, before Time Machine is initialized, to show the loaded
  // source doesn't need TimeMachine.initialize().
  test('FromBytes_LoadAndExercise', FromBytes_LoadAndExercise);
  test('FromBytes_InvalidData', FromBytes_InvalidData);

  group('Compared with the default source', () {
    setUpAll(TimeMachineTest.initialize);

    test('FromBytes_Compressed',
        () => _assertSameAsDefault(TzdbDateTimeZoneSource.fromBytes(_tzdbBin)));
    test(
        'FromBytes_Decompressed',
        () => _assertSameAsDefault(TzdbDateTimeZoneSource.fromBytes(
            XZDecoder().decodeBytes(_tzdbBin, verify: true))));
  });
}

final Uint8List _tzdbBin = io.File('lib/data/tzdb/tzdb.bin').readAsBytesSync();

Future FromBytes_LoadAndExercise() async {
  var source = TzdbDateTimeZoneSource.fromBytes(_tzdbBin);
  expect(source.versionId, startsWith('TZDB: 20'));
  source.validate();

  var utc = Instant.utc(2007, 8, 24, 9, 30, 0);

  // Test a regular zone with rules.
  var london = await source.forId('Europe/London');
  var inLondon = ZonedDateTime(utc, london);
  var expectedLocal = LocalDateTime(2007, 8, 24, 10, 30, 0);
  expect(inLondon.localDateTime, expectedLocal);

  // Test a fixed-offset zone.
  var utcFixed = await source.forId('Etc/UTC');
  var inUtcFixed = ZonedDateTime(utc, utcFixed);
  expectedLocal = LocalDateTime(2007, 8, 24, 9, 30, 0);
  expect(inUtcFixed.localDateTime, expectedLocal);

  // Test an alias.
  var japan = await source.forId('Japan'); // Asia/Tokyo
  var inJapan = ZonedDateTime(utc, japan);
  expectedLocal = LocalDateTime(2007, 8, 24, 18, 30, 0);
  expect(inJapan.localDateTime, expectedLocal);
  expect(source.canonicalIdMap['Japan'], 'Asia/Tokyo');

  // Test ZoneLocations.
  var france =
      source.zoneLocations!.singleWhere((g) => g.countryName == 'France');
  // Tolerance of about 2 seconds
  expect(france.latitude, closeTo(48.86666, 0.00055));
  expect(france.longitude, closeTo(2.3333, 0.00055));
  expect(france.zoneId, 'Europe/Paris');
  expect(france.countryCode, 'FR');
  expect(france.comment, '');

  // And a provider for the source.
  var provider = await DateTimeZoneCache.getCache(source);
  expect(provider.versionId, source.versionId);
  expect((await provider['Europe/London']).getUtcOffset(utc), Offset.hours(1));
}

void FromBytes_InvalidData() {
  var decompressed = XZDecoder().decodeBytes(_tzdbBin, verify: true);
  for (var data in [
    <int>[],
    [1, 2, 3, 4, 5],
    // Truncated XZ data.
    _tzdbBin.sublist(0, _tzdbBin.length ~/ 2),
    // Truncated data.
    decompressed.sublist(0, decompressed.length ~/ 2),
  ]) {
    expect(() => TzdbDateTimeZoneSource.fromBytes(data),
        throwsA(isA<InvalidTimeDataError>()),
        reason: 'Data of length ${data.length}');
  }
}

Future _assertSameAsDefault(TzdbDateTimeZoneSource loaded) async {
  var defaultSource = TzdbDateTimeZoneSource.defaultSource;
  expect(loaded, isNot(same(defaultSource)));
  expect(loaded.versionId, defaultSource.versionId);
  expect(loaded.tzdbVersion, defaultSource.tzdbVersion);
  expect(loaded.canonicalIdMap, defaultSource.canonicalIdMap);
  expect(loaded.aliases, defaultSource.aliases);
  expect(loaded.windowsMapping.version, defaultSource.windowsMapping.version);
  expect(loaded.windowsToTzdbIds, defaultSource.windowsToTzdbIds);
  expect(loaded.tzdbToWindowsIds, defaultSource.tzdbToWindowsIds);
  expect(loaded.zoneLocations!.length, defaultSource.zoneLocations!.length);
  expect(loaded.zone1970Locations!.length,
      defaultSource.zone1970Locations!.length);
  loaded.validate();

  var ids = (await loaded.getIds()).toList();
  expect(ids, unorderedEquals(await defaultSource.getIds()));

  var comparer = ZoneEqualityComparer.forInterval(Interval(
          Instant.utc(1800, 1, 1, 0, 0), Instant.utc(2100, 1, 1, 0, 0)))
      .withOptions(ZoneEqualityComparerOptions.strictestMatch);
  var different = <String>[];
  for (var id in ids) {
    var loadedZone = await loaded.forId(id);
    var defaultZone = await defaultSource.forId(id);
    expect(loadedZone.id, id);
    if (!comparer.equals(loadedZone, defaultZone)) {
      different.add(id);
    }
  }
  expect(different, isEmpty);
}
