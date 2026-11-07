// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2019 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';

import '../time_machine_testing.dart';
import 'pattern_test_base.dart';
import 'pattern_test_data.dart';
import 'test_cultures.dart';

void main() {
  group('YearMonthPatternTest', () {
    final fixture = YearMonthPatternTest();
    test('CreateWithCurrentCulture', fixture.CreateWithCurrentCulture);
    test('CreateWithSpecificCulture', fixture.CreateWithSpecificCulture);
    test('CreateWithTemplateValue', fixture.CreateWithTemplateValue);
    // ParseNull isn't ported: Dart's non-nullable String parameter means a
    // null can't be passed to parse.
    parameterizedTest(
        'WithTwoDigitYearMax',
        [
          [0, '00-01', 2000],
          [0, '01-01', 1901],
          [50, '49-01', 2049],
          [50, '50-01', 2050],
          [50, '51-01', 1951],
          [99, '00-01', 2000],
          [99, '99-01', 2099],
        ],
        fixture.WithTwoDigitYearMax,
        customDescriptionBuilder: describeArguments);
    parameterizedTest(
        'WithTwoDigitYearMax_Invalid',
        [-1, 100, Platform.int32MinValue, Platform.int32MaxValue],
        fixture.WithTwoDigitYearMax_Invalid,
        customDescriptionBuilder: describeArguments);
    parameterizedTest(
        'InvalidPatterns', fixture.InvalidPatternData, fixture.InvalidPatterns,
        customDescriptionBuilder: describeArguments);
    parameterizedTest(
        'ParseFailures', fixture.ParseFailureData, fixture.ParseFailures,
        customDescriptionBuilder: describeArguments);
    parameterizedTest('Parse', fixture.ParseData.toList(), fixture.Parse,
        customDescriptionBuilder: describeArguments);
    parameterizedTest('Format', fixture.FormatData.toList(), fixture.Format,
        customDescriptionBuilder: describeArguments);
    parameterizedTest(
        'AppendFormat', fixture.FormatData.toList(), fixture.AppendFormat,
        customDescriptionBuilder: describeArguments);
  });
}

