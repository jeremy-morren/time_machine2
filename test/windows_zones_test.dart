// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:time_machine2/time_machine2.dart';
import 'package:time_machine2/src/platforms/windows_time_zone.dart';
import 'package:time_machine2/src/timezones/zone_guesser.dart';
import 'package:universal_io/io.dart' as io;

import 'time_machine_testing.dart';

Future main() async {
  await TimeMachineTest.initialize();
  await runTests();
}

TzdbDateTimeZoneSource get source => TzdbDateTimeZoneSource.defaultSource;

// ---------------------------------------------------------------------------
// Embedded data and the public mapping API (ported from Noda Time's
// TzdbDateTimeZoneSourceTest).
// ---------------------------------------------------------------------------

@Test()
void ValidateDefault() => source.validate();

@Test()
void WindowsMappingIsEmbedded() {
  expect(source.windowsMapping.mapZones, isNotEmpty);
  expect(source.windowsMapping.windowsVersion, isNotEmpty);
  expect(
      source.windowsToTzdbIds['AUS Eastern Standard Time'], 'Australia/Sydney');
  expect(source.windowsToTzdbIds['W. Europe Standard Time'], 'Europe/Berlin');
}

@Test()
void TzdbToWindowsIdDocumentationExamples() {
  const kolkata = 'Asia/Kolkata';
  const calcutta = 'Asia/Calcutta';
  const indiaStandardTime = 'India Standard Time';
  const asmara = 'Africa/Asmara';
  const eastAfricaStandardTime = 'E. Africa Standard Time';
  const nairobi = 'Africa/Nairobi';

  // Validate the claims about the source data
  var mappedIds = source.windowsMapping.mapZones.expand((mz) => mz.tzdbIds);
  expect(source.canonicalIdMap[calcutta], kolkata);
  expect(mappedIds, isNot(contains(kolkata)));
  expect(source.canonicalIdMap[asmara], nairobi);
  expect(mappedIds, isNot(contains(asmara)));

  // And the mappings
  expect(source.tzdbToWindowsIds[kolkata], indiaStandardTime);
  expect(source.tzdbToWindowsIds[asmara], eastAfricaStandardTime);
}

@Test()
void WindowsToTzdbIdDocumentationExamples() {
  expect(source.canonicalIdMap['Asia/Calcutta'], 'Asia/Kolkata');
  expect(source.windowsToTzdbIds['India Standard Time'], 'Asia/Kolkata');
}

@Test()
void UtcMappings() {
  expect(source.windowsToTzdbIds['UTC'], 'Etc/UTC');
  expect(source.tzdbToWindowsIds['Etc/UTC'], 'UTC');
  // We follow the link
  expect(source.tzdbToWindowsIds['Etc/GMT+0'], 'UTC');
}

@Test()
void WindowsStandardNamesThatDifferFromTheId() {
  expect(source.windowsStandardNameToTzdbId('Coordinated Universal Time'),
      'Etc/UTC');
  expect(source.windowsStandardNameToTzdbId('Malay Peninsula Standard Time'),
      'Asia/Singapore');
  expect(source.windowsStandardNameToTzdbId('Not A Zone'), isNull);
}

/// Canonical IDs: zone1 to zone6. Aliases, linked to the obvious corresponding
/// IDs: link1, link2, link3a, link3b, link3c. Windows mappings:
/// win1: zone1 (primary, UK); win2: link2 (primary, UK); win3: link3a (primary, UK);
/// win4: zone4 (primary, UK), zone5 (FR), link3b (CA).
final _complexCanonicalIdMap = {
  for (var i = 1; i <= 6; i++) 'zone$i': 'zone$i',
  'link1': 'zone1',
  'link2': 'zone2',
  'link3a': 'zone3',
  'link3b': 'zone3',
  'link3c': 'zone3',
};

