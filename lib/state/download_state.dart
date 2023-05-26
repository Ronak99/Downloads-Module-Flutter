import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:downloads_module/constants/constants.dart';
import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/utils/custom_exception.dart';
import 'package:downloads_module/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadState extends ChangeNotifier {
  final ReceivePort _receivePort = ReceivePort();
  StreamSubscription? _portStateUpdates;

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

  _onReceiveData(data, {required BuildContext context}) async {
    if (data == null) {
      return;
    }

    String? id = data[0];
    int? status = data[1];
    int? progress = data[2];

    print("On receive data | Status: $status");
  }

  // Binds the background isolate
  void bindBackgroundIsolate({required BuildContext context}) {
    bool isSuccess = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      kDownloadsPort,
    );

    if (!isSuccess) {
      _unbindBackgroundIsolate();
      bindBackgroundIsolate(context: context);
      return;
    }

    _portStateUpdates = _receivePort.listen((dynamic data) {
      _onReceiveData(data, context: context);
    });
  }

  // Unbinds the background isolate
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(kDownloadsPort);
  }
}
