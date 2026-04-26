import Foundation
import WebKit

final class KirieResourceURLSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(KirieURLResolverError.invalidURL("<nil>"))
            return
        }

        do {
            let fileURL = try KirieURLResolver.bundleFileURL(forResolvedResourceURL: url)
            let data = try Data(contentsOf: fileURL)
            let response = response(
                for: url,
                statusCode: 200,
                reasonPhrase: "OK",
                mimeType: mimeType(for: fileURL.path),
                contentLength: data.count
            )

            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            let message = error.localizedDescription
            let data = Data(message.utf8)
            let response = response(
                for: url,
                statusCode: statusCode(for: error),
                reasonPhrase: reasonPhrase(for: error),
                mimeType: "text/plain",
                contentLength: data.count
            )

            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }

    private func response(
        for url: URL,
        statusCode: Int,
        reasonPhrase: String,
        mimeType: String,
        contentLength: Int
    ) -> URLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Access-Control-Allow-Origin": "*",
                "Cache-Control": "no-cache",
                "Content-Length": "\(contentLength)",
                "Content-Type": mimeType,
            ]
        ) ?? URLResponse(
            url: url,
            mimeType: mimeType,
            expectedContentLength: contentLength,
            textEncodingName: "utf-8"
        )
    }

    private func statusCode(for error: Error) -> Int {
        if let resolverError = error as? KirieURLResolverError {
            switch resolverError {
            case .resourceNotFound:
                return 404
            default:
                return 403
            }
        }

        return 500
    }

    private func reasonPhrase(for error: Error) -> String {
        if let resolverError = error as? KirieURLResolverError {
            switch resolverError {
            case .resourceNotFound:
                return "Not Found"
            default:
                return "Forbidden"
            }
        }

        return "Internal Server Error"
    }

    private func mimeType(for path: String) -> String {
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        return Self.mimeTypes[fileExtension] ?? "application/octet-stream"
    }

    private static let mimeTypes = [
        "aac": "audio/aac",
        "apng": "image/apng",
        "avif": "image/avif",
        "bmp": "image/bmp",
        "css": "text/css",
        "gif": "image/gif",
        "htm": "text/html",
        "html": "text/html",
        "ico": "image/vnd.microsoft.icon",
        "jpeg": "image/jpeg",
        "jpg": "image/jpeg",
        "js": "text/javascript",
        "json": "application/json",
        "map": "application/json",
        "mjs": "text/javascript",
        "mp3": "audio/mpeg",
        "mp4": "video/mp4",
        "oga": "audio/ogg",
        "ogg": "audio/ogg",
        "ogv": "video/ogg",
        "opus": "audio/ogg",
        "otf": "font/otf",
        "png": "image/png",
        "svg": "image/svg+xml",
        "ttf": "font/ttf",
        "txt": "text/plain",
        "wasm": "application/wasm",
        "wav": "audio/wav",
        "weba": "audio/webm",
        "webm": "video/webm",
        "webp": "image/webp",
        "woff": "font/woff",
        "woff2": "font/woff2",
        "xml": "application/xml",
    ]
}
