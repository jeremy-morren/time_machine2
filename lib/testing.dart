// Portions of this work are Copyright 2026 The Time Machine Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

/// Types to help test code which uses Time Machine: the equivalent of the
/// `NodaTime.Testing` package.
///
/// * [FakeClock]: a [Clock] whose time is set and advanced by the test.
/// * [FakeDateTimeZoneSource]: a [DateTimeZoneSource] of the zones the test
///   provides.
/// * [SingleTransitionDateTimeZone] and [MultiTransitionDateTimeZone]: time
///   zones with transitions at given instants.
/// * [TimeConstruction] and [LocalDateConstruction]: `5.hours` and
///   `19.march(2019)`.
library;

import 'time_machine2.dart';

export 'src/testing/construction_extensions.dart'
    show TimeConstruction, LocalDateConstruction;
export 'src/testing/fake_clock.dart' show FakeClock;
export 'src/testing/fake_datetimezone_source.dart'
    show FakeDateTimeZoneSource, FakeDateTimeZoneSourceBuilder;
export 'src/testing/multi_transition_datetimezone.dart'
    show MultiTransitionDateTimeZone, MultiTransitionDateTimeZoneBuilder;
export 'src/testing/single_transition_datetimezone.dart'
    show SingleTransitionDateTimeZone;
