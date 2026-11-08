// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'dart:typed_data';

import 'package:parameterized_test/parameterized_test.dart';
import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/datetimezone_writer.dart';

import '../time_machine_testing.dart';
import 'dtz_io_helper.dart';

/// Round-trip tests for [DateTimeZoneWriter] and [DateTimeZoneReader], as
/// Noda Time's DateTimeZoneReaderTest and DtzIoHelper-based tests.
void main() {
  setUpAll(TimeMachineTest.initialize);

  parameterizedTest(
      'Count_RoundTrip',
      [
        [0],
        [1],
        [127],
        [128],
        [16383],
        [16384],
        [1 << 21],
        [Platform.int32MaxValue],
      ],
      Count_RoundTrip,
      customDescriptionBuilder: describeArguments);
  test('WriteCount_Negative', WriteCount_Negative);
  test(
      'ReadCount_GreaterThanInt32MaxValue', ReadCount_GreaterThanInt32MaxValue);
  parameterizedTest(
      'SignedCount_RoundTrip',
      [
        [0],
        [1],
        [-1],
        [63],
        [-64],
        [100000],
        [-100000],
        [90 * 3600],
        [-180 * 3600],
      ],
      SignedCount_RoundTrip,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'Milliseconds_RoundTrip',
      [
        // Multiples of 30 minutes: one byte.
        [0, 1],
        [30 * 60 * 1000, 1],
        [-30 * 60 * 1000, 1],
        // Whole minutes: two bytes.
        [5 * 60 * 1000, 2],
        [-(23 * 60 + 59) * 60 * 1000, 2],
        // Whole seconds: three bytes.
        [5 * 1000, 3],
        [-(23 * 3600 + 59 * 60 + 59) * 1000, 3],
        // Anything else: four bytes.
        [1, 4],
        [-1, 4],
        [TimeConstants.millisecondsPerDay - 1, 4],
        [-TimeConstants.millisecondsPerDay + 1, 4],
      ],
      Milliseconds_RoundTrip,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'WriteMilliseconds_OutOfRange',
      [
        [TimeConstants.millisecondsPerDay],
        [-TimeConstants.millisecondsPerDay],
      ],
      WriteMilliseconds_OutOfRange,
      customDescriptionBuilder: describeArguments);
  test('ReadMilliseconds_InvalidFlag', ReadMilliseconds_InvalidFlag);
  test('Offset_RoundTrip', Offset_RoundTrip);
  test('String_RoundTrip_NoStringPool', String_RoundTrip_NoStringPool);
  test('String_RoundTrip_WithStringPool', String_RoundTrip_WithStringPool);
  test('Dictionary_RoundTrip', Dictionary_RoundTrip);
  test('HasMoreData', HasMoreData);
  test('ReadByte_EndOfStream', ReadByte_EndOfStream);
  test('ZoneIntervalTransition_Markers', ZoneIntervalTransition_Markers);
  test('ZoneIntervalTransition_HoursSincePrevious',
      ZoneIntervalTransition_HoursSincePrevious);
  test('ZoneIntervalTransition_MinutesSinceEpoch',
      ZoneIntervalTransition_MinutesSinceEpoch);
  test('ZoneIntervalTransition_Raw', ZoneIntervalTransition_Raw);
  test('ZoneIntervalTransition_Backwards', ZoneIntervalTransition_Backwards);
  test('ReadZoneIntervalTransition_NoPreviousValue',
      ReadZoneIntervalTransition_NoPreviousValue);
  test('ReadZoneIntervalTransition_UnknownMarker',
      ReadZoneIntervalTransition_UnknownMarker);
}

void Count_RoundTrip(int value) {
  var dio = DtzIoHelper.noStringPool();
  dio.writer.writeCount(value);
  expect(dio.reader.readCount(), value);
  expect(dio.reader.hasMoreData, isFalse);
}

void WriteCount_Negative() {
  var dio = DtzIoHelper.noStringPool();
  expect(() => dio.writer.writeCount(-1), throwsArgumentError);
}

void ReadCount_GreaterThanInt32MaxValue() {
  // 2^31 as a varint.
  var reader = DateTimeZoneReader(
      ByteData.sublistView(Uint8List.fromList([0x80, 0x80, 0x80, 0x80, 0x08])),
      null);
  expect(() => reader.readCount(), throwsException);
}

void SignedCount_RoundTrip(int value) {
  var dio = DtzIoHelper.noStringPool();
  dio.writer.writeSignedCount(value);
  expect(dio.reader.readSignedCount(), value);
  expect(dio.reader.hasMoreData, isFalse);
}

void Milliseconds_RoundTrip(int millis, int expectedLength) {
  var dio = DtzIoHelper.noStringPool();
  dio.writer.writeMilliseconds(millis);
  expect(dio.bytes.length, expectedLength);
  expect(dio.reader.readMilliseconds(), millis);
  expect(dio.reader.hasMoreData, isFalse);
}

void WriteMilliseconds_OutOfRange(int millis) {
  var dio = DtzIoHelper.noStringPool();
  expect(() => dio.writer.writeMilliseconds(millis), throwsArgumentError);
}

void ReadMilliseconds_InvalidFlag() {
  // A first byte with the top three bits set isn't a valid encoding.
  var reader = DateTimeZoneReader(
      ByteData.sublistView(Uint8List.fromList([0xe0])), null);
  expect(() => reader.readMilliseconds(), throwsException);
}

