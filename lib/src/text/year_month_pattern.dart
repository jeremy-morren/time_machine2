// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2019 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

@internal
abstract class YearMonthPatterns {
  static const String isoPatternText = "uuuu'-'MM";

  static final YearMonthPattern isoPatternImpl =
      YearMonthPattern.createWithInvariantCulture(isoPatternText);

  static final YearMonth defaultTemplateValue = YearMonth(2000, 1);

  static YearMonthPattern create(String patternText,
          TimeMachineFormatInfo formatInfo, YearMonth templateValue,
          [int twoDigitYearMax = LocalDatePatterns.defaultTwoDigitYearMax]) =>
      YearMonthPattern._create(
          patternText, formatInfo, templateValue, twoDigitYearMax);

  static IPartialPattern<YearMonth> underlyingPattern(
          YearMonthPattern yearMonthPattern) =>
      yearMonthPattern._underlyingPattern;

  static String format(
          YearMonth yearMonth, String? patternText, Culture? culture) =>
      TimeMachineFormatInfo.getInstance(culture)
          .yearMonthPatternParser
          .parsePattern(patternText ?? YearMonthPattern._defaultFormatPattern)
          .format(yearMonth);
}

/// Represents a pattern for parsing and formatting [YearMonth] values.
///
/// The pattern characters are those of [LocalDatePattern] without the day
/// (`y`, `u`, `M`, `c` and `g`). The standard pattern `g` is the ISO pattern
/// `uuuu'-'MM`. (Noda Time's `G` standard pattern, the culture's year/month
/// pattern, isn't available: Time Machine's culture data has no year/month
/// pattern.)
@immutable
class YearMonthPattern implements IPattern<YearMonth> {
  static const String _defaultFormatPattern = 'g'; // ISO

  /// An invariant [YearMonthPattern] which is ISO-8601 compatible, providing
  /// a 4 digit year and a 2 digit month. This corresponds to the text pattern
  /// `uuuu'-'MM`.
  ///
  /// This pattern round-trips for ISO year/month values in the range
  /// -9999 to 9999.
  static YearMonthPattern get iso => YearMonthPatterns.isoPatternImpl;

  final IPartialPattern<YearMonth> _underlyingPattern;

  /// The pattern text for this pattern, as supplied on creation.
  final String patternText;

  final TimeMachineFormatInfo _formatInfo;

  /// The value used as a template for parsing: any field values unspecified
  /// in the pattern are taken from the template.
  final YearMonth templateValue;

  /// Maximum two-digit-year in the template to treat as the current century.
  /// If the value parsed is higher than this, the result is adjusted to the
  /// previous century. This value defaults to 30. To create a pattern with a
  /// different value, use [withTwoDigitYearMax].
  final int twoDigitYearMax;

  const YearMonthPattern._(this.patternText, this._formatInfo,
      this.templateValue, this.twoDigitYearMax, this._underlyingPattern);

  /// Parses the given text value according to the rules of this pattern.
  ///
  /// This method never throws an exception (barring a bug in Time Machine
  /// itself). Even errors such as the argument being null are wrapped in a
  /// parse result.
  ///
  /// * [text]: The text value to parse.
  ///
  /// Returns: The result of parsing, which may be successful or
  /// unsuccessful.
  @override
  ParseResult<YearMonth> parse(String text) => _underlyingPattern.parse(text);

  /// Formats the given year/month as text according to the rules of this
  /// pattern.
  ///
  /// * [value]: The year/month to format.
  ///
  /// Returns: The year/month formatted according to this pattern.
  @override
  String format(YearMonth value) => _underlyingPattern.format(value);

  /// Formats the given value as text according to the rules of this pattern,
  /// appending to the given [StringBuffer].
  ///
  /// * [value]: The value to format.
  /// * [builder]: The [StringBuffer] to append to.
  ///
  /// Returns: The builder passed in as [builder].
  @override
  StringBuffer appendFormat(YearMonth value, StringBuffer builder) =>
      _underlyingPattern.appendFormat(value, builder);

