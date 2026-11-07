// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

/// Exception thrown to indicate that the specified value could not be parsed.
// todo: should match FormatException's format better..er (Do I want FormatException.. is it compatible? I wish Exception\Error had a common ancestor)
// todo: Is Unparsable (vs Unparseable) okay phrasing -- it's a bit weird? NotParsedValueError ???
class UnparsableValueError extends Error {
  // extends FormatException {
  final String message;

  /// The value which could not be parsed: the whole text that was passed to
  /// the pattern's `parse` method.
  ///
  /// This is the empty string when the error wasn't created with a value.
  final String value;

  /// The index within [value] at which parsing failed, or -1 if the failure
  /// was detected after parsing (for example, a day-of-month which doesn't
  /// exist in the parsed month) or no index is available.
  final int index;

  /// Creates a new [UnparsableValueError] with the given message, and
  /// optionally the value which couldn't be parsed and the index within it at
  /// which parsing failed.
  ///
  /// * [message]: The failure message
  /// * [value]: The value which couldn't be parsed.
  /// * [index]: The index within [value] at which parsing failed, or -1.
  UnparsableValueError(this.message, {this.value = '', this.index = -1});

  @override
  String toString() => message;
}