class YearMonthPatternTest extends PatternTestBase<YearMonth> {
  @internal
  final List<Data> InvalidPatternData = [
    Data()
      ..pattern = ''
      ..message = TextErrorMessages.formatStringEmpty,
    Data()
      ..pattern = '!'
      ..message = TextErrorMessages.unknownStandardFormat
      ..parameters.addAll(['!', 'YearMonth']),
    Data()
      ..pattern = '%'
      ..message = TextErrorMessages.unknownStandardFormat
      ..parameters.addAll(['%', 'YearMonth']),
    Data()
      ..pattern = "\\"
      ..message = TextErrorMessages.unknownStandardFormat
      ..parameters.addAll(['\\', 'YearMonth']),
    // Noda Time's 'G' standard pattern (the culture's year/month pattern) isn't
    // supported: Time Machine's culture data has no year/month pattern.
    Data()
      ..pattern = 'G'
      ..message = TextErrorMessages.unknownStandardFormat
      ..parameters.addAll(['G', 'YearMonth']),
    Data()
      ..pattern = '%%'
      ..message = TextErrorMessages.percentDoubled,
    Data()
      ..pattern = "%\\"
      ..message = TextErrorMessages.escapeAtEndOfString,
    Data()
      ..pattern = 'MMMMM'
      ..message = TextErrorMessages.repeatCountExceeded
      ..parameters.addAll(['M', 4]),
    Data()
      ..pattern = 'M%'
      ..message = TextErrorMessages.percentAtEndOfString,
    Data()
      ..pattern = 'yyyyy'
      ..message = TextErrorMessages.repeatCountExceeded
      ..parameters.addAll(['y', 4]),
    Data()
      ..pattern = 'uuuuu'
      ..message = TextErrorMessages.repeatCountExceeded
      ..parameters.addAll(['u', 4]),
    Data()
      ..pattern = 'ggg'
      ..message = TextErrorMessages.repeatCountExceeded
      ..parameters.addAll(['g', 2]),
    Data()
      ..pattern = "'qwe"
      ..message = TextErrorMessages.missingEndQuote
      ..parameters.addAll(['\'']),
    Data()
      ..pattern = "'qwe\\"
      ..message = TextErrorMessages.escapeAtEndOfString,
    Data()
      ..pattern = "'qwe\\'"
      ..message = TextErrorMessages.missingEndQuote
      ..parameters.addAll(['\'']),
    // Note incorrect use of 'u' (year) instead of 'y' (year of era)
    Data()
      ..pattern = 'MM uuuu gg'
      ..message = TextErrorMessages.eraWithoutYearOfEra,
    // Era specifier and calendar specifier in the same pattern.
    Data()
      ..pattern = 'MM yyyy gg c'
      ..message = TextErrorMessages.calendarAndEra,

    // Invalid patterns directly after the uuuu specifier. This will detect the issue early, but then
    // continue and reject it in the normal path.
    Data()
      ..pattern = "uuuu'"
      ..message = TextErrorMessages.missingEndQuote
      ..parameters.addAll(['\'']),
    Data()
      ..pattern = "uuuu\\"
      ..message = TextErrorMessages.escapeAtEndOfString,

    // Common typo, which is caught in 2.0...
    Data()
      ..pattern = 'uuuu-mm'
      ..message = TextErrorMessages.unquotedLiteral
      ..parameters.addAll(['m']),
    // T isn't valid in a year/month pattern
    Data()
      ..pattern = 'uuuu-MMT00:00:00'
      ..message = TextErrorMessages.unquotedLiteral
      ..parameters.addAll(['T']),

    // These became invalid in date patterns in v2.0, when we decided that y and yyy weren't sensible.
    Data()
      ..pattern = 'y M'
      ..message = TextErrorMessages.invalidRepeatCount
      ..parameters.addAll(['y', 1]),
    Data()
      ..pattern = 'yyy M'
      ..message = TextErrorMessages.invalidRepeatCount
      ..parameters.addAll(['y', 3]),
  ];

