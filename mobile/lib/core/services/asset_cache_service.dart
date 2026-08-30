import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Service responsible for downloading and locally caching 3D GLB assets and thumbnails.
class AssetCacheService {
  Directory? _cacheDir;

  Future<Directory> get _dir async {
    if (_cacheDir != null) return _cacheDir!;
    final baseDir = await getApplicationDocumentsDirectory();
    final assetDir = Directory('${baseDir.path}/gym3d_assets_cache');
    if (!await assetDir.exists()) {
      await assetDir.create(recursive: true);
    }
    _cacheDir = assetDir;
    return _cacheDir!;
  }

  /// Hashes a remote URL into a safe filename with original extension.
  String _urlToFilename(String url) {
    final hash = crypto.md5.convert(utf8.encode(url)).toString();
    final extension = url.split('.').last.split('?').first;
    return '$hash.$extension';
  }

  /// Checks if a file is already cached locally.
  Future<bool> isCached(String url) async {
    final dir = await _dir;
    final file = File('${dir.path}/${_urlToFilename(url)}');
    return file.exists();
  }

  /// Returns the local file path if cached, or downloads and caches it.
  Future<String> getLocalOrDownload(String url) async {
    final dir = await _dir;
    final file = File('${dir.path}/${_urlToFilename(url)}');

    if (await file.exists()) {
      return file.path;
    }

    // Download from remote
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download asset: HTTP ${response.statusCode}');
    }
  }

  /// Clears all downloaded cached assets.
  Future<void> clearCache() async {
    final dir = await _dir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      _cacheDir = null;
    }
  }
}

/// Provider for AssetCacheService.
final assetCacheServiceProvider = Provider<AssetCacheService>((ref) {
  return AssetCacheService();
});
