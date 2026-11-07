// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2019 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Extension members on numbers to make it easy to construct [Time] values in
/// tests, such as `5.hours` or `1.5.days`.
///
/// This is Noda Time's `NodaTime.Testing.Extensions.DurationConstruction`
/// (`5.Hours()`). Noda Time's `Ticks()` isn't available, as Time Machine has
/// no ticks; [microseconds] is available instead.
extension TimeConstruction on num {
  /// A [Time] of this number of standard (24-hour) days.
  Time get days => Time(days: this);

  /// A [Time] of this number of hours.
  Time get hours => Time(hours: this);

  /// A [Time] of this number of minutes.
  Time get minutes => Time(minutes: this);

  /// A [Time] of this number of seconds.
  Time get seconds => Time(seconds: this);

  /// A [Time] of this number of milliseconds.
  Time get milliseconds => Time(milliseconds: this);

  /// A [Time] of this number of microseconds.
  Time get microseconds => Time(microseconds: this);

  /// A [Time] of this number of nanoseconds.
  Time get nanoseconds => Time(nanoseconds: this);
}

/// Extension methods on [int] to make it easy to construct ISO [LocalDate]
/// values in tests, such as `19.march(2019)`: the target is the day of month.
///
/// This is Noda Time's `NodaTime.Testing.Extensions.LocalDateConstruction`
/// (`19.March(2019)`).
extension LocalDateConstruction on int {
  /// The ISO date in January of [year] with this day of month.
  LocalDate january(int year) => LocalDate(year, 1, this);

  /// The ISO date in February of [year] with this day of month.
  LocalDate february(int year) => LocalDate(year, 2, this);

  /// The ISO date in March of [year] with this day of month.
  LocalDate march(int year) => LocalDate(year, 3, this);

  /// The ISO date in April of [year] with this day of month.
  LocalDate april(int year) => LocalDate(year, 4, this);

  /// The ISO date in May of [year] with this day of month.
  LocalDate may(int year) => LocalDate(year, 5, this);

  /// The ISO date in June of [year] with this day of month.
  LocalDate june(int year) => LocalDate(year, 6, this);

  /// The ISO date in July of [year] with this day of month.
  LocalDate july(int year) => LocalDate(year, 7, this);

  /// The ISO date in August of [year] with this day of month.
  LocalDate august(int year) => LocalDate(year, 8, this);

  /// The ISO date in September of [year] with this day of month.
  LocalDate september(int year) => LocalDate(year, 9, this);

  /// The ISO date in October of [year] with this day of month.
  LocalDate october(int year) => LocalDate(year, 10, this);

  /// The ISO date in November of [year] with this day of month.
  LocalDate november(int year) => LocalDate(year, 11, this);

  /// The ISO date in December of [year] with this day of month.
  LocalDate december(int year) => LocalDate(year, 12, this);
}
