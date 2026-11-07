// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2019 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

@internal
abstract class IYearMonth {
  /// The first day of the month.
  static LocalDate startDate(YearMonth yearMonth) => yearMonth._startDate;

  /// The last day of the month.
  static LocalDate endDate(YearMonth yearMonth) => yearMonth._endDate;
}

/// A year and month in a particular calendar. This is effectively
/// [LocalDate] without the day-of-month component.
///
/// Values can freely be compared for equality: a value in a different calendar
/// system is not equal to a value in a different calendar system. However, ordering
/// comparisons (either via the [compareTo] method or via operators) fail with
/// [ArgumentError]; attempting to compare values in different calendars
/// almost always indicates a bug in the calling code.
@immutable
class YearMonth implements Comparable<YearMonth> {
  final YearMonthDayCalendar _startOfMonth;

  const YearMonth._(this._startOfMonth);

  /// Constructs an instance for the given year and month, in the given
  /// calendar system ([CalendarSystem.iso] if [calendar] is omitted).
  ///
  /// If [era] is specified, [year] is the year within that era (the year of
  /// era) rather than the absolute year.
  ///
  /// * [year]: The year. This is the "absolute year", so, for the ISO
  ///   calendar, a value of 0 means 1 BC, for example; or the year of era if
  ///   [era] is specified.
  /// * [month]: The month of year.
  /// * [calendar]: Calendar system in which to create the year/month.
  /// * [era]: The era within which to create a year/month.
  ///
  /// * [RangeError]: The parameters do not form a valid year/month, or [era]
  ///   isn't an era of the calendar.
  factory YearMonth(int year, int month, [CalendarSystem? calendar, Era? era]) {
    calendar ??= CalendarSystem.iso;
    if (era != null) {
      year = calendar.getAbsoluteYear(year, era);
    }
    ICalendarSystem.validateYearMonthDay(calendar, year, month, 1);
    return YearMonth._(YearMonthDayCalendar(
        year, month, 1, ICalendarSystem.ordinal(calendar)));
  }

  /// The calendar system associated with this year/month.
  CalendarSystem get calendar =>
      ICalendarSystem.forOrdinal(_startOfMonth.calendarOrdinal);

  /// The year of this value.
  ///
  /// This returns the "absolute year", so, for the ISO calendar,
  /// a value of 0 means 1 BC, for example.
  int get year => _startOfMonth.year;

  /// The month of this value within the year.
  int get month => _startOfMonth.month;

  /// The year of this value within the era.
  int get yearOfEra => ICalendarSystem.getYearOfEra(calendar, year);

  /// The era of this value.
  Era get era => ICalendarSystem.getEra(calendar, year);

  LocalDate get _startDate => ILocalDate.trusted(_startOfMonth);

  LocalDate get _endDate =>
      LocalDate(year, month, calendar.getDaysInMonth(year, month), calendar);

  /// Returns a [DateInterval] covering the month represented by this value.
  DateInterval toDateInterval() => DateInterval(_startDate, _endDate);

  /// Returns a [YearMonth] value which is a number of months later (or
  /// earlier, for a negative value) than this one.
  ///
  /// * [months]: The number of months to add to this value. May be negative.
  ///
  /// Returns: A [YearMonth] value which is the given number of months
  /// later than this one.
  YearMonth addMonths(int months) =>
      onDayOfMonth(1).addMonths(months).toYearMonth();

  /// Returns a [YearMonth] value which is a number of months earlier (or
  /// later, for a negative value) than this one. See [addMonths].
  YearMonth subtractMonths(int months) => addMonths(-months);

  /// Returns a [LocalDate] with the year/month of this value, and the given
  /// day of month.
  ///
  /// * [day]: The day within the month.
  ///
  /// Returns: The result of combining this year and month with [day].
  ///
  /// * [RangeError]: [day] does not fall within the month represented by
  ///   this value.
  LocalDate onDayOfMonth(int day) {
    Preconditions.checkArgumentRange(
        'day', day, 1, calendar.getDaysInMonth(year, month));
    return LocalDate(year, month, day, calendar);
  }

