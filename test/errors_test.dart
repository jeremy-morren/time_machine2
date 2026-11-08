// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';
import 'package:time_machine2/src/text/invalid_pattern_error.dart';
import 'package:time_machine2/time_machine2.dart';

/// Tests for the library's error types, the equivalents of Noda Time's
/// exception classes.
void main() {
  test('UnparsableValueError', UnparsableValueError_Properties);
  test('UnparsableValueError_Defaults', UnparsableValueError_Defaults);
  test('InvalidPatternError', InvalidPatternError_Properties);
  test('InvalidPatternError_Format', InvalidPatternError_Format);
  test('DateTimeZoneNotFoundError', DateTimeZoneNotFoundError_Properties);
  test('InvalidDateTimeZoneSourceError',
      InvalidDateTimeZoneSourceError_Properties);
  test('InvalidTimeDataError', InvalidTimeDataError_Properties);
  test('InvalidTimeDataError_WithCause', InvalidTimeDataError_WithCause);
}

void UnparsableValueError_Properties() {
  var error = UnparsableValueError('Bad value', value: 'abc', index: 1);
  expect(error, isA<Error>());
  expect(error.message, 'Bad value');
  expect(error.value, 'abc');
  expect(error.index, 1);
  expect(error.toString(), 'Bad value');
}

void UnparsableValueError_Defaults() {
  var error = UnparsableValueError('Bad value');
  expect(error.value, '');
  expect(error.index, -1);
}

void InvalidPatternError_Properties() {
  var error = InvalidPatternError('Bad pattern');
  expect(error, isA<Error>());
  expect(error.message, 'Bad pattern');
  expect(error.toString(), 'InvalidPatternError: Bad pattern');
}

void InvalidPatternError_Format() {
  var error = IInvalidPatternError.format('{0} then {1}', ['x', 2]);
  expect(error.message, 'x then 2');
  expect(error.toString(), 'InvalidPatternError: x then 2');
}

void DateTimeZoneNotFoundError_Properties() {
  var error = DateTimeZoneNotFoundError('No zone');
  expect(error, isA<Error>());
  expect(error.message, 'No zone');
  expect(error.toString(), 'No zone');
}

void InvalidDateTimeZoneSourceError_Properties() {
  var error = InvalidDateTimeZoneSourceError('Bad source');
  expect(error, isA<Error>());
  expect(error.message, 'Bad source');
  expect(error.toString(), 'Bad source');
}

void InvalidTimeDataError_Properties() {
  var error = InvalidTimeDataError('Bad data');
  expect(error, isA<Error>());
  expect(error.message, 'Bad data');
  expect(error.error, isNull);
  expect(error.toString(), 'Bad data');
}

void InvalidTimeDataError_WithCause() {
  var cause = ArgumentError('inner');
  var error = InvalidTimeDataError('Bad data', cause);
  expect(identical(error.error, cause), isTrue);
  expect(error.toString(), 'Bad data\n$cause');
}
