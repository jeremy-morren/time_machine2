// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';

import '../time_machine_testing.dart';

void main() {
  test('Value_Success', Value_Success);
  test('Value_Failure', Value_Failure);
  test('Exception_Success', Exception_Success);
  test('Exception_Failure', Exception_Failure);
  test('GetValueOrThrow_Success', GetValueOrThrow_Success);
  test('GetValueOrThrow_Failure', GetValueOrThrow_Failure);
  test('TryGetValue_Success', TryGetValue_Success);
  test('TryGetValue_Failure', TryGetValue_Failure);
  test('Convert_ForFailureResult', Convert_ForFailureResult);
  test('Convert_ForSuccessResult', Convert_ForSuccessResult);
  test('ConvertError_ForFailureResult', ConvertError_ForFailureResult);
  test('ConvertError_ForSuccessResult', ConvertError_ForSuccessResult);
  test('ForException', ForException);
  test('UnparsableValueObsoleteConstructors',
      UnparsableValueObsoleteConstructors);
  parameterizedTest(
      'PatternFailure_ValueAndIndex',
      [
        // Mismatched number: the index is the start of the month field.
        ['2011-1x-05', 5],
        // Extra characters at the end.
        ['2011-02-05x', 10],
        // Invalid day-of-month is detected after parsing, so there's no index.
        ['2011-02-30', -1],
      ],
      PatternFailure_ValueAndIndex,
      customDescriptionBuilder: describeArguments);
}

final ParseResult<int> _failureResult =
    IParseResult.forInvalidValue<int>(ValueCursor('text'), "text");

void Value_Success() {
  ParseResult<int> result = ParseResult.forValue<int>(5);
  expect(5, result.value);
}

void Value_Failure() {
  expect(
      () => _failureResult.value.hashCode, willThrow<UnparsableValueError>());
  var error = _catchUnparsable(() => _failureResult.value.hashCode);
  expect(error.value, 'text');
  expect(error.index, -1);
}

void Exception_Success() {
  ParseResult<int> result = ParseResult.forValue<int>(5);
  expect(() => result.error.hashCode, throwsStateError);
}

void Exception_Failure() {
  // Assert.IsInstanceOf<UnparsableValueError>(FailureResult.Exception);
  expect(_failureResult.error, const TypeMatcher<UnparsableValueError>());
  expect((_failureResult.error as UnparsableValueError).value, 'text');
  expect((_failureResult.error as UnparsableValueError).index, -1);
}

void GetValueOrThrow_Success() {
  ParseResult<int> result = ParseResult.forValue<int>(5);
  expect(5, result.getValueOrThrow());
}

void GetValueOrThrow_Failure() {
  expect(() => _failureResult.getValueOrThrow(),
      willThrow<UnparsableValueError>());
  var error = _catchUnparsable(() => _failureResult.getValueOrThrow());
  expect(error.value, 'text');
  expect(error.index, -1);
}

void TryGetValue_Success() {
  ParseResult<int> result = ParseResult.forValue<int>(5);
  //expect(result.TryGetValue(-1, out int actual), isTrue);
  int actual;
  expect(actual = result.TryGetValue(-1), isNot(-1));
  expect(5, actual);
}

void TryGetValue_Failure() {
// expect(FailureResult.TryGetValue(-1, out int actual), isFalse);

  int actual;
  expect(actual = _failureResult.TryGetValue(-1), -1);
  expect(-1, actual);
}

void Convert_ForFailureResult() {
  ParseResult<String> converted = _failureResult.convert((x) => 'xx${x}xx');
  expect(() => converted.getValueOrThrow(), willThrow<UnparsableValueError>());
  var error = _catchUnparsable(() => converted.getValueOrThrow());
  expect(error.value, 'text');
  expect(error.index, -1);
}

void Convert_ForSuccessResult() {
  ParseResult<int> original = ParseResult.forValue<int>(10);
  ParseResult<String> converted = original.convert((x) => 'xx${x}xx');
  expect('xx10xx', converted.value);
}

void ConvertError_ForFailureResult() {
  ParseResult<String> converted = _failureResult.convertError<String>();
  expect(() => converted.getValueOrThrow(), willThrow<UnparsableValueError>());
  var error = _catchUnparsable(() => converted.getValueOrThrow());
  expect(error.value, 'text');
  expect(error.index, -1);
}

void ConvertError_ForSuccessResult() {
  ParseResult<int> original = ParseResult.forValue<int>(10);
  expect(() => original.convertError<String>(), throwsStateError);
}

void ForException() {
  Error e = Error();
  ParseResult<int> result = ParseResult.forError<int>(() => e);
  expect(result.success, isFalse);
  expect(identical(e, result.error), isTrue);
}

// From Noda Time's ExceptionConstructorTests.UnparsableValueObsoleteConstructors: an
// UnparsableValueError created with just a message has an empty value and an index of -1.
void UnparsableValueObsoleteConstructors() {
  var error = UnparsableValueError('message');
  expect(error.value, isEmpty);
  expect(error.index, -1);
}

// Not a Noda Time test: checks that real pattern failures populate value and index as
// Noda Time does - the whole text, and the cursor index where parsing failed (or -1
// when the failure is detected after parsing).
void PatternFailure_ValueAndIndex(String text, int expectedIndex) {
  var result = LocalDatePattern.iso.parse(text);
  expect(result.success, isFalse);
  var error = result.error as UnparsableValueError;
  expect(error.value, text);
  expect(error.index, expectedIndex);
}

UnparsableValueError _catchUnparsable(void Function() action) {
  try {
    action();
  } on UnparsableValueError catch (e) {
    return e;
  }
  fail('Expected UnparsableValueError');
}
