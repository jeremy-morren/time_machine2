// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Class whose existence is solely to avoid type initialization order issues, most of which stem
/// from needing TimeMachineFormatInfo.InvariantInfo... (todo: does this affect us in Dart Land?)
@internal
abstract class LocalDateTimePatterns {
  static final LocalDateTimePattern generalIsoPatternImpl =
      LocalDateTimePattern.createWithInvariantCulture(
          "uuuu'-'MM'-'dd'T'HH':'mm':'ss");
  static final LocalDateTimePattern extendedIsoPatternImpl =
      LocalDateTimePattern.createWithInvariantCulture(
          "uuuu'-'MM'-'dd'T'HH':'mm':'ss;FFFFFFFFF");
  static final LocalDateTimePattern roundtripPatternImpl =
      LocalDateTimePattern.createWithInvariantCulture(
          "uuuu'-'MM'-'dd'T'HH':'mm':'ss'.'fffffff");
  static final LocalDateTimePattern fullRoundtripWithoutCalendarImpl =
      LocalDateTimePattern.createWithInvariantCulture(
          "uuuu'-'MM'-'dd'T'HH':'mm':'ss'.'fffffffff");
  static final LocalDateTimePattern fullRoundtripPatternImpl =
      LocalDateTimePattern.createWithInvariantCulture(
          "uuuu'-'MM'-'dd'T'HH':'mm':'ss'.'fffffffff '('c')'");
  static final LocalDateTimePattern dateHourIsoPatternImpl =
      LocalDateTimePattern.createWithInvariantCulture("uuuu'-'MM'-'dd'T'HH");
  static final LocalDateTimePattern dateHourMinuteIsoPatternImpl =
      LocalDateTimePattern.createWithInvariantCulture(
          "uuuu'-'MM'-'dd'T'HH':'mm");
  static final IPattern<LocalDateTime> variablePrecisionIsoPatternImpl =
      (CompositePatternBuilder<LocalDateTime>()
            ..add(extendedIsoPatternImpl, (time) => true)
            ..add(
                dateHourMinuteIsoPatternImpl,
                (time) =>
                    time.secondOfMinute == 0 && time.nanosecondOfSecond == 0)
            ..add(
                dateHourIsoPatternImpl,
                (time) =>
                    time.minuteOfHour == 0 &&
                    time.secondOfMinute == 0 &&
                    time.nanosecondOfSecond == 0))
          .build();

  static final LocalDateTime defaultTemplateValue =
      LocalDateTime(2000, 1, 1, 0, 0, 0);
  static String format(
          LocalDateTime localDateTime, String? patternText, Culture? culture) =>
      TimeMachineFormatInfo.getInstance(culture)
          .localDateTimePatternParser
          .parsePattern(
              patternText ?? LocalDateTimePattern._defaultFormatPattern)
          .format(localDateTime);

  static IPartialPattern<LocalDateTime> underlyingPattern(
          LocalDateTimePattern localDateTimePattern) =>
      localDateTimePattern._underlyingPattern;

  static LocalDateTimePattern create(String patternText,
          TimeMachineFormatInfo formatInfo, LocalDateTime templateValue,
          [int twoDigitYearMax = LocalDatePatterns.defaultTwoDigitYearMax]) =>
      LocalDateTimePattern._create(
          patternText, formatInfo, templateValue, twoDigitYearMax);
}

/// Represents a pattern for parsing and formatting [LocalDateTime] values.
@immutable
class LocalDateTimePattern implements IPattern<LocalDateTime> {
  static const String _defaultFormatPattern = 'G'; // General (long time)

  /// Gets an invariant local date/time pattern which is ISO-8601 compatible, down to the second.
  /// This corresponds to the text pattern "uuuu'-'MM'-'dd'T'HH':'mm':'ss", and is also used as the "sortable"
  /// standard pattern.
  static LocalDateTimePattern get generalIso =>
      LocalDateTimePatterns.generalIsoPatternImpl;

  /// Gets an invariant local date/time pattern which is ISO-8601 compatible, providing up to 9 decimal places
  /// of sub-second accuracy. (These digits are omitted when unnecessary.)
  /// This corresponds to the text pattern "uuuu'-'MM'-'dd'T'HH':'mm':'ss;FFFFFFFFF".
  static LocalDateTimePattern get extendedIso =>
      LocalDateTimePatterns.extendedIsoPatternImpl;

  /// Gets an invariant local date/time pattern which is ISO-8601 compatible, providing up to 7 decimal places
  /// of sub-second accuracy which are always present (including trailing zeroes). This is compatible with the
  /// BCL round-trip formatting of [DateTime] values with a kind of 'unspecified'.
  /// This corresponds to the text pattern "uuuu'-'MM'-'dd'T'HH':'mm':'ss'.'fffffff". It does not necessarily
  /// round-trip all `LocalDateTime` values as it will lose sub-tick information. Use
  /// [fullRoundtripWithoutCalendar]
  static LocalDateTimePattern get roundtrip =>
      LocalDateTimePatterns.roundtripPatternImpl;

