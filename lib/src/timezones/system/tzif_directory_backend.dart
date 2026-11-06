// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'system_time_zone_backend.dart';

/// Linux, macOS, iOS: TZif files in the zoneinfo directory. (Placeholder.)
class TzifDirectoryBackend {
  static SystemTimeZoneBackend create() =>
      const UnsupportedSystemTimeZoneBackend(
          'TZif backend not implemented yet');
}
