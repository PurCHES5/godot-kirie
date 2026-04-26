# Kirie iOS Plugin

This directory contains the native iOS implementation for `Kirie`, the first-pass transparent web UI layer for the Godot project.

## What this version does

- Exposes `init_kirie` and `deinit_kirie` entry points for the Godot iOS plugin system.
- Registers the `Kirie` Godot singleton.
- Creates a transparent full-screen `WKWebView` through `createWebView`.
- Bridges IPC with `window.webkit.messageHandlers.kirie.postMessage(...)` and
  `kirie:ipc-message` DOM events.
- Resolves `res://` web URLs to files exported into the app bundle and serves
  them through Kirie's `WKURLSchemeHandler`.

`res://` loading is intentionally limited to packaged application bundle
resources. For example, `res://web/index.html` resolves to Kirie's resource
origin and serves `web/index.html` from the app bundle. `res://web` resolves to
`web/index.html`. Runtime-mounted Godot packs are not part of this path.
`http://`, `https://`, and `file://` URLs keep the default `WKWebView` loading
behavior.

## Tooling

- `xcodebuild`
- `xcodegen`
- Apple toolchain from the installed Xcode

The project definition lives in [project.yml](./project.yml). The generated `.xcodeproj` is intentionally not committed.

## Build

Run the repository-level helper:

```sh
./scripts/build_kirie_ios.sh
```

The script will:

1. Generate a local Xcode project under `.generated/`
2. Archive `Kirie` for `iphoneos` and `iphonesimulator`
3. Create `Kirie.xcframework`
4. Copy the result into `res://ios/plugins/kirie/`

## Runtime configuration

No runtime plist keys are required for the current IPC path.

Those keys are surfaced to Godot through the plugin descriptor in `ios/plugins/kirie/Kirie.gdip`.

## Notes

- The WebView is visually transparent, but it still captures touches everywhere it covers.
- ATS is currently widened unconditionally via the plugin plist injection.
- Invalid TLS certificates are currently bypassed unconditionally.
- TODO: Narrow ATS and TLS bypass to debug-only before shipping.

## Current packaging direction

- use Godot's standard iOS plugin flow with a `.gdip` file
- keep the current milestone compatible with `res://ios/plugins`
- defer any editor-generated `gdip` shim workflow until after the iOS IPC path
  is working
