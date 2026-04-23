import Dispatch
import Foundation

@_cdecl("kirie_swift_init")
public func kirie_swift_init() {
    DispatchQueue.main.async {
        _ = KirieManager.shared
    }
}

@_cdecl("kirie_swift_deinit")
public func kirie_swift_deinit() {
    DispatchQueue.main.async {
        KirieManager.shared.destroyWebView()
    }
}

@_cdecl("kirie_swift_create_webview")
public func kirie_swift_create_webview(_ initialURLPointer: UnsafePointer<CChar>?) {
    let initialURL = initialURLPointer.map { String(cString: $0) }
    DispatchQueue.main.async {
        KirieManager.shared.createWebView(initialURL: initialURL?.isEmpty == true ? nil : initialURL)
    }
}

@_cdecl("kirie_swift_destroy_webview")
public func kirie_swift_destroy_webview() {
    DispatchQueue.main.async {
        KirieManager.shared.destroyWebView()
    }
}

@_cdecl("kirie_swift_load_url")
public func kirie_swift_load_url(_ urlPointer: UnsafePointer<CChar>?) {
    guard let urlPointer else {
        return
    }

    let url = String(cString: urlPointer)
    DispatchQueue.main.async {
        KirieManager.shared.loadURL(url)
    }
}

@_cdecl("kirie_swift_load_html_string")
public func kirie_swift_load_html_string(_ htmlPointer: UnsafePointer<CChar>?, _ baseURLPointer: UnsafePointer<CChar>?) {
    guard let htmlPointer else {
        return
    }

    let html = String(cString: htmlPointer)
    let baseURL = baseURLPointer.map { String(cString: $0) }

    DispatchQueue.main.async {
        KirieManager.shared.loadHTMLString(html, baseURLString: baseURL?.isEmpty == true ? nil : baseURL)
    }
}

@_cdecl("kirie_swift_send_ipc_message")
public func kirie_swift_send_ipc_message(_ messageJSONPointer: UnsafePointer<CChar>?) {
    guard let messageJSONPointer else {
        return
    }

    let messageJSON = String(cString: messageJSONPointer)
    DispatchQueue.main.async {
        KirieManager.shared.sendIpcMessage(messageJSON)
    }
}
