// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/datetimezone_writer.dart';
import 'package:time_machine2/src/utility/binary_writer.dart';

/// Wrapper around a [DateTimeZoneWriter]/[DateTimeZoneReader] pair for
/// round-trip tests; the equivalent of Noda Time's DtzIoHelper.
///
/// Write with [writer], then read back with [reader]: the reader is created
/// on first use, over everything written so far.
class DtzIoHelper {
  final List<int> _output = [];
  final List<String>? _stringPool;
  late DateTimeZoneWriter writer;
  DateTimeZoneReader? _reader;

  DtzIoHelper._(this._stringPool) {
    writer = DateTimeZoneWriter(BinaryWriter(_output), _stringPool);
  }

  /// Creates a helper which writes strings inline.
  factory DtzIoHelper.noStringPool() => DtzIoHelper._(null);

  /// Creates a helper which writes strings as indexes into a shared pool.
  factory DtzIoHelper.withStringPool() => DtzIoHelper._(<String>[]);

  /// The bytes written so far.
  List<int> get bytes => List.unmodifiable(_output);

  DateTimeZoneReader get reader => _reader ??= DateTimeZoneReader(
      ByteData.sublistView(Uint8List.fromList(_output)), _stringPool);

  /// Clears everything written (and the string pool), so the helper can be
  /// reused.
  void reset() {
    _output.clear();
    _stringPool?.clear();
    _reader = null;
  }

  /// Writes [value] with [write], reads it back with [read], and checks the
  /// result is equal to [value] and that the whole stream was consumed.
  void testRoundTrip<T>(T value, void Function(T value) write,
      T Function(DateTimeZoneReader reader) read) {
    reset();
    write(value);
    var actual = read(reader);
    expect(actual, value);
    expect(reader.hasMoreData, isFalse);
  }

  void testZoneYearOffset(ZoneYearOffset value) => testRoundTrip(
      value, (v) => v.write(writer), (r) => ZoneYearOffset.read(r));

  void testZoneRecurrence(ZoneRecurrence value) => testRoundTrip(
      value, (v) => v.write(writer), (r) => ZoneRecurrence.read(r));
}
