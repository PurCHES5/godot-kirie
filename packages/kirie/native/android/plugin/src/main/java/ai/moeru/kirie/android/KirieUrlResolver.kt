package ai.moeru.kirie.android

import android.net.Uri

object KirieUrlResolver {
    private const val RES_SCHEME_PREFIX = "res://"
    private const val KIRIE_ASSET_SCHEME = "https"
    private const val KIRIE_ASSET_HOST = "res.kirie.invalid"
    private const val KIRIE_ASSET_BASE_URL = "$KIRIE_ASSET_SCHEME://$KIRIE_ASSET_HOST/"

    fun resolveForWebView(url: String): String {
        if (!url.startsWith(RES_SCHEME_PREFIX, ignoreCase = true)) {
            return url
        }

        val suffix = url.substring(RES_SCHEME_PREFIX.length)
        val pathEnd = suffix.indexOfAny(charArrayOf('?', '#')).takeIf { it != -1 } ?: suffix.length
        val encodedPath = suffix.take(pathEnd)
        val queryAndFragment = suffix.drop(pathEnd)

        require(encodedPath.isNotBlank()) { "Cannot load empty res:// asset path" }
        require(hasValidPercentEncoding(encodedPath)) { "Cannot load res:// URL with invalid percent encoding: $url" }

        val decodedPath = Uri.decode(encodedPath).trimStart('/')
        require(decodedPath.isNotBlank()) { "Cannot load empty res:// asset path" }
        require(decodedPath.indexOf('\u0000') == -1 && !containsPathTraversal(decodedPath)) {
            "Cannot load unsafe res:// asset path: $url"
        }

        val assetPath = resolveAssetPath(decodedPath)
        return KIRIE_ASSET_BASE_URL + Uri.encode(assetPath, "/") + queryAndFragment
    }

    fun isResolvedAssetUrl(uri: Uri): Boolean =
        KIRIE_ASSET_SCHEME.equals(uri.scheme, ignoreCase = true) &&
            KIRIE_ASSET_HOST.equals(uri.host, ignoreCase = true)

    fun assetPathFromResolvedUrl(uri: Uri): String {
        require(isResolvedAssetUrl(uri)) { "Not a Kirie asset URL: $uri" }

        val encodedPath = uri.encodedPath?.trimStart('/') ?: ""
        require(encodedPath.isNotBlank()) { "Cannot load empty Kirie asset path" }
        require(hasValidPercentEncoding(encodedPath)) { "Cannot load Kirie asset URL with invalid percent encoding: $uri" }

        val decodedPath = Uri.decode(encodedPath)
        require(decodedPath.indexOf('\u0000') == -1 && !containsPathTraversal(decodedPath)) {
            "Cannot load unsafe Kirie asset path: $uri"
        }

        return decodedPath
    }

    private fun hasValidPercentEncoding(value: String): Boolean {
        var index = 0
        while (index < value.length) {
            if (value[index] != '%') {
                index += 1
                continue
            }

            if (
                index + 2 >= value.length ||
                !value[index + 1].isHexDigit() ||
                !value[index + 2].isHexDigit()
            ) {
                return false
            }

            index += 3
        }

        return true
    }

    private fun containsPathTraversal(path: String): Boolean =
        path
            .replace('\\', '/')
            .split('/')
            .any { segment -> segment == ".." }

    private fun resolveAssetPath(path: String): String {
        val trimmedPath = path.trimEnd('/')
        val lastSegment = trimmedPath.substringAfterLast('/')

        return if (path.endsWith('/') || !lastSegment.contains('.')) {
            "$trimmedPath/index.html"
        } else {
            path
        }
    }

    private fun Char.isHexDigit(): Boolean = this in '0'..'9' || this in 'a'..'f' || this in 'A'..'F'
}