void Offset_RoundTrip() {
  var dio = DtzIoHelper.noStringPool();
  var offsets = [
    Offset.zero,
    Offset.hours(5),
    Offset.hoursAndMinutes(-3, -30),
    Offset(12345),
    Offset.maxValue,
    Offset.minValue,
  ];
  for (var offset in offsets) {
    dio.writer.writeOffset(offset);
  }
  for (var offset in offsets) {
    expect(dio.reader.readOffset(), offset);
  }
  expect(dio.reader.hasMoreData, isFalse);
}

void String_RoundTrip_NoStringPool() {
  var dio = DtzIoHelper.noStringPool();
  dio.writer.writeString('');
  dio.writer.writeString('Europe/London');
  dio.writer.writeString('Zürich');
  expect(dio.reader.readString(), '');
  expect(dio.reader.readString(), 'Europe/London');
  expect(dio.reader.readString(), 'Zürich');
  expect(dio.reader.hasMoreData, isFalse);
}

void String_RoundTrip_WithStringPool() {
  var dio = DtzIoHelper.withStringPool();
  dio.writer.writeString('first');
  dio.writer.writeString('second');
  dio.writer.writeString('first');
  // Each string is written as its index in the pool.
  expect(dio.bytes, [0, 1, 0]);
  expect(dio.reader.readString(), 'first');
  expect(dio.reader.readString(), 'second');
  expect(dio.reader.readString(), 'first');
  expect(dio.reader.hasMoreData, isFalse);
}

void Dictionary_RoundTrip() {
  var dio = DtzIoHelper.noStringPool();
  var dictionary = {'a': 'b', 'Europe/London': 'GMT Standard Time', '': 'x'};
  dio.writer.writeDictionary(dictionary);
  expect(dio.reader.readDictionary(), dictionary);
  expect(dio.reader.hasMoreData, isFalse);
}

void HasMoreData() {
  var reader = DateTimeZoneReader(
      ByteData.sublistView(Uint8List.fromList([1, 2])), null);
  expect(reader.hasMoreData, isTrue);
  expect(reader.readByte(), 1);
  expect(reader.hasMoreData, isTrue);
  expect(reader.readByte(), 2);
  expect(reader.hasMoreData, isFalse);
}

void ReadByte_EndOfStream() {
  var reader = DateTimeZoneReader(ByteData(0), null);
  expect(() => reader.readByte(), throwsException);
}

/// Writes [value] (after [previous]) and checks it reads back, and that it
/// was written in [expectedLength] bytes.
void _testTransition(Instant? previous, Instant value, int expectedLength) {
  var dio = DtzIoHelper.noStringPool();
  dio.writer.writeZoneIntervalTransition(previous, value);
  expect(dio.bytes.length, expectedLength);
  expect(dio.reader.readZoneIntervalTransition(previous), value);
  expect(dio.reader.hasMoreData, isFalse);
}

void ZoneIntervalTransition_Markers() {
  _testTransition(null, IInstant.beforeMinValue, 1);
  _testTransition(null, IInstant.afterMaxValue, 1);
  _testTransition(Instant.utc(2000, 1, 1, 0, 0), IInstant.afterMaxValue, 1);
}

void ZoneIntervalTransition_HoursSincePrevious() {
  var previous = Instant.utc(2000, 3, 26, 1, 0);
  // About six months later: a whole number of hours, written as a delta.
  _testTransition(previous, previous.add(Time(hours: 5000)), 2);
  // Too close to the previous transition for the delta encoding (fewer than
  // 128 hours), so written as minutes since the epoch for that encoding.
  _testTransition(previous, previous.add(Time(hours: 100)), 4);
  // Not a whole number of hours: also written as minutes.
  _testTransition(previous, previous.add(Time(hours: 5000, minutes: 30)), 4);
  // The start of time isn't a useful previous value.
  _testTransition(IInstant.beforeMinValue, previous, 4);
}

void ZoneIntervalTransition_MinutesSinceEpoch() {
  _testTransition(null, Instant.utc(2000, 3, 26, 1, 30), 4);
  _testTransition(null, Instant.utc(1970, 1, 1, 0, 0), 4);
}

void ZoneIntervalTransition_Raw() {
  if (skipUnless(
      !intsAreJsNumbers, 'DateTimeZoneWriter.writeInt64 needs 64-bit integers'))
    return;
  // Before the epoch used for minutes...
  _testTransition(null, Instant.utc(1700, 1, 1, 0, 0), 9);
  // ... or not a whole number of minutes.
  _testTransition(null, Instant.utc(2000, 1, 1, 0, 0, 30), 9);
}

void ZoneIntervalTransition_Backwards() {
  var dio = DtzIoHelper.noStringPool();
  expect(
      () => dio.writer.writeZoneIntervalTransition(
          Instant.utc(2000, 1, 1, 0, 0), Instant.utc(1999, 1, 1, 0, 0)),
      throwsArgumentError);
}

void ReadZoneIntervalTransition_NoPreviousValue() {
  // Count value between 1 << 7 and 1 << 21 (we'll use 1 << 8).
  var reader = DateTimeZoneReader(
      ByteData.sublistView(Uint8List.fromList([0x80, 2])), null);
  expect(() => reader.readZoneIntervalTransition(null), throwsException);
}

void ReadZoneIntervalTransition_UnknownMarker() {
  var reader =
      DateTimeZoneReader(ByteData.sublistView(Uint8List.fromList([3])), null);
  expect(() => reader.readZoneIntervalTransition(null), throwsException);
}