  static YearMonthPattern _create(String patternText,
      TimeMachineFormatInfo formatInfo, YearMonth templateValue,
      [int twoDigitYearMax = LocalDatePatterns.defaultTwoDigitYearMax]) {
    Preconditions.checkNotNull(patternText, 'patternText');
    Preconditions.checkNotNull(formatInfo, 'formatInfo');
    // Use the 'fixed' parser for the common case of the default template value.
    var pattern = templateValue == YearMonthPatterns.defaultTemplateValue &&
            twoDigitYearMax == LocalDatePatterns.defaultTwoDigitYearMax
        ? formatInfo.yearMonthPatternParser.parsePattern(patternText)
        : YearMonthPatternParser(templateValue, twoDigitYearMax)
            .parsePattern(patternText, formatInfo);
    // If ParsePattern returns a standard pattern instance, we need to get the underlying partial pattern.
    pattern =
        pattern is YearMonthPattern ? pattern._underlyingPattern : pattern;
    var partialPattern = pattern as IPartialPattern<YearMonth>;
    return YearMonthPattern._(patternText, formatInfo, templateValue,
        twoDigitYearMax, partialPattern);
  }

  /// Creates a pattern for the given pattern text, culture, and template
  /// value.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  /// * [culture]: The culture to use in the pattern
  /// * [templateValue]: Template value to use for unspecified fields.
  ///   Defaults to January 2000 in the ISO calendar.
  ///
  /// Returns: A pattern for parsing and formatting year/month values.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static YearMonthPattern createWithCulture(String patternText, Culture culture,
          [YearMonth? templateValue]) =>
      _create(patternText, TimeMachineFormatInfo.getFormatInfo(culture),
          templateValue ?? YearMonthPatterns.defaultTemplateValue);

  /// Creates a pattern for the given pattern text in the current culture.
  ///
  /// Note that the current culture is captured at the time this method is
  /// called - it is not captured at the point of parsing or formatting values.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  ///
  /// Returns: A pattern for parsing and formatting year/month values.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static YearMonthPattern createWithCurrentCulture(String patternText) =>
      _create(patternText, TimeMachineFormatInfo.currentInfo,
          YearMonthPatterns.defaultTemplateValue);

  /// Creates a pattern for the given pattern text in the invariant culture.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  ///
  /// Returns: A pattern for parsing and formatting year/month values.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static YearMonthPattern createWithInvariantCulture(String patternText) =>
      _create(patternText, TimeMachineFormatInfo.invariantInfo,
          YearMonthPatterns.defaultTemplateValue);

  YearMonthPattern _withFormatInfo(TimeMachineFormatInfo formatInfo) =>
      _create(patternText, formatInfo, templateValue, twoDigitYearMax);

  /// Creates a pattern for the same original pattern text as this pattern,
  /// but with the specified culture.
  ///
  /// * [culture]: The culture to use in the new pattern.
  ///
  /// Returns: A new pattern with the given culture.
  YearMonthPattern withCulture(Culture culture) =>
      _withFormatInfo(TimeMachineFormatInfo.getFormatInfo(culture));

  /// Creates a pattern like this one, but with the specified template value.
  ///
  /// * [newTemplateValue]: The template value for the new pattern, used to
  ///   fill in unspecified fields.
  ///
  /// Returns: A new pattern with the given template value.
  YearMonthPattern withTemplateValue(YearMonth newTemplateValue) =>
      _create(patternText, _formatInfo, newTemplateValue, twoDigitYearMax);

  /// Creates a pattern like this one, but with a different [twoDigitYearMax]
  /// value.
  ///
  /// * [twoDigitYearMax]: The value to use for [twoDigitYearMax] in the new
  ///   pattern, in the range 0-99 inclusive.
  ///
  /// Returns: A new pattern with the specified maximum two-digit-year
  /// value.
  ///
  /// * [RangeError]: [twoDigitYearMax] is outside the range 0-99.
  YearMonthPattern withTwoDigitYearMax(int twoDigitYearMax) =>
      _create(patternText, _formatInfo, templateValue, twoDigitYearMax);
}
