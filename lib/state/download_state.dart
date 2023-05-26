import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/utils/custom_exception.dart';
import 'package:downloads_module/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadState extends ChangeNotifier {
  Future<String> _findDirectory() async {
    try {
      String externalStorageDirPath;
      final directory = await getExternalStorageDirectory();
      externalStorageDirPath = directory!.path;
      return externalStorageDirPath;
    } catch (e) {
      throw CustomException("findLocalPath: $e");
    }
  }

  onDownloadButtonTap({required DownloadItem item}) async {
    String? taskId;

    // Download
    try {
      String directoryPath = await _findDirectory();

      taskId = await FlutterDownloader.enqueue(
        url: item.url,
        savedDir: directoryPath,
        showNotification: true,
        openFileFromNotification: false,
        fileName: '${item.title}.${Utils.getExtensionFromUrl(item.url)}',
      );
    } catch (e) {
      throw CustomException("onDownloadButtonTap: $e");
    }
  }
}
