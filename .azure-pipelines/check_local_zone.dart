// Prints the local time zone Time Machine detects, and fails if it isn't the
// expected one (first argument, optional) or disagrees with the system's
// current UTC offset.
//
// The system offset is Dart's DateTime offset, unless SYSTEM_OFFSET_SECONDS
// gives it (the pipeline passes Windows' own offset from .NET's TimeZoneInfo,
// because Dart's C runtime applies the current year's rules to every year and
// honours TZ). KNOWN_OFFSET_DIFFERENCE, if set, explains an expected
// difference between the OS's data and TZDB: it's reported, not failed.
import 'dart:io';

import 'package:time_machine2/time_machine2.dart';

Future<void> main(List<String> args) async {
  await TimeMachine.initialize();
  final local = DateTimeZone.local;
  final now = DateTime.now();
  final offset = local.getUtcOffset(Instant.dateTime(now));

  print('System:       ${now.timeZoneName} (UTC offset ${now.timeZoneOffset})');
  print('Time Machine: ${local.id} (UTC offset $offset)');
  print('TZDB:         ${TzdbDateTimeZoneSource.defaultSource.versionId}');
  print('TZ:           ${Platform.environment['TZ'] ?? '<unset>'}');
  final localtime = Link('/etc/localtime');
  if (!Platform.isWindows && localtime.existsSync()) {
    print('/etc/localtime -> ${localtime.targetSync()}');
  }

  var failed = false;
  final expected = args.isEmpty ? '' : args.first.trim();
  if (expected.isNotEmpty && local.id != expected) {
    stderr.writeln('FAIL: expected $expected, detected ${local.id}');
    failed = true;
  }
  final systemOffsetSeconds =
      int.tryParse(Platform.environment['SYSTEM_OFFSET_SECONDS'] ?? '') ??
          now.timeZoneOffset.inSeconds;
  final systemOffset = Offset(systemOffsetSeconds);
  print('System offset: $systemOffset '
      '(${Platform.environment.containsKey('SYSTEM_OFFSET_SECONDS') ? 'from the OS' : 'from Dart'})');
  final knownDifference = Platform.environment['KNOWN_OFFSET_DIFFERENCE'] ?? '';
  if (offset != systemOffset) {
    if (knownDifference.isNotEmpty) {
      print('KNOWN DIFFERENCE: detected zone offset $offset != system offset '
          '$systemOffset: $knownDifference');
    } else {
      stderr.writeln('FAIL: detected zone offset $offset != system offset '
          '$systemOffset');
      failed = true;
    }
  } else if (knownDifference.isNotEmpty) {
    stderr.writeln('FAIL: expected a difference ($knownDifference), but the '
        'offsets agree ($offset); remove KNOWN_OFFSET_DIFFERENCE');
    failed = true;
  }
  exit(failed ? 1 : 0);
}
