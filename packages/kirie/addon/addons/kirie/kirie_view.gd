class_name KirieView
extends Control

signal webview_ready()
signal ipc_message_received(message: Variant)
signal ipc_error(error: String)

@export var initial_url := ""
@export var auto_create := true
@export var auto_destroy := true

var _kirie := GdKirie.new()


func _ready() -> void:
	_kirie.webview_ready.connect(_on_kirie_webview_ready)
	_kirie.ipc_message_received.connect(_on_kirie_ipc_message_received)
	_kirie.ipc_error.connect(_on_kirie_ipc_error)

	if not auto_create:
		return

	_kirie.create_webview({
		"initial_url": initial_url,
	})


func _exit_tree() -> void:
	if not auto_destroy:
		return

	_kirie.destroy_webview()


func load_url(url: String) -> void:
	_kirie.load_url(url)


func send_ipc_message(message: Variant) -> void:
	_kirie.send_ipc_message(message)


func _on_kirie_webview_ready() -> void:
	webview_ready.emit()


func _on_kirie_ipc_message_received(message: Variant) -> void:
	ipc_message_received.emit(message)


func _on_kirie_ipc_error(error: String) -> void:
	ipc_error.emit(error)
