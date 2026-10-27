import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalFileService {
  Future<String> saveReportImage(String sourceFilePath, String localUuid) async {
    final appDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory(p.join(appDir.path, 'reports_images'));
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final ext = p.extension(sourceFilePath);
    final targetPath = p.join(reportsDir.path, 'report_$localUuid$ext');
    final sourceFile = File(sourceFilePath);
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<String> saveDownloadedPanorama(List<int> bytes, String sceneUuid) async {
    final appDir = await getApplicationDocumentsDirectory();
    final panoramasDir = Directory(p.join(appDir.path, 'offline_panoramas'));
    if (!await panoramasDir.exists()) {
      await panoramasDir.create(recursive: true);
    }

    final targetPath = p.join(panoramasDir.path, 'pano_$sceneUuid.jpg');
    final file = File(targetPath);
    await file.writeAsBytes(bytes);
    return targetPath;
  }

  Future<void> deleteOfflinePanoramas() async {
    final appDir = await getApplicationDocumentsDirectory();
    final panoramasDir = Directory(p.join(appDir.path, 'offline_panoramas'));
    if (await panoramasDir.exists()) {
      await panoramasDir.delete(recursive: true);
    }
  }
}
