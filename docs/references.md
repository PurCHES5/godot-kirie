# References

This file collects the primary official references for `godot-kirie`.

Use these links before relying on memory for engine behavior, Android plugin
packaging, or platform WebView bridge details.

## Godot

- [Godot Android plugins (stable)](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html)
  Main reference for Godot Android plugin v2 packaging and export flow.
- [Command line tutorial (stable)](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
  Reference for `--remote-debug`, command-line running, and export behavior.
- [Overview of debugging tools (stable)](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/overview_of_debugging_tools.html)
  High-level reference for remote debugging and editor debugging workflows.
- [Debugger panel (stable)](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/debugger_panel.html)
  Reference for runtime debugger capabilities such as scene inspection and
  stack or variable introspection.
- [EditorSettings (stable)](https://docs.godotengine.org/en/stable/classes/class_editorsettings.html)
  Reference for editor debugger settings such as automatic switching to the
  remote scene tree.
- [EditorExportPlugin (stable)](https://docs.godotengine.org/en/stable/classes/class_editorexportplugin.html)
  Reference for `_get_android_libraries()`,
  `_get_android_dependencies()`, and related export hooks.
- [EditorExportPlatformAndroid (stable)](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformandroid.html)
  Android export platform settings, including Gradle build requirements.
- [iOS plugins index (stable)](https://docs.godotengine.org/en/stable/tutorials/platform/ios/index.html)
  Entry point for Godot iOS plugin documentation.
- [Creating iOS plugins](https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html)
  iOS plugin structure, `.gdip`, and packaging expectations.
- [EditorExportPlatformIOS (stable)](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformios.html)
  iOS export platform settings reference.

## Android

- [Android WebView](https://developer.android.com/reference/android/webkit/WebView)
  Primary API reference for WebView lifecycle, `addJavascriptInterface()`, and
  `evaluateJavascript()`.
- [JavascriptInterface](https://developer.android.com/reference/android/webkit/JavascriptInterface)
  Security-critical annotation reference for JavaScript-exposed methods.
- [WebMessage](https://developer.android.com/reference/android/webkit/WebMessage)
  Reference for message payloads when using the platform message APIs.
- [WebMessagePort](https://developer.android.com/reference/android/webkit/WebMessagePort)
  Reference for channel-style messaging on Android WebView.
- [Upload your Android library](https://developer.android.com/studio/publish-library/upload-library)
  Publishing reference for Maven delivery of Android libraries and metadata.
- [Gradle dependency management basics](https://docs.gradle.org/current/userguide/declaring_dependencies_basics.html)
  Reference for module dependencies vs file dependencies and transitive
  dependency behavior.

## Apple

- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)
  Primary API reference for embedded web content on Apple platforms.
- [WKScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler)
  Reference for JavaScript-to-native messaging through
  `window.webkit.messageHandlers`.

## Suggested usage in this repo

- When changing Android plugin packaging, start with the Godot Android plugin
  docs and `EditorExportPlugin`.
- When changing Android IPC, start with `WebView`,
  `JavascriptInterface`, and `WebMessagePort`.
- When changing iOS IPC, start with `WKWebView` and
  `WKScriptMessageHandler`.
