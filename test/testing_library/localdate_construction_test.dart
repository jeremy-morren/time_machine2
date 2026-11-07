// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2016 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Port of Noda Time's NodaTime.Test/Testing/Extensions/LocalDateConstructionTest.cs.
import 'package:test/test.dart';
import 'package:time_machine2/testing.dart';
import 'package:time_machine2/time_machine2.dart';

void main() {
  test('Construction', Construction);
}

void Construction() {
  expect(18.january(2017), LocalDate(2017, 1, 18));
  expect(18.february(2017), LocalDate(2017, 2, 18));
  expect(18.march(2017), LocalDate(2017, 3, 18));
  expect(18.april(2017), LocalDate(2017, 4, 18));
  expect(18.may(2017), LocalDate(2017, 5, 18));
  expect(18.june(2017), LocalDate(2017, 6, 18));
  expect(18.july(2017), LocalDate(2017, 7, 18));
  expect(18.august(2017), LocalDate(2017, 8, 18));
  expect(18.september(2017), LocalDate(2017, 9, 18));
  expect(18.october(2017), LocalDate(2017, 10, 18));
  expect(18.november(2017), LocalDate(2017, 11, 18));
  expect(18.december(2017), LocalDate(2017, 12, 18));
}
