#!/usr/bin/env bash

set -euo pipefail

if [ ! -f "tests/integration/project.godot" ]; then
    echo "This script must be run from the repository root." >&2
    exit 1
fi

APK_PATH="${APK_PATH:-dist/integration/android_debug.apk}"

mkdir -p "$(dirname "${APK_PATH}")"

mise x -- packages/kirie/native/android/gradlew \
    --project-dir packages/kirie/native/android \
    :plugin:assembleDebug

if [ -n "${GODOT_BIN:-}" ]; then
    godot_command=("${GODOT_BIN}")
else
    godot_path="$(mise which godot)"
    resolved_godot_path="$(readlink "${godot_path}" || true)"
    if [ -n "${resolved_godot_path}" ] && [ -x "${resolved_godot_path}" ]; then
        godot_command=(mise x -- "${resolved_godot_path}")
    else
        godot_command=(mise x -- "${godot_path}")
    fi
fi

"${godot_command[@]}" \
    --headless \
    --path tests/integration \
    --install-android-build-template \
    --export-debug "Android" \
    "../../${APK_PATH}"

echo "Exported ${APK_PATH}"
