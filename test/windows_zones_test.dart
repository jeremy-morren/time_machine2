// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:time_machine2/time_machine2.dart';
import 'package:time_machine2/src/timezones/datetimezone_providers.dart';
import 'package:universal_io/io.dart' as io;

import 'time_machine_testing.dart';

Future main() async {
  await TimeMachineTest.initialize();
  await runTests();
}

@Test()
Future WindowsMappingIsEmbedded() async {
  var source = IDateTimeZoneProviders.tzdbSource;
  expect(await source.windowsZoneNameToTzdbId('AUS Eastern Standard Time'),
      'Australia/Sydney');
  expect(await source.windowsZoneNameToTzdbId('W. Europe Standard Time'),
      'Europe/Berlin');
  // Standard names that differ from the Windows ID
  expect(await source.windowsZoneNameToTzdbId('Coordinated Universal Time'),
      'Etc/UTC');
  expect(await source.windowsZoneNameToTzdbId('Malay Peninsula Standard Time'),
      'Asia/Singapore');
  expect(await source.windowsZoneNameToTzdbId('Not A Zone'), isNull);
}

@Test()
void LocalZoneMatchesSystemOffset() {
  // Whatever zone is detected, it must agree with the system's current offset.
  var now = DateTime.now();
  var offset = DateTimeZone.local.getUtcOffset(Instant.dateTime(now));
  expect(offset.inSeconds, now.timeZoneOffset.inSeconds);
}

@Test()
Future WindowsLocalZoneIsMappedFromSystemName() async {
  if (!io.Platform.isWindows) return;
  var id = await IDateTimeZoneProviders.tzdbSource.windowsZoneNameToTzdbId(
      DateTime(DateTime.now().year, 1, 1).timeZoneName);
  var julyId = await IDateTimeZoneProviders.tzdbSource.windowsZoneNameToTzdbId(
      DateTime(DateTime.now().year, 7, 1).timeZoneName);
  var expected = id ?? julyId;
  if (expected == null) return; // e.g. localized Windows
  expect(DateTimeZone.local.id, expected);
}

/// Legacy Windows zones that CLDR deliberately doesn't map (Noda Time has the
/// same gap). Detection falls back to the offset-based heuristic for these.
const _knownUnmappedWindowsIds = {
  'Kamchatka Standard Time',
  'Mid-Atlantic Standard Time',
};

/// Equivalent of Noda Time's NameIdMappingSupport test: every zone in the
/// Windows registry must be mappable from both its ID and its standard name,
/// which is what Dart reports in [DateTime.timeZoneName].
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

  var source = IDateTimeZoneProviders.tzdbSource;
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

    if (await source.windowsZoneNameToTzdbId(windowsId) == null) {
      unmapped.add('ID "$windowsId"');
    }
    if (await source.windowsZoneNameToTzdbId(standardName) == null) {
      unmapped.add('standard name "$standardName" (ID "$windowsId")');
    }
  }
  expect(unmapped, isEmpty,
      reason: 'Add missing standard names to '
          'tool/tzdb_compiler/tzdb/named_id_mapping_support.dart, '
          'or add a newer CLDR windowsZones file, then rerun the TZDB compiler');
}
