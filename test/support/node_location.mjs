// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.

// Preloaded into Node.js by dart_test.yaml. dart2wasm's Uri.base reads
// globalThis.location, which Node.js doesn't have, and with assertions on (as
// in tests) it then fails an assertion instead of throwing UnsupportedError.
// package:stack_trace calls Uri.base whenever it formats a stack trace: for
// every failure, and for every test's location when the JSON reporter is on.
// This defines location as the dart2js Node.js preamble does (configurable, so
// that the preamble can still define it for dart2js).
import { pathToFileURL } from 'node:url';

if (globalThis.location === undefined) {
  Object.defineProperty(globalThis, 'location', {
    configurable: true,
    value: {
      get href() {
        return pathToFileURL(process.cwd()).href + '/';
      },
    },
  });
}