final _complexWindowsMapping =
    WindowsZones('cldr-version', 'tzdb-version', 'windows-version', [
  MapZone('win1', MapZone.primaryTerritory, ['zone1']),
  MapZone('win1', 'UK', ['zone1']),
  MapZone('win2', MapZone.primaryTerritory, ['link2']),
  MapZone('win2', 'UK', ['link2']),
  MapZone('win3', MapZone.primaryTerritory, ['link3a']),
  MapZone('win3', 'UK', ['link3a']),
  MapZone('win4', MapZone.primaryTerritory, ['zone4']),
  MapZone('win4', 'UK', ['zone4']),
  MapZone('win4', 'FR', ['zone5']),
  MapZone('win4', 'CA', ['link3b']),
]);

@Test()
void TzdbToWindowsIds() {
  TzdbDateTimeZoneSource.validateData(
      _complexCanonicalIdMap, _complexWindowsMapping);
  var actual = TzdbDateTimeZoneSource.buildTzdbToWindowsIdMap(
      _complexWindowsMapping, _complexCanonicalIdMap);
  expect(actual, {
    'zone1': 'win1',
    'link1': 'win1',
    'zone2': 'win2',
    'link2': 'win2',
    // No explicit zone3 mapping; link3a and link3b map to win3 and win4 respectively;
    // link3a "wins" as it's earlier lexicographically.
    'zone3': 'win3',
    'link3a': 'win3',
    // Explicit mapping to win4 from link3b. This is unusual, but we handle it.
    'link3b': 'win4',
    // link3c isn't mentioned at all, so we use the canonical ID
    'link3c': 'win3',
    'zone4': 'win4',
    'zone5': 'win4',
    // zone6 isn't mapped at all
  });
}

// Validation (ported from Noda Time). zone3 is an alias for zone1.
const _sampleCanonicalIdMap = {
  'zone1': 'zone1',
  'zone2': 'zone2',
  'zone3': 'zone1',
};

void _assertInvalid(List<MapZone> mapZones,
    [Map<String, String> canonicalIdMap = _sampleCanonicalIdMap]) {
  expect(
      () => TzdbDateTimeZoneSource.validateData(
          canonicalIdMap,
          WindowsZones(
              'cldr-version', 'tzdb-version', 'windows-version', mapZones)),
      throwsA(isA<InvalidDateTimeZoneSourceError>()));
}

