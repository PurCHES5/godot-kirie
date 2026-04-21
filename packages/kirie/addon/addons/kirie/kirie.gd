class_name Kirie
extends Object

signal webview_ready(webview_id: StringName)
signal ipc_message_received(webview_id: StringName, message: Variant)
signal ipc_error(webview_id: StringName, error: String)


func create_webview(_options: Dictionary = {}) -> StringName:
	push_warning("Kirie.create_webview() is not implemented yet")
	return &""


func destroy_webview(_webview_id: StringName) -> void:
	push_warning("Kirie.destroy_webview() is not implemented yet")


func load_url(_webview_id: StringName, _url: String) -> void:
	push_warning("Kirie.load_url() is not implemented yet")


func send_ipc_message(_webview_id: StringName, _message: Variant) -> void:
	push_warning("Kirie.send_ipc_message() is not implemented yet")
