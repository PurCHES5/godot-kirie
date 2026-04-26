class_name GdKirie
extends Object

signal webview_ready()
signal ipc_message_received(message: Variant)
signal ipc_error(error: String)

const PLUGIN_SINGLETON_NAME := "Kirie"

var _plugin_singleton = null


func _init() -> void:
	if Engine.has_singleton(PLUGIN_SINGLETON_NAME):
		_plugin_singleton = Engine.get_singleton(PLUGIN_SINGLETON_NAME)
		print("[Kirie][gd] platform singleton detected")
		_connect_plugin_signals()
		return

	print("[Kirie][gd] platform singleton unavailable")


func create_webview(options: Dictionary = {}) -> void:
	if not _ensure_plugin_singleton("create_webview"):
		return

	var initial_url := ""
	if options.has("initial_url"):
		initial_url = str(options["initial_url"])

	print("[Kirie][gd] create_webview initial_url=%s" % initial_url)
	_plugin_singleton.createWebView(initial_url)


func destroy_webview() -> void:
	if not _ensure_plugin_singleton("destroy_webview"):
		return

	print("[Kirie][gd] destroy_webview")
	_plugin_singleton.destroyWebView()


func load_url(url: String) -> void:
	if not _ensure_plugin_singleton("load_url"):
		return

	print("[Kirie][gd] load_url url=%s" % url)
	_plugin_singleton.loadUrl(url)


func load_html_string(html: String, base_url: String = "") -> void:
	if not _ensure_plugin_singleton("load_html_string"):
		return

	print("[Kirie][gd] load_html_string bytes=%d base_url=%s" % [html.length(), base_url])
	_plugin_singleton.loadHtmlString(html, base_url)


func send_ipc_message(message: Variant) -> void:
	if not _ensure_plugin_singleton("send_ipc_message"):
		return

	var message_json := JSON.stringify(message)
	print("[Kirie][gd] send_ipc_message %s" % message_json)
	_plugin_singleton.sendIpcMessage(message_json)


func is_available() -> bool:
	return _plugin_singleton != null


func _connect_plugin_signals() -> void:
	if _plugin_singleton == null:
		return

	if OS.get_name() == "iOS":
		print("[Kirie][gd] registering iOS callbacks")
		_plugin_singleton.registerCallbacks(
			Callable(self, "_on_plugin_webview_ready"),
			Callable(self, "_on_plugin_ipc_message_received"),
			Callable(self, "_on_plugin_ipc_error"),
		)
		return

	if _plugin_singleton.has_signal(&"webview_ready"):
		print("[Kirie][gd] connecting Android webview_ready signal")
		_plugin_singleton.webview_ready.connect(_on_plugin_webview_ready)

	if _plugin_singleton.has_signal(&"ipc_message_received"):
		print("[Kirie][gd] connecting Android ipc_message_received signal")
		_plugin_singleton.ipc_message_received.connect(_on_plugin_ipc_message_received)

	if _plugin_singleton.has_signal(&"ipc_error"):
		print("[Kirie][gd] connecting Android ipc_error signal")
		_plugin_singleton.ipc_error.connect(_on_plugin_ipc_error)


func _ensure_plugin_singleton(method_name: String) -> bool:
	if _plugin_singleton != null:
		return true

	var error := "Kirie platform singleton is not available for %s()" % method_name
	push_warning(error)
	ipc_error.emit(error)
	return false


func _on_plugin_webview_ready() -> void:
	print("[Kirie][gd] signal webview_ready")
	webview_ready.emit()


func _on_plugin_ipc_message_received(message_json: String) -> void:
	print("[Kirie][gd] signal ipc_message_received raw=%s" % message_json)
	var parsed_message := JSON.parse_string(message_json)
	if parsed_message == null and message_json != "null":
		ipc_message_received.emit(message_json)
		return

	ipc_message_received.emit(parsed_message)


func _on_plugin_ipc_error(error: String) -> void:
	print("[Kirie][gd] signal ipc_error %s" % error)
	ipc_error.emit(error)
