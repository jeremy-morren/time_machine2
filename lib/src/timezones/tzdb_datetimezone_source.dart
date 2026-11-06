import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:time_machine2/src/platforms/platform_io.dart';
import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/tzdb_stream_reader.dart';

class TzdbDateTimeZoneSource extends DateTimeZoneSource {
  bool _initialized = false;

  // map of date time zones that are deserialized from TZF entries on init
  final _dateTimeZones = <String, DateTimeZone>{};
  final _aliases = <String, String>{};
  final _windowsIdToTzdbId = <String, String>{};
  final _windowsStandardNameToTzdbId = <String, String>{};

  String _defaultId = "UTC";
  String _versionId = 'Uninitialized';

  TzdbDateTimeZoneSource();

  Future<void> _init() async {
    if (!_initialized) {
      final xzDecoder = XZDecoder();

      final tzdbData = xzDecoder.decodeBytes(
          (await PlatformIO.local.getBinary('tzdb', 'tzdb.bin'))
              .buffer
              .asUint8List(),
          verify: true);

      final streamReader = TzdbStreamReader(ByteData.sublistView(tzdbData));

      _versionId = 'TZDB: ${streamReader.tzdbVersion}';
      _aliases.clear();
      _aliases.addAll(streamReader.aliases);

      _windowsIdToTzdbId
        ..clear()
        ..addAll(streamReader.windowsIdToTzdbId);
      _windowsStandardNameToTzdbId
        ..clear()
        ..addAll(streamReader.windowsStandardNameToTzdbId);

      final dateTimeZones = streamReader.timeZones;

      _dateTimeZones.clear();
      _dateTimeZones.addAll(dateTimeZones);

      // Add time zones under their alias names as well
      final aliases = streamReader.aliases;
      for (final entry in aliases.entries) {
        final aliasId = entry.key;
        final canonicalId = entry.value;
        if (_dateTimeZones.containsKey(canonicalId)) {
          final originalZone = _dateTimeZones[canonicalId]!;
          if (originalZone is FixedDateTimeZone) {
            _dateTimeZones[aliasId] = FixedDateTimeZone(
                aliasId, originalZone.offset, originalZone.name);
          } else if (originalZone is PrecalculatedDateTimeZone) {
            _dateTimeZones[aliasId] = PrecalculatedDateTimeZone(
                aliasId, originalZone.periods, originalZone.tailZone);
          } else {
            // For any other type, just use the original instance
            _dateTimeZones[aliasId] = originalZone;
          }
        }
      }

      _initialized = true;
    }
  }

  @override
  Future<DateTimeZone> forId(String id) async {
    await _init();

    return forCachedId(id);
  }

  @override
  DateTimeZone forCachedId(String id) {
    return _dateTimeZones[id] ?? _dateTimeZones['UTC']!;
  }

  @override
  Future<Iterable<String>> getIds() async {
    await _init();
    return _dateTimeZones.keys;
  }

  /// Maps a Windows time zone ID or standard name to a TZDB ID, using the
  /// CLDR Windows zone mapping embedded in the TZDB data.
  ///
  /// On Windows, [DateTime.timeZoneName] returns the zone's standard name
  /// (e.g. 'AUS Eastern Standard Time'), which usually matches the Windows ID.
  /// Returns null if the name is unknown (e.g. daylight or localized names).
  Future<String?> windowsZoneNameToTzdbId(String name) async {
    await _init();
    return _windowsStandardNameToTzdbId[name] ?? _windowsIdToTzdbId[name];
  }

  @override
  String get systemDefaultId => _defaultId;

  @override
  String get versionId => _versionId;

  @override
  void setSystemDefaultId(String id) {
    _defaultId = id;
  }
}