  /// Gets an invariant local date/time pattern which round trips values, but doesn't include the calendar system.
  /// It provides up to 9 decimal places of sub-second accuracy which are always present (including trailing zeroes).
  /// This corresponds to the text pattern "uuuu'-'MM'-'dd'T'HH':'mm':'ss'.'fffffffff". It will
  /// round-trip all [LocalDateTime] values if the calendar system of the template value is the same
  /// as the calendar system of the original value.
  static LocalDateTimePattern get fullRoundtripWithoutCalendar =>
      LocalDateTimePatterns.fullRoundtripWithoutCalendarImpl;

  /// Gets an invariant local date/time pattern which round trips values including the calendar system.
  /// This corresponds to the text pattern "uuuu'-'MM'-'dd'T'HH':'mm':'ss'.'fffffffff '('c')'".
  static LocalDateTimePattern get fullRoundtrip =>
      LocalDateTimePatterns.fullRoundtripPatternImpl;

  /// An invariant local date/time pattern which is ISO-8601 compatible,
  /// providing up to the hour. This corresponds to the text pattern
  /// `uuuu'-'MM'-'dd'T'HH`.
  static LocalDateTimePattern get dateHourIso =>
      LocalDateTimePatterns.dateHourIsoPatternImpl;

  /// An invariant local date/time pattern which is ISO-8601 compatible,
  /// providing up to the minute. This corresponds to the text pattern
  /// `uuuu'-'MM'-'dd'T'HH':'mm`.
  static LocalDateTimePattern get dateHourMinuteIso =>
      LocalDateTimePatterns.dateHourMinuteIsoPatternImpl;

  /// An invariant local date/time pattern which is ISO-8601 compatible, and
  /// which formats values to the shortest precision that represents them
  /// exactly: [dateHourIso], [dateHourMinuteIso] or [extendedIso]. It parses
  /// any of those three formats.
  static IPattern<LocalDateTime> get variablePrecisionIso =>
      LocalDateTimePatterns.variablePrecisionIsoPatternImpl;

  /// Gets the pattern text for this pattern, as supplied on creation.
  final String patternText;

  /// Gets the localization information used in this pattern.
  final TimeMachineFormatInfo _formatInfo;

  /// Get the value used as a template for parsing: any field values unspecified
  /// in the pattern are taken from the template.
  final LocalDateTime templateValue;

  /// Maximum two-digit-year in the template to treat as the current century.
  /// If the value parsed is higher than this, the result is adjusted to the
  /// previous century. This value defaults to 30. To create a pattern with a
  /// different value, use [withTwoDigitYearMax].
  final int twoDigitYearMax;

  /// Returns the pattern that this object delegates to. Mostly useful to avoid this public class
  /// implementing an internal interface.
  final IPartialPattern<LocalDateTime> _underlyingPattern;

  const LocalDateTimePattern._(this.patternText, this._formatInfo,
      this.templateValue, this.twoDigitYearMax, this._underlyingPattern);

  /// Parses the given text value according to the rules of this pattern.
  ///
  /// This method never throws an exception (barring a bug in Time Machine itself). Even errors such as
  /// the argument being null are wrapped in a parse result.
  ///
  /// * [text]: The text value to parse.
  ///
  /// Returns: The result of parsing, which may be successful or unsuccessful.
  @override
  ParseResult<LocalDateTime> parse(String text) =>
      _underlyingPattern.parse(text);

  /// Formats the given local date/time as text according to the rules of this pattern.
  ///
  /// * [value]: The local date/time to format.
  ///
  /// Returns: The local date/time formatted according to this pattern.
  @override
  String format(LocalDateTime value) => _underlyingPattern.format(value);

  /// Formats the given value as text according to the rules of this pattern,
  /// appending to the given [StringBuilder].
  ///
  /// * [value]: The value to format.
  /// * [builder]: The `StringBuffer` to append to.
  ///
  /// Returns: The builder passed in as [builder].
  @override
  StringBuffer appendFormat(LocalDateTime value, StringBuffer builder) =>
      _underlyingPattern.appendFormat(value, builder);

