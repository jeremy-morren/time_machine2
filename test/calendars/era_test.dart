// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:time_machine2/src/time_machine_internal.dart';

import 'package:test/test.dart';
import 'package:parameterized_test/parameterized_test.dart';

import '../time_machine_testing.dart';

void main() {
  parameterizedTest('ResourcePresence', Eras, ResourcePresence,
      customDescriptionBuilder: describeArguments);
  parameterizedTest('ToStringReturnsName', Eras, ToStringReturnsName,
      customDescriptionBuilder: describeArguments);
}

/// The static Era fields (typeof(Era).GetTypeInfo().DeclaredProperties in
/// Noda Time), named by field, as two eras share the name 'AM'.
List<Object> Eras = [
  Era.common.options(customDescriptionBuilder: (_, __, ___) => 'common'),
  Era.beforeCommon
      .options(customDescriptionBuilder: (_, __, ___) => 'beforeCommon'),
  Era.annoMartyrum
      .options(customDescriptionBuilder: (_, __, ___) => 'annoMartyrum'),
  Era.annoHegirae
      .options(customDescriptionBuilder: (_, __, ___) => 'annoHegirae'),
  Era.annoMundi.options(customDescriptionBuilder: (_, __, ___) => 'annoMundi'),
  Era.annoPersico
      .options(customDescriptionBuilder: (_, __, ___) => 'annoPersico'),
  Era.bahai.options(customDescriptionBuilder: (_, __, ___) => 'bahai'),
];

void ResourcePresence(Era era) {
  var valueByName = PatternResources.getString(
      IEra.resourceIdentifier(era), Culture.invariant);
  expect(valueByName, isNotEmpty,
      reason: 'Missing resource for ${IEra.resourceIdentifier(era)}');
}

void ToStringReturnsName(Era era) {
  expect(era.toString(), era.name);
}
