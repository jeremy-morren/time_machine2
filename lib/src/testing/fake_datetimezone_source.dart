// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'dart:async';

import 'package:time_machine2/src/time_machine_internal.dart';

/// A time zone source for test purposes.
/// Create instances via [FakeDateTimeZoneSourceBuilder].
class FakeDateTimeZoneSource extends DateTimeZoneSource {
  final Map<String, DateTimeZone> _zones;
  String? _systemDefaultId;

  FakeDateTimeZoneSource._(this.versionId, this._zones, this._systemDefaultId);

  /// Creates a time zone provider ([DateTimeZoneCache]) from this source.
  ///
  /// Returns: A provider backed by this source.
  Future<DateTimeZoneProvider> toProvider() => DateTimeZoneCache.getCache(this);

  @override
  Future<Iterable<String>> getIds() => Future.value(_zones.keys);

  /// The version ID: the [FakeDateTimeZoneSourceBuilder.versionId] of the
  /// builder.
  @override
  // ignore: overridden_fields
  final String versionId;

  /// Returns the zone with the given ID.
  ///
  /// * [ArgumentError]: [id] is not the ID of a zone in this source.
  @override
  Future<DateTimeZone> forId(String id) => Future.value(forCachedId(id));

  /// Returns the zone with the given ID.
  ///
  /// * [ArgumentError]: [id] is not the ID of a zone in this source.
  @override
  DateTimeZone forCachedId(String id) {
    Preconditions.checkNotNull(id, 'id');
    var zone = _zones[id];
    if (zone != null) {
      return zone;
    }
    throw ArgumentError('Unknown ID: $id');
  }

  /// The ID of the zone to report as the system default: the
  /// [FakeDateTimeZoneSourceBuilder.systemDefaultId] of the builder, or the
  /// last value passed to [setSystemDefaultId]. Null if neither was set.
  ///
  /// (Noda Time maps the system's `TimeZoneInfo.Local` ID through the
  /// builder's `BclIdsToZoneIds` instead.)
  @override
  String? get systemDefaultId => _systemDefaultId;

  @override
  void setSystemDefaultId(String id) {
    _systemDefaultId = id;
  }
}

/// Builder for [FakeDateTimeZoneSource], allowing the built object to
/// be immutable, but constructed with cascades.
///
/// This is Noda Time's `FakeDateTimeZoneSource.Builder`.
class FakeDateTimeZoneSourceBuilder {
  /// The list of zones, exposed for use when a test needs to set properties
  /// as well as adding zones.
  final List<DateTimeZone> zones = <DateTimeZone>[];

  /// The version ID to advertise; defaults to `TestZones`.
  String versionId = 'TestZones';

  /// The ID of the zone the built source reports as the system default, or
  /// null (the default) for none. It must be the ID of one of the [zones].
  String? systemDefaultId;

  /// Creates a new builder, optionally with an initial list of zones.
  FakeDateTimeZoneSourceBuilder([Iterable<DateTimeZone> zones = const []]) {
    this.zones.addAll(zones);
  }

  /// Adds a time zone to the builder.
  ///
  /// * [zone]: The zone to add.
  void add(DateTimeZone zone) {
    Preconditions.checkNotNull(zone, 'zone');
    zones.add(zone);
  }

  /// Builds a time zone source from this builder. The returned source will
  /// be independent of this builder; further changes to this builder will
  /// not be reflected in the returned source.
  ///
  /// This method performs some sanity checks, and throws errors if they're
  /// violated. Those errors are not documented here, and you shouldn't be
  /// catching them anyway. (This is aimed at testing...)
  ///
  /// Returns: The newly-built time zone source.
  FakeDateTimeZoneSource build() {
    var zoneMap = <String, DateTimeZone>{};
    for (var zone in zones) {
      // As Noda Time's ToDictionary, which throws on a duplicate key.
      if (zoneMap.containsKey(zone.id)) {
        throw ArgumentError('Duplicate zone ID: ${zone.id}', 'zones');
      }
      zoneMap[zone.id] = zone;
    }
    var defaultId = systemDefaultId;
    if (defaultId != null && !zoneMap.containsKey(defaultId)) {
      throw StateError(
          'The system default ID $defaultId has no corresponding zone.');
    }
    return FakeDateTimeZoneSource._(versionId, zoneMap, defaultId);
  }
}
