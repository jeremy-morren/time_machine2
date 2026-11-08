// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

import 'package:test/test.dart';

/// Marks the current test as skipped, with [reason], unless [condition] holds;
/// the equivalent of NUnit's Assert.Ignore. Returns true if the test should
/// stop, so tests can write `if (skipUnless(isWindows, 'Windows only')) return;`.
bool skipUnless(bool condition, String reason) {
  if (!condition) markTestSkipped(reason);
  return !condition;
}

/// Whether integers are JavaScript numbers, as when compiled with dart2js:
/// exact only within ±2^53, where the VM and dart2wasm have 64-bit integers.
/// (In a parameterized test, `testOn: '!js'` would skip every case.)
// Evaluated at run time, so it's the compiled program's answer.
// ignore: prefer_const_declarations
final bool intsAreJsNumbers = identical(1, 1.0);
