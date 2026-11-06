// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';

import '../time_machine_testing.dart';

void main() {
  parameterizedTest('ValidateStartOfYear1Days', AllCalculators.toList(),
      ValidateStartOfYear1Days,
      customDescriptionBuilder: describeArguments);
  parameterizedTest('GetYearConsistentWithGetYearDays', AllCalculators.toList(),
      GetYearConsistentWithGetYearDays,
      customDescriptionBuilder: describeArguments);
}

// Here the term 'Islamic' only refers to whether the implementation is IslamicYearMonthDayCalculator,
// not whether the calendar itself is based on Islamic scripture.
List<Object> NonIslamicCalculators = [
  GregorianYearMonthDayCalculator()
      .options(customDescriptionBuilder: (_, __, ___) => 'Gregorian'),
  CopticYearMonthDayCalculator()
      .options(customDescriptionBuilder: (_, __, ___) => 'Coptic'),
  JulianYearMonthDayCalculator()
      .options(customDescriptionBuilder: (_, __, ___) => 'Julian'),
  HebrewYearMonthDayCalculator(HebrewMonthNumbering.civil)
      .options(customDescriptionBuilder: (_, __, ___) => 'HebrewCivil'),
  HebrewYearMonthDayCalculator(HebrewMonthNumbering.scriptural)
      .options(customDescriptionBuilder: (_, __, ___) => 'HebrewScriptural'),
  PersianSimple()
      .options(customDescriptionBuilder: (_, __, ___) => 'PersianSimple'),
  PersianArithmetic()
      .options(customDescriptionBuilder: (_, __, ___) => 'PersianArithmetic'),
  PersianAstronomical()
      .options(customDescriptionBuilder: (_, __, ___) => 'PersianAstronomical'),
  UmAlQuraYearMonthDayCalculator()
      .options(customDescriptionBuilder: (_, __, ___) => 'UmAlQura'),
];

List<Object> IslamicCalculators = [
  for (var epoch in IslamicEpoch.values)
    for (var leapYearPattern in IslamicLeapYearPattern.values)
      IslamicYearMonthDayCalculator(leapYearPattern, epoch).options(
          customDescriptionBuilder: (_, __, ___) =>
              'Islamic;${epoch.name};${leapYearPattern.name}')
];

Iterable<Object> AllCalculators =
    [NonIslamicCalculators, IslamicCalculators].expand((x) => x);

// Note for tests using TestCaseSource:
// We can't make the parameter of type YearMonthDayCalculator, because that's internal.
// We can't make the method internal, as then it isn't a test. Casting is all we've got.

void ValidateStartOfYear1Days(Object calculatorAsObject) {
  var calculator = calculatorAsObject as YearMonthDayCalculator;
  // Some calendars (e.g. Um Al Qura) don't support year 1, so the DaysAtStartOfYear1
  // is somewhat theoretical. (It's still used in such calendars, but only to get a guess
  // as to a year number given a day number.)
  if (calculator.minYear > 1 || calculator.maxYear < 0) {
    return;
  }
  expect(calculator.getStartOfYearInDays(1), calculator.daysAtStartOfYear1);
}

void GetYearConsistentWithGetYearDays(Object calculatorAsObject) {
  var calculator = calculatorAsObject as YearMonthDayCalculator;
  for (int year = calculator.minYear; year <= calculator.maxYear; year++) {
    int startOfYearDays = calculator.getStartOfYearInDays(year);

    var tmp = calculator.getYear(startOfYearDays);
    var yearCandidate = tmp[0];
    var dayOfYear = tmp[1];
    expect(yearCandidate, year, reason: 'Start of year $year');
    expect(dayOfYear, 0); // Zero-based...

    tmp = calculator.getYear(startOfYearDays - 1);
    yearCandidate = tmp[0];
    dayOfYear = tmp[1];
    expect(yearCandidate, year - 1, reason: 'End of year ${year - 1}');
    expect(calculator.getDaysInYear(year - 1) - 1, dayOfYear);
  }
}
