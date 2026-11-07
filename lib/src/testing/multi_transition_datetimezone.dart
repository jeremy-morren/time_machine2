// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Time zone with multiple transitions, created via a
/// [MultiTransitionDateTimeZoneBuilder].
class MultiTransitionDateTimeZone extends DateTimeZone {
  /// The zone intervals within this time zone, in chronological order,
  /// spanning the whole time line.
  final List<ZoneInterval> intervals;

  /// The transition points between intervals.
  final List<Instant> transitions;

  MultiTransitionDateTimeZone._(String id, List<ZoneInterval> intervals)
      : intervals = List.unmodifiable(intervals),
        transitions = List.unmodifiable(intervals.skip(1).map((x) => x.start)),
        super(
            id,
            intervals.length == 1,
            intervals.map((x) => x.wallOffset).reduce(Offset.min),
            intervals.map((x) => x.wallOffset).reduce(Offset.max));

  @override
  ZoneInterval getZoneInterval(Instant instant) {
    int lower = 0; // Inclusive
    int upper = intervals.length; // Exclusive

    while (lower < upper) {
      int current = (lower + upper) ~/ 2;
      var candidate = intervals[current];
      if (candidate.hasStart && candidate.start > instant) {
        upper = current;
      } else if (candidate.hasEnd && candidate.end <= instant) {
        lower = current + 1;
      } else {
        return candidate;
      }
    }
    // Note: this would indicate a bug. The time zone is meant to cover the whole of time.
    throw StateError('Instant $instant did not exist in time zone $id.');
  }
}

/// Builder to create instances of [MultiTransitionDateTimeZone]. Each builder
/// can only be built once.
///
/// This is Noda Time's `MultiTransitionDateTimeZone.Builder`.
class MultiTransitionDateTimeZoneBuilder {
  final List<ZoneInterval> _intervals = <ZoneInterval>[];
  Offset _currentStandardOffset;
  Offset _currentSavings;
  String _currentName;
  bool _built = false;

  /// The ID of the time zone which will be built; `MultiZone` unless set.
  String id = 'MultiZone';

  /// Constructs a builder using the given first name, standard offset, and
  /// daylight saving offset. The ID is initially `MultiZone`.
  ///
  /// * [firstStandardOffsetHours]: Standard offset in hours in the first zone
  ///   interval; zero if omitted.
  /// * [firstSavingOffsetHours]: Daylight saving offset in hours in the first
  ///   zone interval; zero if omitted.
  /// * [firstName]: Name of the first zone interval; `First` if omitted.
  MultiTransitionDateTimeZoneBuilder(
      [int firstStandardOffsetHours = 0,
      int firstSavingOffsetHours = 0,
      String firstName = 'First'])
      : _currentName = firstName,
        _currentStandardOffset = Offset.hours(firstStandardOffsetHours),
        _currentSavings = Offset.hours(firstSavingOffsetHours);

  /// Constructs a builder using the given first name, standard offset, and a
  /// daylight saving offset of 0. The ID is initially `MultiZone`.
  ///
  /// * [firstOffsetHours]: Standard offset in hours in the first zone
  ///   interval.
  /// * [firstName]: Name of the first zone interval.
  MultiTransitionDateTimeZoneBuilder.withName(
      int firstOffsetHours, String firstName)
      : this(firstOffsetHours, 0, firstName);

  /// Adds a transition at the given instant, to the specified new standard
  /// offset, with the new specified daylight saving. The name is generated
  /// from the transition unless [newName] is specified.
  ///
  /// * [transition]: Instant at which the zone changes.
  /// * [newStandardOffsetHours]: The new standard offset, in hours.
  /// * [newSavingOffsetHours]: The new daylight saving offset, in hours;
  ///   zero if omitted.
  /// * [newName]: The new zone interval name.
  void add(Instant transition, int newStandardOffsetHours,
      [int newSavingOffsetHours = 0, String? newName]) {
    newName ??= 'Interval from $transition';
    _ensureNotBuilt();
    Instant? previousStart = _intervals.isEmpty ? null : _intervals.last.end;
    // The ZoneInterval constructor will perform validation.
    _intervals.add(IZoneInterval.newZoneInterval(_currentName, previousStart,
        transition, _currentStandardOffset + _currentSavings, _currentSavings));
    _currentName = newName;
    _currentStandardOffset = Offset.hours(newStandardOffsetHours);
    _currentSavings = Offset.hours(newSavingOffsetHours);
  }

  /// Builds a [MultiTransitionDateTimeZone] from this builder, invalidating
  /// it in the process.
  ///
  /// Returns: The newly-built zone.
  ///
  /// * [StateError]: The builder has already been built.
  MultiTransitionDateTimeZone build() {
    _ensureNotBuilt();
    _built = true;
    Instant? previousStart = _intervals.isEmpty ? null : _intervals.last.end;
    _intervals.add(IZoneInterval.newZoneInterval(_currentName, previousStart,
        null, _currentStandardOffset + _currentSavings, _currentSavings));
    return MultiTransitionDateTimeZone._(id, _intervals);
  }

  void _ensureNotBuilt() {
    if (_built) {
      throw StateError('Cannot use a builder after building');
    }
  }
}
