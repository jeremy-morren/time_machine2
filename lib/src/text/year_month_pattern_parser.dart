// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2019 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Parser for patterns of [YearMonth] values.
@internal
class YearMonthPatternParser implements IPatternParser<YearMonth> {
  final YearMonth _templateValue;
  final int _twoDigitYearMax;

  static final Map<String, CharacterHandler<YearMonth, YearMonthParseBucket>>
      _patternCharacterHandlers = {
    '%': SteppedPatternBuilder.handlePercent,
    '\'': SteppedPatternBuilder.handleQuote,
    '"': SteppedPatternBuilder.handleQuote,
    '\\': SteppedPatternBuilder.handleBackslash,
    '/': (pattern, builder) => builder.addLiteral1(
        builder.formatInfo.dateSeparator, IParseResult.dateSeparatorMismatch),
    'y': DatePatternHelper.createYearOfEraHandler<YearMonth,
            YearMonthParseBucket>((value) => value.yearOfEra,
        (bucket, value) => bucket.dateBucket.yearOfEra = value),
    'u': SteppedPatternBuilder.handlePaddedField<YearMonth,
            YearMonthParseBucket>(
        4,
        PatternFields.year,
        -9998,
        9999,
        (value) => value.year,
        (bucket, value) => bucket.dateBucket.year = value),
    'M': DatePatternHelper.createMonthOfYearHandler<YearMonth,
            YearMonthParseBucket>(
        (value) => value.month,
        (bucket, value) => bucket.dateBucket.monthOfYearText = value,
        (bucket, value) => bucket.dateBucket.monthOfYearNumeric = value),
    'c': DatePatternHelper.createCalendarHandler<YearMonth,
            YearMonthParseBucket>((value) => value.calendar,
        (bucket, value) => bucket.dateBucket.calendar = value),
    'g': DatePatternHelper.createEraHandler<YearMonth, YearMonthParseBucket>(
        (value) => value.era, (bucket) => bucket.dateBucket),
  };

  /// * [twoDigitYearMax]: Maximum two-digit-year in the template to treat as
  ///   the current century, in the range 0-99 inclusive.
  YearMonthPatternParser(this._templateValue,
      [this._twoDigitYearMax = LocalDatePatterns.defaultTwoDigitYearMax]) {
    Preconditions.checkArgumentRange(
        'twoDigitYearMax', _twoDigitYearMax, 0, 99);
  }

  @override
  IPattern<YearMonth> parsePattern(
      String patternText, TimeMachineFormatInfo formatInfo) {
    // Nullity check is performed in YearMonthPattern.
    if (patternText.isEmpty) {
      throw InvalidPatternError(TextErrorMessages.formatStringEmpty);
    }

    if (patternText.length == 1) {
      switch (patternText) {
        // Invariant standard patterns return cached implementations.
        case 'g':
          return YearMonthPatterns.isoPatternImpl;
        // Noda Time's 'G' is the culture's year/month pattern, which Time
        // Machine's culture data doesn't have.
        default:
          throw IInvalidPatternError.format(
              TextErrorMessages.unknownStandardFormat,
              [patternText, 'YearMonth']);
      }
    }

    var patternBuilder = SteppedPatternBuilder<YearMonth, YearMonthParseBucket>(
        formatInfo,
        () => YearMonthParseBucket(_templateValue, _twoDigitYearMax));
    patternBuilder.parseCustomPattern(patternText, _patternCharacterHandlers);
    patternBuilder.validateUsedFields();
    return patternBuilder.build(_templateValue);
  }
}

/// Bucket to put parsed values in, ready for later result calculation: the
/// values are parsed into a [LocalDateParseBucket] for the first day of the
/// month.
@internal
class YearMonthParseBucket extends ParseBucket<YearMonth> {
  final LocalDateParseBucket dateBucket;

  YearMonthParseBucket(YearMonth templateValue, int twoDigitYearMax)
      : dateBucket = LocalDateParseBucket(
            IYearMonth.startDate(templateValue), twoDigitYearMax);

  @override
  ParseResult<YearMonth> calculateValue(PatternFields usedFields, String text) {
    var result = dateBucket.calculateValueFor(usedFields, text, 'YearMonth');
    if (!result.success) {
      return result.convertError<YearMonth>();
    }
    return ParseResult.forValue<YearMonth>(result.value.toYearMonth());
  }
}
