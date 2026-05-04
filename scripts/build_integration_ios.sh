#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "tests/integration/project.godot" ]; then
    echo "Error: This script must be run from the repository root." >&2
    exit 1
fi

APP_PATH="${APP_PATH:-dist/integration/ios_debug.app}"
XCODE_EXPORT_DIR="dist/integration/ios_xcode"
PROJECT_NAME="integration"
PLUGIN_DIR="packages/kirie/native/ios/Kirie"

mkdir -p "$(dirname "${APP_PATH}")" "${XCODE_EXPORT_DIR}"

echo "Building Godot iOS arm64 simulator template..."
cd godot
scons platform=ios target=template_debug arch=arm64 simulator=yes -j"$(sysctl -n hw.logicalcpu)"
cd ..

ARM64_SRC="godot/bin/libgodot.ios.template_debug.arm64.simulator.a"
if [ ! -f "${ARM64_SRC}" ]; then
    echo "ERROR: scons output not found: ${ARM64_SRC}" >&2
    ls godot/bin/ >&2
    exit 1
fi
echo "Built: $(lipo -info "${ARM64_SRC}")"

echo "Building native iOS plugin (simulator, Debug)..."
PLUGIN_BUILD_DIR="$(pwd)/dist/kirie_plugin_build"

(cd "${PLUGIN_DIR}" && xcodegen generate)

mise x -- xcodebuild \
    -project "${PLUGIN_DIR}/Kirie.xcodeproj" \
    -scheme "Kirie" \
    -sdk iphonesimulator \
    -configuration Debug \
    ARCHS="arm64" \
    EXCLUDED_ARCHS="x86_64" \
    GODOT_SOURCE_ROOT="$(pwd)/godot" \
    CONFIGURATION_BUILD_DIR="${PLUGIN_BUILD_DIR}" \
    build

if [ ! -d "${PLUGIN_BUILD_DIR}/Kirie.framework" ] && [ ! -f "${PLUGIN_BUILD_DIR}/libKirie.a" ]; then
    echo "ERROR: Kirie plugin build produced no output in ${PLUGIN_BUILD_DIR}" >&2
    ls "${PLUGIN_BUILD_DIR}" >&2
    exit 1
fi
echo "Plugin built: $(ls "${PLUGIN_BUILD_DIR}")"

if [ -n "${GODOT_BIN:-}" ]; then
    godot_command=("${GODOT_BIN}")
else
    godot_path="$(mise which godot)"
    resolved="$(readlink "${godot_path}" || true)"
    if [ -n "${resolved}" ] && [ -x "${resolved}" ]; then
        godot_command=(mise x -- "${resolved}")
    else
        godot_command=(mise x -- "${godot_path}")
    fi
fi

INTEGRATION_PLUGIN_DIR="tests/integration/addons/kirie/ios" 
mkdir -p "${INTEGRATION_PLUGIN_DIR}"
rm -rf "${INTEGRATION_PLUGIN_DIR}/Kirie.xcframework"

xcodebuild -create-xcframework \
    -framework "${PLUGIN_BUILD_DIR}/Kirie.framework" \
    -output "${INTEGRATION_PLUGIN_DIR}/Kirie.xcframework"

echo "XCFramework: $(find "${INTEGRATION_PLUGIN_DIR}/Kirie.xcframework" -name "*.framework")"

# ── Now export the Xcode project (plugin is in place) ────────────────────────
echo "Exporting Xcode project..."
"${godot_command[@]}" \
    --headless \
    --path tests/integration \
    --export-debug "iOS" \
    "../../${XCODE_EXPORT_DIR}/${PROJECT_NAME}.xcodeproj"


XCFW_SIMULATOR_LIB="$(find "${XCODE_EXPORT_DIR}" \
    \( -path "*/ios-arm64_x86_64-simulator/libgodot.a" \
    -o -path "*/ios-arm64-simulator/libgodot.a" \) \
    | head -1)"

if [ -z "${XCFW_SIMULATOR_LIB}" ]; then
    echo "ERROR: xcframework simulator libgodot.a not found under ${XCODE_EXPORT_DIR}" >&2
    find "${XCODE_EXPORT_DIR}" -name "*.a" | sort >&2
    exit 1
fi

echo "=== Kirie references in exported xcodeproj ==="
grep -r "Kirie" "${XCODE_EXPORT_DIR}" --include="*.pbxproj" -l || echo "(no reference to Kirie in pbxproj)"

echo "Patching: ${XCFW_SIMULATOR_LIB}"
echo "  Before: $(lipo -info "${XCFW_SIMULATOR_LIB}")"

EXISTING_INFO="$(lipo -info "${XCFW_SIMULATOR_LIB}")"

if echo "${EXISTING_INFO}" | grep -q "Non-fat"; then
    lipo -create "${ARM64_SRC}" "${XCFW_SIMULATOR_LIB}" \
         -output "${XCFW_SIMULATOR_LIB}"
else
    lipo "${XCFW_SIMULATOR_LIB}" -remove arm64 -output /tmp/xcfw_stripped.a
    lipo -create "${ARM64_SRC}" /tmp/xcfw_stripped.a \
         -output "${XCFW_SIMULATOR_LIB}"
fi

echo "  After:  $(lipo -info "${XCFW_SIMULATOR_LIB}")"

echo "Building final .app bundle..."
RAW_BUILD_DIR="$(pwd)/dist/integration_raw_build"

mise x -- xcodebuild \
    -project "${XCODE_EXPORT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${PROJECT_NAME}" \
    -sdk iphonesimulator \
    -destination "generic/platform=iOS Simulator" \
    -configuration Debug \
    CONFIGURATION_BUILD_DIR="${RAW_BUILD_DIR}" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    ARCHS="arm64" \
    EXCLUDED_ARCHS="x86_64" \
    ONLY_ACTIVE_ARCH=YES \
    build

RAW_APP="${RAW_BUILD_DIR}/${PROJECT_NAME}.app"

if [ -d "${RAW_APP}/Frameworks" ]; then
    echo "Frameworks in bundle: $(ls "${RAW_APP}/Frameworks/")"
else
    echo "Frameworks in bundle: (none)"
fi

echo "Checking for built app at: ${RAW_APP}"
ls -la "${RAW_BUILD_DIR}/" || true

if [ ! -d "${RAW_APP}" ]; then
    echo "ERROR: Expected .app not found at ${RAW_APP}" >&2
    exit 1
fi

echo "Moving ${RAW_APP} -> ${APP_PATH}"
mkdir -p "$(dirname "${APP_PATH}")"
rm -rf "${APP_PATH}"
mv "${RAW_APP}" "${APP_PATH}"
rm -rf "${RAW_BUILD_DIR}"
echo "Successfully built: ${APP_PATH}"