@Test()
void ValidSample() => TzdbDateTimeZoneSource.validateData(
    _sampleCanonicalIdMap,
    WindowsZones('cldr-version', 'tzdb-version', 'windows-version', [
      MapZone('windows-id', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id', 'UK', ['zone1']),
    ]));

@Test()
void LinkToNonExistentZone() =>
    _assertInvalid(const [], {..._sampleCanonicalIdMap, 'zone4': 'zone5'});

@Test()
void LinkToLink() =>
    _assertInvalid(const [], {..._sampleCanonicalIdMap, 'zone4': 'zone3'});

@Test()
void WindowsMappingWithoutPrimaryTerritory() => _assertInvalid([
      MapZone('windows-id', 'nonprimary', ['zone1', 'zone2'])
    ]);

@Test()
void WindowsMappingPrimaryTerritoryNotInNonPrimary() => _assertInvalid([
      MapZone('windows-id', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id', 'UK', ['zone2']),
    ]);

@Test()
void WindowsMappingUsesMissingId() => _assertInvalid([
      MapZone('windows-id', MapZone.primaryTerritory, ['zone4']),
      MapZone('windows-id', 'UK', ['zone4']),
    ]);

@Test()
void WindowsMappingContainsDuplicateTzdbIds_SameTerritory() => _assertInvalid([
      MapZone('windows-id', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id', 'UK', ['zone1']),
      MapZone('windows-id', 'CA', ['zone2', 'zone2']),
    ]);

@Test()
void WindowsMappingContainsDuplicateTzdbIds_SameWindowsIdDifferentTerritory() =>
    _assertInvalid([
      MapZone('windows-id', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id', 'UK', ['zone1']),
      MapZone('windows-id', 'CA', ['zone1']),
    ]);

@Test()
void WindowsMappingContainsDuplicateTzdbIds_DifferentTerritories() =>
    _assertInvalid([
      MapZone('windows-id1', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id1', 'CA', ['zone1']),
      MapZone('windows-id2', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id2', 'UK', ['zone1']),
    ]);

@Test()
void WindowsMappingContainsWindowsIdWithNoPrimaryTerritory() => _assertInvalid([
      MapZone('windows-id1', 'CA', ['zone1']),
    ]);

@Test()
void WindowsMappingContainsWindowsIdWithDuplicateTerritories() =>
    _assertInvalid([
      MapZone('windows-id1', MapZone.primaryTerritory, ['zone1']),
      MapZone('windows-id1', 'CA', ['zone2']),
      MapZone('windows-id1', 'CA', ['zone3']),
    ]);

// ---------------------------------------------------------------------------
// Guessing by transitions (ported from Noda Time).
// ---------------------------------------------------------------------------

Future<List<DateTimeZone>> _canonicalZones() async {
  var provider = DateTimeZoneProviders.defaultProvider!;
  var ids = source.canonicalIdMap.values.toSet().toList()..sort();
  return [for (var id in ids) await provider[id]];
}

@Test()
Future GuessByTransitionsPicksFirstMatchingZoneById() async {
  // Both Pacific/Honolulu and Etc/GMT+10 match with the same score; we use
  // Etc/GMT+10 as it comes first lexically.
  var id = guessZoneIdByTransitions(
      (_) => Offset.hours(-10), await _canonicalZones());
  expect(id, 'Etc/GMT+10');
}

@Test()
Future GuessByTransitionsFindsEveryWindowsZone() async {
  // Noda Time checks every system zone. We use each Windows zone's TZDB
  // zone as the "system" zone, and require the guess to agree on at least
  // 74% of the days in this year and next (Noda Time's threshold).
  var provider = DateTimeZoneProviders.defaultProvider!;
  var candidates = await _canonicalZones();
  var thisYear = DateTime.now().toUtc().year;
  var failures = <String>[];

  for (var tzdbId in source.windowsToTzdbIds.values.toSet()) {
    var systemZone = await provider[tzdbId];
    var guessedId =
        guessZoneIdByTransitions(systemZone.getUtcOffset, candidates);
    if (guessedId == null) {
      failures.add('$tzdbId: no guess');
      continue;
    }
    var guessed = await provider[guessedId];
    var total = 0, correct = 0;
    for (var date = LocalDate(thisYear, 1, 1);
        date.year < thisYear + 2;
        date = date.addDays(1)) {
      var startOfUtcDay = date.atMidnight().inUtc().toInstant();
      if (guessed.getUtcOffset(startOfUtcDay) ==
          systemZone.getUtcOffset(startOfUtcDay)) {
        correct++;
      }
      total++;
    }
    if (correct * 100.0 / total < 74.0) {
      failures.add('$tzdbId guessed as $guessedId: $correct/$total days');
    }
  }
  expect(failures, isEmpty);
}

// ---------------------------------------------------------------------------
// Local zone detection.
// ---------------------------------------------------------------------------

@Test()
void LocalZoneMatchesSystemOffset() {
  // Whatever zone is detected, it must agree with the system's current offset.
  var now = DateTime.now();
  var offset = DateTimeZone.local.getUtcOffset(Instant.dateTime(now));
  expect(offset.inSeconds, now.timeZoneOffset.inSeconds);
}

Future<String?> _registryValue(String key, String name) async {
  var result = await io.Process.run('reg', ['query', key, '/v', name],
      stdoutEncoding: utf8);
  if (result.exitCode != 0) return null;
  var match = RegExp('^\\s+$name\\s+REG_\\w+\\s+(.*)\$', multiLine: true)
      .firstMatch(result.stdout as String);
  return match?.group(1)?.trim();
}

const _timeZoneInformationKey =
    r'HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation';

@Test()
Future WindowsTimeZoneIdIsReadViaWin32() async {
  if (!io.Platform.isWindows) return;
  var expected =
      await _registryValue(_timeZoneInformationKey, 'TimeZoneKeyName');
  var info = readWindowsTimeZoneInfo();
  expect(info, isNotNull);
  expect(info!.keyName, expected);
}

/// The local zone comes from the Windows zone ID, which is the same in every
/// display language, so this holds on non-English Windows too.
@Test()
Future WindowsLocalZoneIsMappedFromZoneId() async {
  if (!io.Platform.isWindows) return;
  var keyName =
      await _registryValue(_timeZoneInformationKey, 'TimeZoneKeyName');
  var dstDisabled = await _registryValue(
      _timeZoneInformationKey, 'DynamicDaylightTimeDisabled');
  if (dstDisabled == '0x1') return; // detection deliberately guesses instead

  var expected = source.windowsToTzdbIds[keyName];
  if (expected == null) {
    // Unmapped legacy zone (see below): detection falls back to guessing.
    expect(_knownUnmappedWindowsIds, contains(keyName));
    return;
  }
  expect(DateTimeZone.local.id, expected,
      reason: 'Windows zone "$keyName", '
          'display name "${DateTime.now().timeZoneName}"');
}

/// Legacy Windows zones that CLDR deliberately doesn't map (Noda Time has the
/// same gap). Detection falls back to guessing by transitions for these.
const _knownUnmappedWindowsIds = {
  'Kamchatka Standard Time',
  'Mid-Atlantic Standard Time',
};

/// Equivalent of Noda Time's NameIdMappingSupport test: every zone in the
/// Windows registry must be mappable from its ID, and from its English
/// standard name (used when the ID can't be read).
@Test()
Future AllWindowsRegistryZonesAreMapped() async {
  if (!io.Platform.isWindows) return;

  var result = await io.Process.run(
      'reg',
      [
        'query',
        r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones',
        '/s',
        '/v',
        'Std',
      ],
      stdoutEncoding: utf8);
  expect(result.exitCode, 0, reason: '${result.stderr}');

  var unmapped = <String>[];
  String? windowsId;
  for (var line in LineSplitter.split(result.stdout as String)) {
    if (line.startsWith('HKEY_')) {
      windowsId = line.substring(line.lastIndexOf(r'\') + 1).trim();
      continue;
    }
    var match = RegExp(r'^\s+Std\s+REG_SZ\s+(.*)$').firstMatch(line);
    if (match == null || windowsId == null) continue;
    if (_knownUnmappedWindowsIds.contains(windowsId)) continue;
    var standardName = match.group(1)!.trim();

    if (source.windowsToTzdbIds[windowsId] == null) {
      unmapped.add('ID "$windowsId"');
    }
    if ((source.windowsStandardNameToTzdbId(standardName) ??
            source.windowsToTzdbIds[standardName]) ==
        null) {
      unmapped.add('standard name "$standardName" (ID "$windowsId")');
    }
  }
  expect(unmapped, isEmpty,
      reason: 'Add missing standard names to '
          'tool/tzdb_compiler/tzdb/named_id_mapping_support.dart, '
          'or add a newer CLDR windowsZones file, then rerun the TZDB compiler');
}

/// Guards the non-English Windows CI leg: with
/// TIME_MACHINE_EXPECT_LOCALIZED_WINDOWS=1, the display names Dart reports
/// must not be the English ones, otherwise that leg isn't testing anything.
@Test()
Future WindowsDisplayNamesAreLocalizedWhenExpected() async {
  if (!io.Platform.isWindows ||
      io.Platform.environment['TIME_MACHINE_EXPECT_LOCALIZED_WINDOWS'] != '1') {
    return;
  }
  var keyName =
      await _registryValue(_timeZoneInformationKey, 'TimeZoneKeyName');
  var zoneKey =
      r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\' +
          keyName!;
  var englishNames = {
    await _registryValue(zoneKey, 'Std'),
    await _registryValue(zoneKey, 'Dlt'),
  };
  var year = DateTime.now().year;
  var reported = {
    DateTime(year, 1, 1).timeZoneName,
    DateTime(year, 7, 1).timeZoneName,
  };
  expect(reported.intersection(englishNames), isEmpty,
      reason: 'Dart reports $reported for Windows zone "$keyName"');
}
