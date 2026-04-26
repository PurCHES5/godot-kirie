package ai.moeru.kirie.android

import android.content.res.AssetManager
import android.net.Uri
import android.webkit.WebResourceResponse
import java.io.FileNotFoundException
import java.io.IOException

class KirieAssetRequestHandler(
    private val assetManager: AssetManager,
) {
    fun open(uri: Uri): WebResourceResponse {
        val assetPath =
            try {
                KirieUrlResolver.assetPathFromResolvedUrl(uri)
            } catch (error: IllegalArgumentException) {
                return errorResponse(403, "Forbidden", error.message ?: "Forbidden")
            }

        return try {
            val inputStream = assetManager.open(assetPath, AssetManager.ACCESS_STREAMING)
            WebResourceResponse(
                mimeTypeFor(assetPath),
                null,
                200,
                "OK",
                RESPONSE_HEADERS,
                inputStream,
            )
        } catch (_: FileNotFoundException) {
            errorResponse(404, "Not Found", "File not found: $assetPath")
        } catch (_: IOException) {
            errorResponse(500, "Internal Server Error", "Failed to read asset: $assetPath")
        }
    }

    private fun errorResponse(
        statusCode: Int,
        reasonPhrase: String,
        message: String,
    ): WebResourceResponse =
        WebResourceResponse(
            "text/plain",
            "utf-8",
            statusCode,
            reasonPhrase,
            RESPONSE_HEADERS,
            message.byteInputStream(Charsets.UTF_8),
        )

    private fun mimeTypeFor(path: String): String {
        val extension =
            path
                .substringAfterLast('/', "")
                .substringAfterLast('.', "")
                .lowercase()

        return MIME_TYPES[extension] ?: "application/octet-stream"
    }

    companion object {
        private val RESPONSE_HEADERS =
            mapOf(
                "Access-Control-Allow-Origin" to "*",
                "Cache-Control" to "no-cache",
            )

        private val MIME_TYPES =
            mapOf(
                "aac" to "audio/aac",
                "apng" to "image/apng",
                "avif" to "image/avif",
                "bmp" to "image/bmp",
                "css" to "text/css",
                "gif" to "image/gif",
                "htm" to "text/html",
                "html" to "text/html",
                "ico" to "image/vnd.microsoft.icon",
                "jpeg" to "image/jpeg",
                "jpg" to "image/jpeg",
                "js" to "text/javascript",
                "json" to "application/json",
                "mjs" to "text/javascript",
                "mp3" to "audio/mpeg",
                "mp4" to "video/mp4",
                "oga" to "audio/ogg",
                "ogg" to "audio/ogg",
                "ogv" to "video/ogg",
                "opus" to "audio/ogg",
                "otf" to "font/otf",
                "png" to "image/png",
                "svg" to "image/svg+xml",
                "ttf" to "font/ttf",
                "txt" to "text/plain",
                "wasm" to "application/wasm",
                "wav" to "audio/wav",
                "weba" to "audio/webm",
                "webm" to "video/webm",
                "webp" to "image/webp",
                "woff" to "font/woff",
                "woff2" to "font/woff2",
                "xml" to "application/xml",
            )
    }
}
