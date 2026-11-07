// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2013 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Port of Noda Time's NodaTime.Test/Testing/TimeZones/FakeDateTimeZoneSourceTest.cs.
//
// Noda Time maps TimeZoneInfo.Local's ID through the builder's
// BclIdsToZoneIds; the Dart builder has a systemDefaultId property instead,
// so ValidWindowsMapping and InvalidWindowsMapping_MissingZone test that.
// Not ported (Dart is null-safe, so nulls can't be passed):
// NullZoneViaCollectionInitializer, NullZoneViaProperty and
// InvalidWindowsMapping_NullCanonicalId. The builder isn't iterable (Noda
// Time's builder is IEnumerable only for collection initializers), so
// GetEnumerator tests its zones list instead.
import 'package:test/test.dart';
import 'package:time_machine2/testing.dart';
import 'package:time_machine2/time_machine2.dart';

void main() {
  test('Ids', Ids);
  test('ForId_Present', ForId_Present);
  test('ForId_Missing', ForId_Missing);
  test('DuplicateIds', DuplicateIds);
  test('ValidWindowsMapping', ValidWindowsMapping);
  test('InvalidWindowsMapping_MissingZone', InvalidWindowsMapping_MissingZone);
  test('GetEnumerator', GetEnumerator);
  test('NoSystemDefaultId', NoSystemDefaultId);
  test('VersionId', VersionId);
  test('ToProvider', ToProvider);
}

// We don't care about the details of the time zones, just the IDs
DateTimeZone _createZone(String id) => SingleTransitionDateTimeZone(
    Instant.unixEpoch, Offset.hours(1), Offset.hours(2), id);

Future<void> Ids() async {
  var source = (FakeDateTimeZoneSourceBuilder()
        ..add(_createZone('x'))
        ..add(_createZone('y'))
        ..add(_createZone('a'))
        ..add(_createZone('b')))
      .build();
  expect(await source.getIds(), unorderedEquals(['x', 'y', 'a', 'b']));
}

Future<void> ForId_Present() async {
  var zone = _createZone('x');
  var source = FakeDateTimeZoneSourceBuilder(
      // The "right" one and some others
      [zone, _createZone('y'), _createZone('a'), _createZone('b')]).build();
  expect(await source.forId('x'), same(zone));
  expect(source.forCachedId('x'), same(zone));
}

void ForId_Missing() {
  var source =
      FakeDateTimeZoneSourceBuilder([_createZone('x'), _createZone('y')])
          .build();
  expect(() => source.forId('missing'), throwsArgumentError);
  expect(() => source.forCachedId('missing'), throwsArgumentError);
}

void DuplicateIds() {
  var builder = FakeDateTimeZoneSourceBuilder(
      [_createZone('x'), _createZone('y'), _createZone('x')]);
  _assertBuildFails(builder);
}

/// Noda Time maps the local BCL ID to "x"; here the builder names "x" as the
/// system default directly.
void ValidWindowsMapping() {
  var source = (FakeDateTimeZoneSourceBuilder()
        ..systemDefaultId = 'x'
        ..zones.addAll([_createZone('x'), _createZone('y')]))
      .build();
  expect(source.systemDefaultId, 'x');
}

void InvalidWindowsMapping_MissingZone() {
  var builder = FakeDateTimeZoneSourceBuilder()
    ..systemDefaultId = 'z'
    ..zones.addAll([_createZone('x'), _createZone('y')]);
  _assertBuildFails(builder);
}

void GetEnumerator() {
  var x = _createZone('x');
  var y = _createZone('y');
  var builder = FakeDateTimeZoneSourceBuilder()..zones.addAll([x, y]);
  expect(builder.zones, [x, y]);
}

/// Not in Noda Time: with no system default ID (Noda Time's LocalZoneIsNull
/// case), the source reports none.
void NoSystemDefaultId() {
  var source = FakeDateTimeZoneSourceBuilder([_createZone('x')]).build();
  expect(source.systemDefaultId, isNull);
}

/// Not in Noda Time: the version ID is "TestZones" unless the builder sets it.
void VersionId() {
  expect(FakeDateTimeZoneSourceBuilder().build().versionId, 'TestZones');
  expect(
      (FakeDateTimeZoneSourceBuilder()..versionId = 'Custom').build().versionId,
      'Custom');
}

/// Not in Noda Time: toProvider creates a provider backed by the source.
Future<void> ToProvider() async {
  var x = _createZone('x');
  var source = (FakeDateTimeZoneSourceBuilder([x, _createZone('y')])
        ..systemDefaultId = 'x')
      .build();
  var provider = await source.toProvider();
  expect(provider.versionId, 'TestZones');
  expect(provider.ids, ['x', 'y']);
  expect(await provider['x'], same(x));
  expect(await provider.getSystemDefault(), same(x));
}

// We don't really care how it fails - just that an error is thrown.
void _assertBuildFails(FakeDateTimeZoneSourceBuilder builder) {
  expect(builder.build, throwsA(anything));
}