  /// Creates a pattern for the given pattern text, format info, and template value.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  /// * [formatInfo]: The format info to use in the pattern
  /// * [templateValue]: Template value to use for unspecified fields
  ///
  /// Returns: A pattern for parsing and formatting local date/times.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static LocalDateTimePattern _create(String patternText,
      TimeMachineFormatInfo formatInfo, LocalDateTime templateValue,
      [int twoDigitYearMax = LocalDatePatterns.defaultTwoDigitYearMax]) {
    Preconditions.checkNotNull(patternText, 'patternText');
    Preconditions.checkNotNull(formatInfo, 'formatInfo');
    // Use the 'fixed' parser for the common case of the default template value.
    var pattern = templateValue == LocalDateTimePatterns.defaultTemplateValue &&
            twoDigitYearMax == LocalDatePatterns.defaultTwoDigitYearMax
        ? formatInfo.localDateTimePatternParser.parsePattern(patternText)
        : LocalDateTimePatternParser(templateValue, twoDigitYearMax)
            .parsePattern(patternText, formatInfo);
    // If ParsePattern returns a standard pattern instance, we need to get the underlying partial pattern.
    pattern =
        pattern is LocalDateTimePattern ? pattern._underlyingPattern : pattern;
    var partialPattern = pattern as IPartialPattern<LocalDateTime>;
    return LocalDateTimePattern._(patternText, formatInfo, templateValue,
        twoDigitYearMax, partialPattern);
  }

  // todo: do factories

  /// Creates a pattern for the given pattern text, culture, and template value.
  ///
  /// todo: we need one
  /// See the user guide for the available pattern text options.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  /// * [culture]: The culture to use in the pattern
  /// * [templateValue]: Template value to use for unspecified fields. Defaults to a template value of midnight on 2000-01-01.
  ///
  /// Returns: A pattern for parsing and formatting local date/times.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static LocalDateTimePattern createWithCulture(
          String patternText, Culture culture,
          [LocalDateTime? templateValue]) =>
      _create(patternText, TimeMachineFormatInfo.getFormatInfo(culture),
          templateValue ?? LocalDateTimePatterns.defaultTemplateValue);

  /// Creates a pattern for the given pattern text in the current thread's current culture.
  ///
  /// See the user guide for the available pattern text options. Note that the current culture
  /// is captured at the time this method is called - it is not captured at the point of parsing
  /// or formatting values.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  ///
  /// Returns: A pattern for parsing and formatting local date/times.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static LocalDateTimePattern createWithCurrentCulture(String patternText) =>
      _create(patternText, TimeMachineFormatInfo.currentInfo,
          LocalDateTimePatterns.defaultTemplateValue);

  /// Creates a pattern for the given pattern text in the invariant culture.
  ///
  /// todo: we need one
  /// See the user guide for the available pattern text options.
  ///
  /// * [patternText]: Pattern text to create the pattern for
  ///
  /// Returns: A pattern for parsing and formatting local date/times.
  ///
  /// * [InvalidPatternError]: The pattern text was invalid.
  static LocalDateTimePattern createWithInvariantCulture(String patternText) =>
      _create(patternText, TimeMachineFormatInfo.invariantInfo,
          LocalDateTimePatterns.defaultTemplateValue);

  /// Creates a pattern for the same original pattern text as this pattern, but with the specified
  /// localization information.
  ///
  /// * [formatInfo]: The localization information to use in the new pattern.
  ///
  /// Returns: A new pattern with the given localization information.
  LocalDateTimePattern _withFormatInfo(TimeMachineFormatInfo formatInfo) =>
      _create(patternText, formatInfo, templateValue, twoDigitYearMax);

  /// Creates a pattern for the same original pattern text as this pattern, but with the specified
  /// culture.
  ///
  /// * [culture]: The culture to use in the new pattern.
  ///
  /// Returns: A new pattern with the given culture.
  LocalDateTimePattern withCulture(Culture culture) =>
      _withFormatInfo(TimeMachineFormatInfo.getFormatInfo(culture));

  /// Creates a pattern like this one, but with the specified template value.
  ///
  /// * [newTemplateValue]: The template value for the new pattern, used to fill in unspecified fields.
  ///
  /// Returns: A new pattern with the given template value.
  LocalDateTimePattern withTemplateValue(LocalDateTime newTemplateValue) =>
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
  LocalDateTimePattern withTwoDigitYearMax(int twoDigitYearMax) =>
      _create(patternText, _formatInfo, templateValue, twoDigitYearMax);

  /// Creates a pattern like this one, but with the template value modified to use
  /// the specified calendar system.
  ///
  /// Care should be taken in two (relatively rare) scenarios. Although the default template value
  /// is supported by all Time Machine calendar systems, if a pattern is created with a different
  /// template value and then this method is called with a calendar system which doesn't support that
  /// date, an exception will be thrown. Additionally, if the pattern only specifies some date fields,
  /// it's possible that the new template value will not be suitable for all values.
  ///
  /// * [calendar]: The calendar system to convert the template value into.
  ///
  /// Returns: A new pattern with a template value in the specified calendar system.
  LocalDateTimePattern withCalendar(CalendarSystem calendar) =>
      withTemplateValue(templateValue.withCalendar(calendar));
}
