// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:collection/collection.dart';
import 'package:universal_io/io.dart' as io;

/// Finds the IANA ID of the system time zone on Linux, macOS and Android, the
/// way .NET's `TimeZoneInfo.Local` does (which is what Noda Time maps):
///
/// * Android: the `persist.sys.timezone` system property.
/// * Otherwise the `TZ` environment variable, if set (a leading ':' is ignored).
///   An empty value means UTC. A relative value is the ID itself.
/// * Otherwise `/etc/localtime` (or `$TZDIR/localtime`): the ID comes from
///   the symlink target, or failing that from the zoneinfo file with the same
///   contents.
///
/// [knownIds] are the TZDB IDs to accept, ordered with canonical IDs first so
/// a content match picks a canonical ID. Returns null if no known ID is found.
String? readUnixTimeZoneId(List<String> knownIds) {
  try {
    final known = knownIds.toSet();
    String? accept(String? id) => id != null && known.contains(id) ? id : null;

    if (io.Platform.isAndroid) {
      final result = io.Process.runSync('getprop', ['persist.sys.timezone']);
      if (result.exitCode == 0) {
        return accept((result.stdout as String).trim());
      }
      return null;
    }

    final environment = io.Platform.environment;
    final zoneInfoDirectory = timeZoneDirectory(environment['TZDIR']);
    final tz = tzEnvironmentVariable(environment['TZ']);

    if (tz == null) {
      for (final path in ['/etc/localtime', '${zoneInfoDirectory}localtime']) {
        final id = _idForFile(path, zoneInfoDirectory, knownIds);
        if (id != null) return accept(id);
      }
      return null;
    }

    // An empty TZ means UTC.
    if (tz.isEmpty) return accept('UTC') ?? accept('Etc/UTC');

    // A relative TZ is the ID, relative to the zoneinfo directory.
    if (!tz.startsWith('/')) return accept(tz);
    return accept(_idForFile(tz, zoneInfoDirectory, knownIds));
  } catch (_) {
    return null;
  }
}

/// The value of `TZ`, without the leading ':' POSIX allows. Null if unset.
String? tzEnvironmentVariable(String? tz) =>
    tz != null && tz.startsWith(':') ? tz.substring(1) : tz;

/// The zoneinfo directory: `$TZDIR` or /usr/share/zoneinfo/, with a trailing slash.
String timeZoneDirectory(String? tzDir) {
  final directory =
      tzDir == null || tzDir.isEmpty ? '/usr/share/zoneinfo/' : tzDir;
  return directory.endsWith('/') ? directory : '$directory/';
}

/// The zone ID for a path inside a zoneinfo directory, for example
/// 'Europe/Berlin' for '/usr/share/zoneinfo/Europe/Berlin' or (on macOS)
/// '/var/db/timezone/zoneinfo/Europe/Berlin'. Null if the path isn't in one.
String? zoneIdFromPath(String path, String zoneInfoDirectory) {
  final normalized = _normalize(path);
  if (normalized.startsWith(zoneInfoDirectory)) {
    return normalized.substring(zoneInfoDirectory.length);
  }
  const marker = '/zoneinfo/';
  final index = normalized.lastIndexOf(marker);
  if (index < 0) return null;
  final id = normalized.substring(index + marker.length);
  return id.isEmpty ? null : id;
}

String? _idForFile(
    String path, String zoneInfoDirectory, List<String> knownIds) {
  final file = io.File(path);
  if (!file.existsSync()) return null;

  // Prefer the symlink target, as .NET does.
  final link = io.Link(path);
  if (link.existsSync()) {
    var target = link.targetSync();
    if (!target.startsWith('/')) {
      target = '${io.File(path).parent.path}/$target';
    }
    final id = zoneIdFromPath(target, zoneInfoDirectory);
    if (id != null) return id;
  }

  // A file in the zoneinfo directory itself (e.g. TZ=/usr/share/zoneinfo/X).
  final direct = zoneIdFromPath(path, zoneInfoDirectory);
  if (direct != null && direct != 'localtime') return direct;

  // A copy rather than a link: find the zoneinfo file with the same contents.
  final contents = file.readAsBytesSync();
  const equality = ListEquality<int>();
  for (final id in knownIds) {
    final candidate = io.File('$zoneInfoDirectory$id');
    try {
      if (candidate.existsSync() &&
          candidate.lengthSync() == contents.length &&
          equality.equals(candidate.readAsBytesSync(), contents)) {
        return id;
      }
    } catch (_) {
      // Unreadable candidate; keep looking.
    }
  }
  return null;
}

/// Resolves '.' and '..' segments and duplicate slashes.
String _normalize(String path) {
  final segments = <String>[];
  for (final segment in path.split('/')) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (segments.isNotEmpty) segments.removeLast();
    } else {
      segments.add(segment);
    }
  }
  return '/${segments.join('/')}';
}
