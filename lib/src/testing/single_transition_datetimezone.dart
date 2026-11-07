// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

/// Time zone with a single transition between two offsets. This provides a
/// simple way to test behaviour across a transition.
class SingleTransitionDateTimeZone extends DateTimeZone {
  /// The [ZoneInterval] for the period before the transition, starting at
  /// the beginning of time.
  final ZoneInterval earlyInterval;

  /// The [ZoneInterval] for the period after the transition, ending at the
  /// end of time.
  final ZoneInterval lateInterval;

  /// The transition instant of the zone.
  Instant get transition => earlyInterval.end;

  /// Creates a zone with a single transition between two offsets.
  ///
  /// * [transitionPoint]: The transition point as an [Instant].
  /// * [offsetBefore]: The offset of local time from UTC before the
  ///   transition.
  /// * [offsetAfter]: The offset of local time from UTC after the transition.
  /// * [id]: ID for the newly created time zone; `Single` if omitted.
  SingleTransitionDateTimeZone(
      Instant transitionPoint, Offset offsetBefore, Offset offsetAfter,
      [String id = 'Single'])
      : earlyInterval = IZoneInterval.newZoneInterval(
            '$id-Early', null, transitionPoint, offsetBefore, Offset.zero),
        lateInterval = IZoneInterval.newZoneInterval(
            '$id-Late', transitionPoint, null, offsetAfter, Offset.zero),
        super(id, false, Offset.min(offsetBefore, offsetAfter),
            Offset.max(offsetBefore, offsetAfter));

  /// Creates a zone with a single transition between two offsets given in
  /// hours, and the ID `Single`.
  ///
  /// * [transitionPoint]: The transition point as an [Instant].
  /// * [offsetBeforeHours]: The offset of local time from UTC, in hours,
  ///   before the transition.
  /// * [offsetAfterHours]: The offset of local time from UTC, in hours, after
  ///   the transition.
  SingleTransitionDateTimeZone.hours(
      Instant transitionPoint, int offsetBeforeHours, int offsetAfterHours)
      : this(transitionPoint, Offset.hours(offsetBeforeHours),
            Offset.hours(offsetAfterHours));

  /// Returns either the zone interval before or after the transition, based
  /// on the instant provided.
  @override
  ZoneInterval getZoneInterval(Instant instant) =>
      earlyInterval.contains(instant) ? earlyInterval : lateInterval;
}