  @internal
  List<Data> ParseFailureData = [
    Data()
      ..pattern = 'yyyy gg'
      ..text = '2011 NodaEra'
      ..message = TextErrorMessages.mismatchedText
      ..parameters.addAll(['g']),
    Data()
      ..pattern = 'yyyy uuuu gg'
      ..text = '0010 0009 B.C.'
      ..message = TextErrorMessages.inconsistentValues2
      ..parameters.addAll(['g', 'u', 'YearMonth']),
    Data()
      ..pattern = 'uuuu MM MMMM'
      ..text = '2011 10 January'
      ..message = TextErrorMessages.inconsistentMonthTextValue,
    // Don't match a short name against a long pattern
    Data()
      ..pattern = 'uuuu MMMM'
      ..text = '2011 Oct'
      ..message = TextErrorMessages.mismatchedText
      ..parameters.addAll(['M']),
    // Or vice versa... although this time we match the 'Oct' and then fail as we're expecting a space
    Data()
      ..pattern = 'MMM uuuu'
      ..text = 'October 2011'
      ..message = TextErrorMessages.mismatchedCharacter
      ..parameters.addAll([' ']),

    // Invalid year-of-era/year, month
    Data()
      ..pattern = 'yyyy MM'
      ..text = '0000 01'
      ..message = TextErrorMessages.fieldValueOutOfRange
      ..parameters.addAll([0, 'y', 'YearMonth']),
    Data()
      ..pattern = 'yyyy MM'
      ..text = '2011 15'
      ..message = TextErrorMessages.monthOutOfRange
      ..parameters.addAll([15, 2011]),
    Data()
      ..pattern = 'uuuu MM'
      ..text = '2011 15'
      ..message = TextErrorMessages.monthOutOfRange
      ..parameters.addAll([15, 2011]),
    // Year of era can't be negative...
    Data()
      ..pattern = 'yyyy MM'
      ..text = '-15 01'
      ..message = TextErrorMessages.unexpectedNegative,

    // Year of era and two-digit year, but they don't match
    Data()
      ..pattern = 'yyyy uu'
      ..text = '2011 10'
      ..message = TextErrorMessages.inconsistentValues2
      ..parameters.addAll(['y', 'u', 'YearMonth']),

    // Invalid calendar name
    Data()
      ..pattern = 'c uuuu MM'
      ..text = '2015 01'
      ..message = TextErrorMessages.noMatchingCalendarSystem,

    // Invalid year
    Data()
      ..template = YearMonth(1, 1, CalendarSystem.islamicBcl)
      ..pattern = 'uuuu'
      ..text = '9999'
      ..message = TextErrorMessages.fieldValueOutOfRange
      ..parameters.addAll([9999, 'u', 'YearMonth']),
    Data()
      ..template = YearMonth(1, 1, CalendarSystem.islamicBcl)
      ..pattern = 'yyyy'
      ..text = '9999'
      ..message = TextErrorMessages.yearOfEraOutOfRange
      ..parameters.addAll([9999, 'EH', 'Hijri']),

    // https://github.com/nodatime/nodatime/issues/414
    Data()
      ..pattern = 'uuuu-MM'
      ..text = '1984-00'
      ..message = TextErrorMessages.fieldValueOutOfRange
      ..parameters.addAll([0, 'M', 'YearMonth']),
    Data()
      ..pattern = 'M/uuuu'
      ..text = '00/1984'
      ..message = TextErrorMessages.fieldValueOutOfRange
      ..parameters.addAll([0, 'M', 'YearMonth']),

    // Calendar ID parsing is now ordinal, case-sensitive
    Data.ym(2011, 10)
      ..pattern = 'uuuu MM c'
      ..text = '2011 10 iso'
      ..message = TextErrorMessages.noMatchingCalendarSystem,

    // Lower bound of ISO
    Data()
      ..pattern = 'uuuu-MM'
      ..text = '-9999-01'
      ..message = TextErrorMessages.fieldValueOutOfRange
      ..parameters.addAll([-9999, 'u', 'YearMonth']),
  ];

  @internal
  List<Data> ParseOnlyData = [
    // Alternative era names
    Data.ym(0, 10)
      ..pattern = 'yyyy MM gg'
      ..text = '0001 10 BCE',

    // Month parsing should be case-insensitive
    Data.ym(2011, 10)
      ..pattern = 'uuuu MMM'
      ..text = '2011 OcT',
    Data.ym(2011, 10)
      ..pattern = 'uuuu MMMM'
      ..text = '2011 OcToBeR',

    // Genitive name is an extension of the non-genitive name; parse longer first.
    Data.ym(2011, 1)
      ..pattern = 'uuuu MMMM'
      ..text = '2011 MonthName-Genitive'
      ..culture = TestCultures.GenitiveNameTestCultureWithLeadingNames,
    Data.ym(2011, 1)
      ..pattern = 'uuuu MMMM'
      ..text = '2011 MonthName'
      ..culture = TestCultures.GenitiveNameTestCultureWithLeadingNames,
    Data.ym(2011, 1)
      ..pattern = 'uuuu MMM'
      ..text = '2011 MN-Gen'
      ..culture = TestCultures.GenitiveNameTestCultureWithLeadingNames,
    Data.ym(2011, 1)
      ..pattern = 'uuuu MMM'
      ..text = '2011 MN'
      ..culture = TestCultures.GenitiveNameTestCultureWithLeadingNames,
  ];

  @internal
  List<Data> FormatOnlyData = [
    // Would parse back to 2011
    Data.ym(1811, 7)
      ..pattern = 'yy M'
      ..text = '11 7',
    // Tests for the documented 2-digit formatting of BC years
    // (Less of an issue since yy became 'year of era')
    Data.ym(-94, 7)
      ..pattern = 'yy M'
      ..text = '95 7',
    Data.ym(-93, 7)
      ..pattern = 'yy M'
      ..text = '94 7',
  ];

