// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'system_time_zone_backend.dart';

/// Android: the system tzdata bundle. (Placeholder.)
class AndroidTzdataBackend {
  static SystemTimeZoneBackend create() =>
      const UnsupportedSystemTimeZoneBackend(
          'Android backend not implemented yet');
}
