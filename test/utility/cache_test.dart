// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/src/utility/cache.dart';

/// Tests for [Cache], as Noda Time's CacheTest.
void main() {
  test('Valid', Valid);
  test('Overflow', Overflow);
  test('TestInvalid', TestInvalid);
  test('Clear', Clear);
}

void Valid() {
  var cache = Cache<String, int>(10, int.parse);
  expect(cache.getOrAdd('5'), 5);
}

void Overflow() {
  // Use a small cache to make it easier to test. The value isn't used.
  var cache = Cache<String, int>(2, (x) => x.length);
  expect(cache.count, 0);
  cache.getOrAdd('Test');
  expect(cache.count, 1);
  cache.getOrAdd('Test');
  expect(cache.count, 1);
  cache.getOrAdd('Test2');
  expect(cache.count, 2);
  cache.getOrAdd('Test3');
  expect(cache.count, 2);
  // The oldest entry was evicted.
  expect(cache.keys, unorderedEquals(['Test2', 'Test3']));
}

void TestInvalid() {
  var cache = Cache<String, int>(10, int.parse);
  expect(() => cache.getOrAdd('Test'), throwsFormatException);
  expect(cache.count, 0);
  expect(cache.keys, isEmpty);
}

void Clear() {
  var cache = Cache<String, int>(10, int.parse);
  cache.getOrAdd('1');
  cache.getOrAdd('2');
  expect(cache.count, 2);
  cache.clear();
  expect(cache.count, 0);
  expect(cache.keys, isEmpty);
  // The cache still works after being cleared.
  expect(cache.getOrAdd('3'), 3);
  expect(cache.keys, ['3']);
}
