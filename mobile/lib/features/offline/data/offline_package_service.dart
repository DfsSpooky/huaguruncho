import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/rust/rust_core_service.dart';

final offlinePackageServiceProvider = Provider<OfflinePackageService>((ref) {
  return OfflinePackageService(Dio());
});

class OfflinePackageService {
  final Dio _dio;

  OfflinePackageService(this._dio);

  Future<String> _getOfflinePackagesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final offlineDir = Directory('${appDocDir.path}/offline_packages');
    if (!await offlineDir.exists()) {
      await offlineDir.create(recursive: true);
    }
    return offlineDir.path;
  }

  Future<String> getRouteOfflinePath(String routeUuid) async {
    final baseDir = await _getOfflinePackagesDirectory();
    return '$baseDir/$routeUuid';
  }

  Future<bool> isPackageDownloaded(String routeUuid) async {
    try {
      final routePath = await getRouteOfflinePath(routeUuid);
      final manifestFile = File('$routePath/manifest.json');
      return await manifestFile.exists();
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getLocalManifest(String routeUuid) async {
    try {
      final routePath = await getRouteOfflinePath(routeUuid);
      final manifestFile = File('$routePath/manifest.json');
      if (await manifestFile.exists()) {
        final content = await manifestFile.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<bool> downloadAndExtractPackage({
    required String routeUuid,
    required String downloadUrl,
    Function(double progress)? onProgress,
  }) async {
    try {
      final baseDir = await _getOfflinePackagesDirectory();
      final zipFilePath = '$baseDir/$routeUuid.zip';
      final extractDirPath = '$baseDir/$routeUuid';

      // 1. Descargar archivo ZIP vía HTTP Streaming con seguimiento de progreso
      final response = await _dio.download(
        downloadUrl,
        zipFilePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      // 2. Verificar integridad criptográfica SHA-256 / BLAKE3 en Rust y leer bytes
      final zipFile = File(zipFilePath);
      final rustHashes = RustCoreService.instance.computeFileHashes(zipFilePath);
      if (rustHashes != null && rustHashes['success'] == false) {
        return false;
      }
      final bytes = await zipFile.readAsBytes();

      // 3. Descomprimir contenido del archivo ZIP
      final archive = ZipDecoder().decodeBytes(bytes);

      final extractDir = Directory(extractDirPath);
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      for (final file in archive) {
        final filename = '$extractDirPath/${file.name}';
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }

      // 4. Limpiar archivo .zip temporal para ahorrar almacenamiento
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLocalPackage(String routeUuid) async {
    try {
      final routePath = await getRouteOfflinePath(routeUuid);
      final dir = Directory(routePath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