  /// Indicates whether this value is earlier, later or the same as [other].
  ///
  /// The calendar systems of the two values must be the same.
  ///
  /// * [other]: The value to compare this one with.
  ///
  /// Returns: A value less than zero if this value is earlier than [other];
  /// zero if this value is the same as [other]; a value greater than zero if
  /// this value is later than [other].
  ///
  /// * [ArgumentError]: The calendar system of [other] is not the same as
  ///   the calendar system of this value.
  @override
  int compareTo(YearMonth? other) {
    // Dart's Comparable convention, as LocalDate.compareTo: a null value is
    // earlier than any value (Noda Time: IComparable.CompareTo(null) == 1).
    if (other == null) return 1;
    Preconditions.checkArgument(
        _startOfMonth.calendarOrdinal == other._startOfMonth.calendarOrdinal,
        'other',
        'Only values with the same calendar system can be compared');
    return _trustedCompareTo(other);
  }

  int _trustedCompareTo(YearMonth other) => ICalendarSystem.compare(calendar,
      _startOfMonth.toYearMonthDay(), other._startOfMonth.toYearMonthDay());

  void _checkSameCalendar(YearMonth other) => Preconditions.checkArgument(
      _startOfMonth.calendarOrdinal == other._startOfMonth.calendarOrdinal,
      'other',
      'Only values in the same calendar can be compared');

  /// Compares two [YearMonth] values to see if this one is strictly earlier
  /// than [other].
  ///
  /// * [ArgumentError]: The calendar system of [other] is not the same as
  ///   the calendar system of this value.
  bool operator <(YearMonth other) {
    _checkSameCalendar(other);
    return _trustedCompareTo(other) < 0;
  }

  /// Compares two [YearMonth] values to see if this one is earlier than or
  /// equal to [other].
  ///
  /// * [ArgumentError]: The calendar system of [other] is not the same as
  ///   the calendar system of this value.
  bool operator <=(YearMonth other) {
    _checkSameCalendar(other);
    return _trustedCompareTo(other) <= 0;
  }

  /// Compares two [YearMonth] values to see if this one is strictly later
  /// than [other].
  ///
  /// * [ArgumentError]: The calendar system of [other] is not the same as
  ///   the calendar system of this value.
  bool operator >(YearMonth other) {
    _checkSameCalendar(other);
    return _trustedCompareTo(other) > 0;
  }

  /// Compares two [YearMonth] values to see if this one is later than or
  /// equal to [other].
  ///
  /// * [ArgumentError]: The calendar system of [other] is not the same as
  ///   the calendar system of this value.
  bool operator >=(YearMonth other) {
    _checkSameCalendar(other);
    return _trustedCompareTo(other) >= 0;
  }

  /// Compares two [YearMonth] values for equality: they are equal if they
  /// have the same year, month and calendar system.
  @override
  bool operator ==(Object other) =>
      other is YearMonth && _startOfMonth == other._startOfMonth;

  /// Compares two [YearMonth] values for equality. See [operator ==].
  bool equals(YearMonth other) => this == other;

  @override
  int get hashCode => _startOfMonth.hashCode;

  /// Formats the value of the current instance using the specified pattern.
  ///
  /// * [patternText]: The pattern to use, or null to use the ISO pattern
  ///   (`uuuu'-'MM`).
  /// * [culture]: The culture to use when formatting the value, or null to
  ///   use the current culture.
  ///
  /// Returns: A [String] containing the value of the current instance in
  /// the specified format.
  ///
  /// Noda Time formats with the culture's year/month pattern by default;
  /// Time Machine's culture data has no year/month pattern, so the default is
  /// the ISO pattern.
  @override
  String toString([String? patternText, Culture? culture]) =>
      YearMonthPatterns.format(this, patternText, culture);
}
