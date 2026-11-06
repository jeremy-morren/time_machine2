// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

//import 'package:time_machine2/src/time_machine_internal.dart';

//import 'package:test/test.dart';
//import 'package:matcher/matcher.dart';

import 'package:test/test.dart';

void main() {
  test('UnsupportedCalendarWeekRule', UnsupportedCalendarWeekRule,
      skip: 'Not applicable: Dart enums cannot hold out-of-range values');
}

void UnsupportedCalendarWeekRule() {
// expect(() => WeekYearRules.FromCalendarWeekRule(CalendarWeekRule.FirstDay + 1000, DayOfWeek.Monday), throwsArgumentError);
// expect(() => WeekYearRules.FromCalendarWeekRule(CalendarWeekRule.FirstDay, IsoDayOfWeek.monday), throwsArgumentError);
}
