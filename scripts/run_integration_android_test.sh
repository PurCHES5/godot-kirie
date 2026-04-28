#!/usr/bin/env bash

set -euo pipefail

if [ ! -f "tests/integration/project.godot" ]; then
    echo "This script must be run from the repository root." >&2
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: scripts/run_integration_android_test.sh <test_name>" >&2
    exit 1
fi

TEST_NAME="$1"
PACKAGE_NAME="${PACKAGE_NAME:-ai.moeru.kirie.integrationtests}"
ACTIVITY_NAME="${ACTIVITY_NAME:-com.godot.game.GodotAppLauncher}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-30}"
LOG_FILE="${LOG_FILE:-${TMPDIR:-/tmp}/kirie-integration-${TEST_NAME}.log}"

cleanup() {
    if [ -n "${LOGCAT_PID:-}" ]; then
        kill "${LOGCAT_PID}" >/dev/null 2>&1 || true
        wait "${LOGCAT_PID}" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

: > "${LOG_FILE}"
adb logcat -c
adb shell am force-stop "${PACKAGE_NAME}" >/dev/null 2>&1 || true
adb shell pm clear "${PACKAGE_NAME}" >/dev/null

adb logcat > "${LOG_FILE}" &
LOGCAT_PID="$!"

adb shell am start \
    -n "${PACKAGE_NAME}/${ACTIVITY_NAME}" \
    --es kirie_test "${TEST_NAME}" \
    >/dev/null

deadline=$((SECONDS + TIMEOUT_SECONDS))
while [ "${SECONDS}" -lt "${deadline}" ]; do
    if fail_line="$(grep -m 1 -E "KIRIE_TEST_FAIL (${TEST_NAME}|unknown)( |$)" "${LOG_FILE}")"; then
        echo "${fail_line}" >&2
        exit 1
    fi

    if pass_line="$(grep -m 1 -E "KIRIE_TEST_PASS ${TEST_NAME}( |$)" "${LOG_FILE}")"; then
        echo "${pass_line}"
        exit 0
    fi

    sleep 0.5
done

echo "Timed out waiting for KIRIE_TEST_PASS or KIRIE_TEST_FAIL for ${TEST_NAME}" >&2
tail -n 120 "${LOG_FILE}" >&2
exit 1
