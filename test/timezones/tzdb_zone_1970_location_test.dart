// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// The bundled TZDB data doesn't include zone1970 location information at
// this time, but the type (and its serialization) is tested as in Noda Time.

import 'package:parameterized_test/parameterized_test.dart';
import 'package:test/test.dart';
import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/tzdb_zone_1970_location.dart';

import '../time_machine_testing.dart';
import 'dtz_io_helper.dart';

final TzdbZone1970LocationCountry SampleCountry =
    TzdbZone1970LocationCountry('Country name', 'CO');

void main() {
  test('Valid', Valid);
  parameterizedTest(
      'LatitudeRange', [-90 * 3600 - 1, 90 * 3600 + 1], LatitudeRange,
      customDescriptionBuilder: describeArguments);
  parameterizedTest(
      'LongitudeRange', [-180 * 3600 - 1, 180 * 3600 + 1], LongitudeRange,
      customDescriptionBuilder: describeArguments);
  test('Constructor_InvalidArguments', Constructor_InvalidArguments);
  test('Country_InvalidArguments', Country_InvalidArguments);
  test('Country_Equality', Country_Equality);
  test('Country_ToString', Country_ToString);
  test('Serialization', Serialization);
  test('ReadInvalid', ReadInvalid);
}

TzdbZone1970Location _create(
        {int latitudeSeconds = 0,
        int longitudeSeconds = 0,
        List<TzdbZone1970LocationCountry>? countries}) =>
    TzdbZone1970Location(latitudeSeconds, longitudeSeconds,
        countries ?? [SampleCountry], 'Etc/MadeUpZone', 'Comment');

void Valid() {
  var location = TzdbZone1970Location(60 * 3600 + 15 * 60 + 5,
      100 * 3600 + 30 * 60 + 10, [SampleCountry], 'Etc/MadeUpZone', 'Comment');
  expect(location.latitude, closeTo(60.25 + 5.0 / 3600, 0.000001));
  expect(location.longitude, closeTo(100.5 + 10.0 / 3600, 0.000001));
  expect(location.countries, [SampleCountry]);
  expect(location.zoneId, 'Etc/MadeUpZone');
  expect(location.comment, 'Comment');
  // The countries can't be changed through the location.
  expect(() => location.countries.add(SampleCountry), throwsUnsupportedError);
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
  expect(() => TzdbZone1970Location(0, 0, null, 'Etc/MadeUpZone', 'Comment'),
      throwsArgumentError);
  expect(() => _create(countries: []), throwsArgumentError);
}

void Country_InvalidArguments() {
  expect(() => TzdbZone1970LocationCountry('', 'CO'), throwsArgumentError);
  expect(() => TzdbZone1970LocationCountry('Name', 'S'), throwsArgumentError);
  expect(() => TzdbZone1970LocationCountry('Name', 'S!!'), throwsArgumentError);
}

void Country_Equality() {
  var equal1 = TzdbZone1970LocationCountry('France', 'FR');
  var equal2 = TzdbZone1970LocationCountry('France', 'FR');
  var unequal1 = TzdbZone1970LocationCountry('France', 'FG');
  var unequal2 = TzdbZone1970LocationCountry('Germany', 'FR');
  TestHelper.TestEqualsClass(equal1, equal2, [unequal1]);
  TestHelper.TestEqualsClass(equal1, equal2, [unequal2]);
  expect(equal1.equals(equal2), isTrue);
  expect(equal1.equals(unequal1), isFalse);
  expect(equal1.equals(unequal2), isFalse);
}

void Country_ToString() {
  expect(TzdbZone1970LocationCountry('France', 'FR').toString(), 'FR (France)');
}

void Serialization() {
  var location = TzdbZone1970Location(
      60 * 3600 + 15 * 60 + 5,
      100 * 3600 + 30 * 60 + 10,
      [SampleCountry, TzdbZone1970LocationCountry('Another country', 'AC')],
      'Etc/MadeUpZone',
      'Comment');

  var dio = DtzIoHelper.noStringPool();
  location.write(dio.writer);
  var location2 = TzdbZone1970Location.read(dio.reader);
  expect(dio.reader.hasMoreData, isFalse);

  expect(location2.countries, location.countries);
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
  dio.writer.writeCount(1);
  dio.writer.writeString('name');
  dio.writer.writeString('co');
  dio.writer.writeString('Europe/Somewhere');
  dio.writer.writeString('');
  expect(() => TzdbZone1970Location.read(dio.reader),
      throwsA(isA<InvalidTimeDataError>()));
}
