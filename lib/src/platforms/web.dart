// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'dart:async';
import 'dart:js_interop';

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/datetimezone_providers.dart';
import 'package:time_machine2/time_machine2.dart';

import 'platform_io.dart';

Future initialize(Map<String, dynamic> args) => TimeMachine.initialize(args);

class TimeMachine {
  // I'm looking to basically use @internal for protection??? <-- what did I mean by this?
  static Future initialize(Map<String, dynamic> args) async {
    Platform.startWeb();

    String? timeZoneOverride = args['timeZone'];
    String? cultureOverride = args['culture'];

    // Map IO functions
    PlatformIO(config: args);

    // Default provider
    var tzdb = await DateTimeZoneProviders.tzdb;
    IDateTimeZoneProviders.defaultProvider = tzdb;

    var options = _readIntlObject();

    // Default TimeZone
    var local = timeZoneOverride != null
        ? await tzdb.getZoneOrNull(timeZoneOverride)
        : await _figureOutTimeZone(tzdb, options?.timeZone);
    tzdb.setSystemDefault(local!.id);

    // Default Culture
    var cultureId = cultureOverride ?? options?.locale ?? 'en-US';
    var culture = await Cultures.getCulture(cultureId);

    // fall back to en-US if the browser's culture doesn't exist, as on the VM
    culture ??= await Cultures.getCulture('en-US');
    ICultures.currentCulture = culture!;
  }

  /// The zone `Intl.DateTimeFormat().resolvedOptions().timeZone` names, mapped
  /// to a TZDB ID as the VM maps the system's zone ID (as Noda Time maps
  /// `TimeZoneInfo.Local.Id`): so 'UTC' becomes 'Etc/UTC', as on the VM.
  ///
  /// If the browser reports no zone, or one TZDB doesn't know, this falls back
  /// to a fixed zone with the browser's current offset, as the VM does.
  static Future<DateTimeZone> _figureOutTimeZone(
      DateTimeZoneProvider provider, String? systemId) async {
    if (systemId != null) {
      var id = IDateTimeZoneProviders.tzdbSource.mapSystemTimeZoneId(systemId);
      if (id != null && provider.ids.contains(id)) return await provider[id];
    }

    return DateTimeZone.forOffset(
        Offset(DateTime.now().timeZoneOffset.inSeconds));
  }

  // {locale: en-US, numberingSystem: latn, calendar: gregory, timeZone: America/New_York, year: numeric, month: numeric, day: numeric}
  static _ResolvedOptions? _readIntlObject() {
    try {
      return _DateTimeFormat().resolvedOptions();
    } catch (e, s) {
      print('Failed to get platform local information.\n$e\n$s');
      return null;
    }
  }
}

@JS('Intl.DateTimeFormat')
extension type _DateTimeFormat._(JSObject _) implements JSObject {
  external _DateTimeFormat();
  external _ResolvedOptions resolvedOptions();
}

/// The parts of `resolvedOptions()` used. Either may be missing (for example
/// `timeZone` in older engines), so both are nullable.
extension type _ResolvedOptions._(JSObject _) implements JSObject {
  external String? get locale;
  external String? get timeZone;
}
