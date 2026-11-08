#!/usr/bin/env bash
# Runs `flutter test integration_test` on a booted iOS Simulator, and runs it
# again when Flutter fails to start the tests. Used by GitHub's and Azure's
# iOS jobs.
#
# Usage: flutter-test-ios-simulator.sh <udid> <bundle-id> [flutter test args...]
#
# Retries (up to 3 attempts), each flagged as a warning:
#
# - The tool hangs before the tests start, on most first attempts in CI. It
#   finds the app's VM service by reading the engine's "The Dart VM service
#   is listening on" line from the Simulator's log, but launches the app
#   without waiting for its `log stream` to attach, so it can miss the line
#   and wait forever (https://github.com/flutter/flutter/issues/181771).
#   A healthy run prints the first test within about 30 seconds of "Xcode
#   build done."; this treats 2 minutes of silence after that as the hang.
#   Fixed by https://github.com/flutter/flutter/pull/193142: delete this
#   check (and likely the script) once the stable release has it (3.53?).
# - "Unable to start the app on the device": e.g. `xcodebuild
#   -showBuildSettings` timed out on a busy runner, so nothing was built.
#
# A test failure is never retried.
set -uo pipefail

udid=$1
bundle_id=$2
shift 2

attempts=3
quiet_limit=${QUIET_LIMIT_SECONDS:-120}

warn() {
  if [ -n "${TF_BUILD:-}" ]; then
    echo "##vso[task.logissue type=warning]$1"
  elif [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "::warning::$1"
  else
    echo "warning: $1"
  fi
}

log=$(mktemp)
for attempt in $(seq 1 $attempts); do
  [ "$attempt" -gt 1 ] && echo "=== Attempt $attempt of $attempts"
  : > "$log"
  flutter test integration_test --device-id "$udid" "$@" > >(tee "$log") 2>&1 &
  pid=$!

  hung=
  last_size=-1
  quiet=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep 5
    grep -q "Xcode build done" "$log" || continue
    size=$(wc -c < "$log")
    if [ "$size" -eq "$last_size" ]; then
      quiet=$((quiet + 5))
    else
      quiet=0
      last_size=$size
    fi
    if [ "$quiet" -ge "$quiet_limit" ]; then
      hung=1
      break
    fi
  done

  if [ -n "$hung" ]; then
    warn "flutter test hung waiting for the app's VM service (attempt $attempt of $attempts)"
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
  else
    status=0
    wait "$pid" || status=$?
    if [ "$status" -eq 0 ] || ! grep -q "Unable to start the app on the device" "$log"; then
      exit "$status"
    fi
    warn "flutter test couldn't start the app (attempt $attempt of $attempts)"
  fi
  xcrun simctl terminate "$udid" "$bundle_id" 2>/dev/null
done

echo "flutter test didn't start the tests in $attempts attempts" >&2
exit 1