  @internal
  List<Data> FormatAndParseData = [
    // Standard patterns
    Data.ym(2011, 10)
      ..standardPattern = YearMonthPattern.iso
      ..standardPatternCode = 'YearMonthPattern.iso'
      ..pattern = 'g'
      ..text = '2011-10',

    // Custom patterns
    Data.ym(2011, 10)
      ..pattern = 'uuuu/MM'
      ..text = '2011/10',
    Data.ym(2011, 10)
      ..pattern = 'uuuu/MM'
      ..text = '2011-10'
      ..culture = TestCultures.FrCa,
    Data.ym(2011, 10)
      ..pattern = 'uuuuMM'
      ..text = '201110',
    Data.ym(2001, 7)
      ..pattern = 'yy M'
      ..text = '01 7',
    Data.ym(2011, 7)
      ..pattern = 'yy M'
      ..text = '11 7',
    Data.ym(2030, 7)
      ..pattern = 'yy M'
      ..text = '30 7',
    // Cutoff defaults to 30 (at the moment...)
    Data.ym(1931, 7)
      ..pattern = 'yy M'
      ..text = '31 7',
    Data.ym(1976, 7)
      ..pattern = 'yy M'
      ..text = '76 7',

    // In the first century, we don't skip back a century for "high" two-digit year numbers.
    Data.ym(25, 7)
      ..pattern = 'yy M'
      ..text = '25 7'
      ..template = YearMonth(50, 1),
    Data.ym(35, 7)
      ..pattern = 'yy M'
      ..text = '35 7'
      ..template = YearMonth(50, 1),

    Data.ym(2000, 10)
      ..pattern = 'MM'
      ..text = '10',
    Data.ym(1885, 10)
      ..pattern = 'MM'
      ..text = '10'
      ..template = YearMonth(1885, 10),

    // When we parse in all of the below tests, we'll use the month and day-of-month if it's provided;
    // the template value is specified to allow simple roundtripping. (Day of week doesn't affect what value is parsed; it just validates.)
    // Non-genitive month name when there's no "day of month", even if there's a "day of week"
    Data.ym(2011, 1)
      ..pattern = 'MMMM'
      ..text = 'FullNonGenName'
      ..culture = TestCultures.GenitiveNameTestCulture
      ..template = YearMonth(2011, 5),
    Data.ym(2011, 1)
      ..pattern = 'MMM'
      ..text = 'AbbrNonGenName'
      ..culture = TestCultures.GenitiveNameTestCulture
      ..template = YearMonth(2011, 5),

    // Era handling
    Data.ym(2011, 1)
      ..pattern = 'yyyy MM gg'
      ..text = '2011 01 A.D.',
    Data.ym(2011, 1)
      ..pattern = 'uuuu yyyy MM gg'
      ..text = '2011 2011 01 A.D.',
    Data.ym(-1, 1)
      ..pattern = 'yyyy MM gg'
      ..text = '0002 01 B.C.',

    // Month handling
    Data.ym(2011, 10)
      ..pattern = 'uuuu MMMM'
      ..text = '2011 October',
    Data.ym(2011, 10)
      ..pattern = 'uuuu MMM'
      ..text = '2011 Oct',

    // Year and two-digit year-of-era in the same format. Note that the year
    // gives the full year information, so we're not stuck in the 20th/21st century
    Data.ym(1825, 10)
      ..pattern = 'uuuu yy MM'
      ..text = '1825 25 10',

    // Negative years
    Data.ym(-43, 3)
      ..pattern = 'uuuu MM'
      ..text = '-0043 03',

    // Calendar handling
    Data.ym(2011, 10)
      ..pattern = 'c uuuu MM'
      ..text = 'ISO 2011 10',
    Data.ym(2011, 10)
      ..pattern = 'uuuu MM c'
      ..text = '2011 10 ISO',
    Data.ymc(2011, 10, CalendarSystem.coptic)
      ..pattern = 'c uuuu MM'
      ..text = 'Coptic 2011 10',
    Data.ymc(2011, 10, CalendarSystem.coptic)
      ..pattern = 'uuuu MM c'
      ..text = '2011 10 Coptic',

    Data.ymc(180, 15, CalendarSystem.badi)
      ..pattern = 'uuuu MM c'
      ..text = '0180 15 Badi',

    // 3 digit year patterns (odd, but valid)
    Data.ym(12, 1)
      ..pattern = 'uuu MM'
      ..text = '012 01',
    Data.ym(-12, 1)
      ..pattern = 'uuu MM'
      ..text = '-012 01',
    Data.ym(123, 1)
      ..pattern = 'uuu MM'
      ..text = '123 01',
    Data.ym(-123, 1)
      ..pattern = 'uuu MM'
      ..text = '-123 01',
    Data.ym(1234, 1)
      ..pattern = 'uuu MM'
      ..text = '1234 01',
    Data.ym(-1234, 1)
      ..pattern = 'uuu MM'
      ..text = '-1234 01',
  ];

