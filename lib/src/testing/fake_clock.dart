// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Clock which can be constructed with an initial instant, and then advanced
/// programmatically (and optionally, automatically advanced on each read).
/// This class is designed to be used when testing classes which take a
/// [Clock] as a dependency.
///
/// This class is somewhere between a fake and a stub, depending on how it's
/// used - if it's set to [autoAdvance] then time will pass, but in a pretty
/// odd way (i.e. dependent on how often it's consulted).
class FakeClock extends Clock {
  Instant _now;

  /// The amount of time to advance the clock by on each call to read the
  /// current time. This is zero unless a value is passed to the [FakeClock]
  /// constructor or set later. If this is zero, the current time as reported
  /// by this clock will not change
  /// other than by calls to [reset] or to one of the [advance] methods.
  ///
  /// The value could even be negative, to simulate particularly odd system
  /// clock effects.
  Time autoAdvance;

  /// Creates a fake clock initially set to the given instant. The clock will
  /// advance by the given duration on each read, with the first value
  /// returned being the initial instant.
  ///
  /// * [initial]: The initial instant.
  /// * [autoAdvance]: The duration to advance the clock on each read;
  ///   zero if omitted.
  FakeClock(Instant initial, [this.autoAdvance = Time.zero]) : _now = initial;

  /// Returns a fake clock initially set to the given year/month/day/time in
  /// UTC in the ISO calendar. The value of the [autoAdvance] property will
  /// be initialised to zero.
  ///
  /// * [year]: The year. This is the "absolute year", so a value of 0 means
  ///   1 BC, for example.
  /// * [monthOfYear]: The month of year.
  /// * [dayOfMonth]: The day of month.
  /// * [hourOfDay]: The hour.
  /// * [minuteOfHour]: The minute.
  /// * [secondOfMinute]: The second.
  ///
  /// Returns: A [FakeClock] with the given instant.
  factory FakeClock.fromUtc(int year, int monthOfYear, int dayOfMonth,
          [int hourOfDay = 0, int minuteOfHour = 0, int secondOfMinute = 0]) =>
      FakeClock(Instant.utc(year, monthOfYear, dayOfMonth, hourOfDay,
          minuteOfHour, secondOfMinute));

  /// Advances the clock by the given duration.
  ///
  /// * [duration]: The duration to advance the clock by (or if negative, the
  ///   duration to move it back by).
  void advance(Time duration) => _now += duration;

  /// Advances the clock by the given number of nanoseconds.
  ///
  /// * [nanoseconds]: The number of nanoseconds to advance the clock by (or
  ///   if negative, the number to move it back by).
  void advanceNanoseconds(int nanoseconds) =>
      advance(Time(nanoseconds: nanoseconds));

  /// Advances the clock by the given number of microseconds. (Noda Time has
  /// `AdvanceTicks` instead; Time Machine has no ticks.)
  ///
  /// * [microseconds]: The number of microseconds to advance the clock by
  ///   (or if negative, the number to move it back by).
  void advanceMicroseconds(int microseconds) =>
      advance(Time(microseconds: microseconds));

  /// Advances the clock by the given number of milliseconds.
  ///
  /// * [milliseconds]: The number of milliseconds to advance the clock by (or
  ///   if negative, the number to move it back by).
  void advanceMilliseconds(int milliseconds) =>
      advance(Time(milliseconds: milliseconds));

  /// Advances the clock by the given number of seconds.
  ///
  /// * [seconds]: The number of seconds to advance the clock by (or if
  ///   negative, the number to move it back by).
  void advanceSeconds(int seconds) => advance(Time(seconds: seconds));

  /// Advances the clock by the given number of minutes.
  ///
  /// * [minutes]: The number of minutes to advance the clock by (or if
  ///   negative, the number to move it back by).
  void advanceMinutes(int minutes) => advance(Time(minutes: minutes));

  /// Advances the clock by the given number of hours.
  ///
  /// * [hours]: The number of hours to advance the clock by (or if negative,
  ///   the number to move it back by).
  void advanceHours(int hours) => advance(Time(hours: hours));

  /// Advances the clock by the given number of standard (24-hour) days.
  ///
  /// * [days]: The number of days to advance the clock by (or if negative,
  ///   the number to move it back by).
  void advanceDays(int days) => advance(Time(days: days));

  /// Resets the clock to the given instant. The value of the [autoAdvance]
  /// property will be unchanged.
  ///
  /// * [instant]: The instant to set the clock to.
  void reset(Instant instant) => _now = instant;

  /// Returns the "current time" for this clock. Unlike a normal clock, this
  /// property may return the same value from repeated calls until one of the
  /// methods to change the time is called.
  ///
  /// If the value of the [autoAdvance] property is non-zero, then every call
  /// to this method will advance the current time by that value.
  ///
  /// Returns: The "current time" from this (fake) clock.
  @override
  Instant getCurrentInstant() {
    var then = _now;
    _now += autoAdvance;
    return then;
  }
}
