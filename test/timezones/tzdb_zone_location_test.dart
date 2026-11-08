// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// The bundled TZDB data doesn't include location information at this time,
// but the type (and its serialization) is tested as in Noda Time.

import 'package:parameterized_test/parameterized_test.dart';
import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/tzdb_zone_location.dart';

import '../time_machine_testing.dart';
import 'dtz_io_helper.dart';

void main() {
  test('Valid', Valid);
  parameterizedTest(
      'LatitudeRange', [-90 * 3600 - 1, 90 * 3600 + 1], LatitudeRange,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'LongitudeRange', [-180 * 3600 - 1, 180 * 3600 + 1], LongitudeRange,
      customDescriptionBuilder: describeArguments);
  test('Constructor_InvalidArguments', Constructor_InvalidArguments);
  test('Serialization', Serialization);
  test('ReadInvalid', ReadInvalid);
}

TzdbZoneLocation _create(
        {int latitudeSeconds = 0,
        int longitudeSeconds = 0,
        String countryName = 'Country name',
        String countryCode = 'CO'}) =>
    TzdbZoneLocation(latitudeSeconds, longitudeSeconds, countryName,
        countryCode, 'Etc/MadeUpZone', 'Comment');

void Valid() {
  var location = TzdbZoneLocation(
      60 * 3600 + 15 * 60 + 5,
      100 * 3600 + 30 * 60 + 10,
      'Country name',
      'CO',
      'Etc/MadeUpZone',
      'Comment');
  expect(location.latitude, closeTo(60.25 + 5.0 / 3600, 0.000001));
  expect(location.longitude, closeTo(100.5 + 10.0 / 3600, 0.000001));
  expect(location.countryName, 'Country name');
  expect(location.countryCode, 'CO');
  expect(location.zoneId, 'Etc/MadeUpZone');
  expect(location.comment, 'Comment');
}

void LatitudeRange(int invalidValue) {
  expect(() => _create(latitudeSeconds: invalidValue), throwsRangeError);
  // We'll assume these are built correctly: we're just checking the range
  // limits are inclusive.
  _create(latitudeSeconds: 90 * 3600);
  _create(latitudeSeconds: -90 * 3600);
}

void LongitudeRange(int invalidValue) {
  expect(() => _create(longitudeSeconds: invalidValue), throwsRangeError);
  _create(longitudeSeconds: 180 * 3600);
  _create(longitudeSeconds: -180 * 3600);
}

void Constructor_InvalidArguments() {
  expect(() => _create(countryName: ''), throwsArgumentError);
  expect(() => _create(countryCode: 'Long code'), throwsArgumentError);
  expect(() => _create(countryCode: ''), throwsArgumentError);
}

void Serialization() {
  var location = TzdbZoneLocation(
      60 * 3600 + 15 * 60 + 5,
      100 * 3600 + 30 * 60 + 10,
      'Country name',
      'CO',
      'Etc/MadeUpZone',
      'Comment');

  var dio = DtzIoHelper.noStringPool();
  location.write(dio.writer);
  var location2 = TzdbZoneLocation.read(dio.reader);
  expect(dio.reader.hasMoreData, isFalse);

  expect(location2.countryName, location.countryName);
  expect(location2.countryCode, location.countryCode);
  expect(location2.zoneId, location.zoneId);
  expect(location2.comment, location.comment);
  expect(location2.latitude, location.latitude);
  expect(location2.longitude, location.longitude);
}

void ReadInvalid() {
  var dio = DtzIoHelper.noStringPool();
  // This is invalid
  dio.writer.writeSignedCount(90 * 3600 + 1);
  dio.writer.writeSignedCount(0);
  dio.writer.writeString('name');
  dio.writer.writeString('co');
  dio.writer.writeString('Europe/Somewhere');
  dio.writer.writeString('');
  expect(() => TzdbZoneLocation.read(dio.reader),
      throwsA(isA<InvalidTimeDataError>()));
}