  @internal
  Iterable<Data> get ParseData =>
      [ParseOnlyData, FormatAndParseData].expand((x) => x);

  @internal
  Iterable<Data> get FormatData =>
      [FormatOnlyData, FormatAndParseData].expand((x) => x);

  void CreateWithCurrentCulture() {
    var yearMonth = YearMonth(2017, 8);
    // using (CultureSaver.SetCultures(Cultures.EnUs))
    Culture.current = TestCultures.EnUs;
    var pattern = YearMonthPattern.createWithCurrentCulture('uuuu/MM');
    expect(pattern.format(yearMonth), '2017/08');

    // using (CultureSaver.SetCultures(Cultures.FrCa))
    Culture.current = TestCultures.FrCa;
    pattern = YearMonthPattern.createWithCurrentCulture('uuuu/MM');
    expect(pattern.format(yearMonth), '2017-08');
  }

  void CreateWithSpecificCulture() {
    var pattern =
        YearMonthPattern.createWithCulture('uuuu/MM', TestCultures.FrCa);
    expect(pattern.format(YearMonth(2017, 8)), '2017-08');
  }

  void CreateWithTemplateValue() {
    // This is testing the Create call specifying the template directly, instead of the WithTemplate method
    var template = YearMonth(2000, 6);
    var pattern =
        YearMonthPattern.createWithCulture('uuuu', Culture.invariant, template);
    expect(pattern.templateValue, template);
    var parseResult = pattern.parse('1990');
    expect(parseResult.success, isTrue);
    expect(parseResult.value, YearMonth(1990, 6));
  }

  void WithTwoDigitYearMax(int twoDigitYearMax, String text, int expectedYear) {
    var pattern = YearMonthPattern.createWithInvariantCulture('yy-MM')
        .withTwoDigitYearMax(twoDigitYearMax);
    var value = pattern.parse(text).value;
    expect(value.year, expectedYear);
  }

  void WithTwoDigitYearMax_Invalid(int twoDigitYearMax) {
    expect(() => YearMonthPattern.iso.withTwoDigitYearMax(twoDigitYearMax),
        throwsRangeError);
  }
}

class Data extends PatternTestData<YearMonth> {
  // Default to the start of the year 2000.
  @override
  YearMonth get defaultTemplate => YearMonthPatterns.defaultTemplateValue;

  /// Initializes a new instance of the [Data] class.
  ///
  /// [value]: The value.
  Data([YearMonth? value])
      : super(value ?? YearMonthPatterns.defaultTemplateValue);

  Data.ym(int year, int month) : super(YearMonth(year, month));

  Data.ymc(int year, int month, CalendarSystem calendar)
      : super(YearMonth(year, month, calendar));

  @internal
  @override
  IPattern<YearMonth> CreatePattern() =>
      YearMonthPattern.createWithInvariantCulture(super.pattern)
          .withTemplateValue(template)
          .withCulture(culture);
}
