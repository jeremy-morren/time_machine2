// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Pattern parsing support for [Instant].
///
/// Supported standard patterns:
///  * g: general; the UTC ISO-8601 instant in the style uuuu-MM-ddTHH:mm:ssZ
@internal
class InstantPatternParser implements IPatternParser<Instant> {
  static const String generalPatternText = "uuuu'-'MM'-'dd'T'HH':'mm':'ss'Z'";
  static const String beforeMinValueText = 'StartOfTime';
  static const String afterMaxValueText = 'EndOfTime';

  /// The template value as a UTC local date/time, or null for the default
  /// template value.
  final LocalDateTime? _localTemplateValue;
  final int _twoDigitYearMax;

  /// * [templateValue]: The template value, or null for the default
  ///   (the start of the year 2000 in UTC).
  /// * [twoDigitYearMax]: Maximum two-digit-year in the template to treat as
  ///   the current century, in the range 0-99 inclusive.
  InstantPatternParser(
      [Instant? templateValue,
      this._twoDigitYearMax = LocalDatePatterns.defaultTwoDigitYearMax])
      : _localTemplateValue = templateValue?.inUtc().localDateTime {
    Preconditions.checkArgumentRange(
        'twoDigitYearMax', _twoDigitYearMax, 0, 99);
  }

  @override
  IPattern<Instant> parsePattern(
      String patternText, TimeMachineFormatInfo formatInfo) {
    Preconditions.checkNotNull(patternText, 'patternText');
    if (patternText.isEmpty) {
      throw InvalidPatternError(TextErrorMessages.formatStringEmpty);
    }

    // todo: I am unsure if this is a 'good' or a 'bad' thing -- this is obviously a 'windows' thing
    //    -- and I can't seem to find it backed up in a standard
    // https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
    if (patternText.length == 1) {
      switch (patternText[0]) {
        case 'g':
          patternText = generalPatternText;
          break;
        default:
          throw IInvalidPatternError.format(
              TextErrorMessages.unknownStandardFormat,
              [patternText[0], 'Instant']);
      }
    }

    // We unwrap the LocalDateTimePattern to avoid unnecessary levels of indirection.
    var localTemplateValue = _localTemplateValue;
    IPattern<LocalDateTime> localResult = localTemplateValue == null &&
            _twoDigitYearMax == LocalDatePatterns.defaultTwoDigitYearMax
        ? formatInfo.localDateTimePatternParser.parsePattern(patternText)
        : LocalDateTimePatterns.underlyingPattern(LocalDateTimePatterns.create(
            patternText,
            formatInfo,
            localTemplateValue ?? LocalDateTimePatterns.defaultTemplateValue,
            _twoDigitYearMax));
    return _LocalDateTimePatternAdapter(localResult);
  }
}

// This not only converts between LocalDateTime and Instant; it also handles infinity.
class _LocalDateTimePatternAdapter implements IPattern<Instant> {
  final IPattern<LocalDateTime> _pattern;

  _LocalDateTimePatternAdapter(this._pattern);

  @override
  String format(Instant value) =>
      // We don't need to be able to parse before-min/after-max values, but it's convenient to be
      // able to format them - mostly for the sake of testing (but also for ZoneInterval).
      value.isValid
          ? _pattern.format(value.inUtc().localDateTime)
          : value == IInstant.beforeMinValue
              ? InstantPatternParser.beforeMinValueText
              : InstantPatternParser.afterMaxValueText;

  @override
  StringBuffer appendFormat(Instant value, StringBuffer builder) =>
      _pattern.appendFormat(value.inUtc().localDateTime, builder);

  @override
  ParseResult<Instant> parse(String text) =>
      _pattern.parse(text).convert((local) => IInstant.trusted(Time(
          days: local.calendarDate.epochDay,
          nanoseconds: local.clockTime.timeSinceMidnight.inNanoseconds)));
}
