@tool
extends EditorExportPlugin

const PLUGIN_NAME := "Kirie"


func _get_name() -> String:
	return PLUGIN_NAME


func _supports_platform(platform: EditorExportPlatform) -> bool:
	return platform is EditorExportPlatformAndroid


func _get_android_dependencies(
	_platform: EditorExportPlatform,
	_debug: bool
) -> PackedStringArray:
	# This stays empty until the Android artifact coordinates are finalized.
	return PackedStringArray()


func _get_android_dependencies_maven_repos(
	_platform: EditorExportPlatform,
	_debug: bool
) -> PackedStringArray:
	return PackedStringArray()


func _get_android_libraries(
	_platform: EditorExportPlatform,
	_debug: bool
) -> PackedStringArray:
	if _debug:
		return PackedStringArray(["kirie/libraries/android/Kirie-debug.aar"])

	return PackedStringArray()
