// ignore_for_file: avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:downloads_module/constants/constants.dart';
import 'package:downloads_module/model/custom_download_task.dart';
import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/screens/downloads_page.dart';
import 'package:downloads_module/screens/widgets/downloads_bottom_sheet.dart';
import 'package:downloads_module/utils/custom_exception.dart';
import 'package:downloads_module/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadState extends ChangeNotifier {
  // port
  final ReceivePort _receivePort = ReceivePort();
  StreamSubscription? _portStateUpdates;

  final List<CustomDownloadTask> _itemDownloadTasks = [];
  DownloadItem? _currentDownloadItem;

  CustomDownloadTask? get currentItemDownloadTask {
    int index = getTaskIndex(url: _currentDownloadItem!.url);

    if (index == -1) {
      return null;
    } else {
      return _itemDownloadTasks[index];
    }
  }

  int getTaskIndex({required String url}) {
    return _itemDownloadTasks.indexWhere((task) => task.url == url);
  }

  intialize({required DownloadItem downloadItem}) async {
    _currentDownloadItem = downloadItem;

    _addToItemDownloadTasks(
      CustomDownloadTask(
        url: downloadItem.url,
        itemId: downloadItem.id,
      ),
    );

    List<DownloadTask>? downloadTaskList = await _loadDownloadTasks();

    downloadTaskList.forEach((downloadTask) {
      for (CustomDownloadTask itemDownloadTask in _itemDownloadTasks) {
        if (downloadTask.url == itemDownloadTask.url) {
          itemDownloadTask.setTaskId(downloadTask.taskId);
          itemDownloadTask.setStatus(downloadTask.status);
          itemDownloadTask.setProgress(downloadTask.progress);
        }
      }
    });

    notifyListeners();
  }

  _addToItemDownloadTasks(CustomDownloadTask downloadTask) {
    int index = getTaskIndex(url: downloadTask.url);
    if (index != -1) {
      _itemDownloadTasks.removeAt(index);
    }
    _itemDownloadTasks.add(downloadTask);
  }

  Future<List<DownloadTask>> _loadDownloadTasks() async {
    List<DownloadTask>? downloadTaskList = await FlutterDownloader.loadTasks();
    return downloadTaskList ?? [];
  }

  Future<String> _findDirectory() async {
    try {
      String externalStorageDirPath;
      final directory = await getApplicationDocumentsDirectory();
      externalStorageDirPath = directory.path;
      return externalStorageDirPath;
    } catch (e) {
      throw CustomException("findLocalPath: $e");
    }
  }

  onDownloadButtonTap({
    required DownloadItem item,
    required BuildContext context,
  }) async {
    if (currentItemDownloadTask == null) {
      _enqueueDownload(item);
      return;
    } else if (currentItemDownloadTask!.isComplete ||
        currentItemDownloadTask!.isRunning) {
      // show go to downloads, and remove from downloads options
      _handleUserAction(context);
      return;
    } else if (currentItemDownloadTask!.isPaused) {
      _resumeDownload();
      return;
    } else {
      _enqueueDownload(item);
      return;
    }
  }

  void _handleUserAction(context) async {
    DownloadsResponse? response =
        await DownloadsBottomSheet.show<DownloadsResponse?>(context);

    if (response == null) {
      return;
    }

    switch (response) {
      case DownloadsResponse.goToDownloads:
        Navigator.push(context, DownloadsPage.route());
        break;
      case DownloadsResponse.pauseDownload:
        _pauseDownload();
        break;
      case DownloadsResponse.cancelDownload:
        _cancelDownload();
        break;
      case DownloadsResponse.removeDownload:
        // TODO: Handle this case.
        break;
    }
  }

  _enqueueDownload(DownloadItem item) async {
    // Download
    try {
      String directoryPath = await _findDirectory();

      String? taskId = await FlutterDownloader.enqueue(
        url: item.url,
        savedDir: directoryPath,
        showNotification: true,
        openFileFromNotification: false,
        fileName: '${item.title}.${Utils.getExtensionFromUrl(item.url)}',
      );

      CustomDownloadTask itemDownloadTask = CustomDownloadTask(
        url: item.url,
        itemId: item.id,
      )..setTaskId(taskId!);

      _addToItemDownloadTasks(itemDownloadTask);
    } catch (e) {
      throw CustomException("onDownloadButtonTap: $e");
    }
  }

  _pauseDownload() {
    try {
      FlutterDownloader.pause(taskId: currentItemDownloadTask!.taskId!);
    } catch (e) {
      throw CustomException("Error in pausing download, $e");
    }
  }

  _resumeDownload() async {
    try {
      String? taskId = await FlutterDownloader.resume(
          taskId: currentItemDownloadTask!.taskId!);

      int index = _itemDownloadTasks
          .indexWhere((e) => e.taskId == currentItemDownloadTask!.taskId!);
      CustomDownloadTask downloadTask = _itemDownloadTasks[index];
      downloadTask.setTaskId(taskId!);

      _itemDownloadTasks.removeAt(index);
      _itemDownloadTasks.insert(index, downloadTask);
    } catch (e) {
      throw CustomException("Error in resuming download, $e");
    }
  }

  _cancelDownload() {
    try {
      FlutterDownloader.cancel(taskId: currentItemDownloadTask!.taskId!);
    } catch (e) {
      throw CustomException("Error in pausing download, $e");
    }
  }

  removeAll() async {
    List<DownloadTask>? taskList = await FlutterDownloader.loadTasks();

    if (taskList != null && taskList.isNotEmpty) {
      for (DownloadTask t in taskList) {
        await FlutterDownloader.remove(taskId: t.taskId);
      }
    }
    _itemDownloadTasks.clear();
    print('removed all');
  }

  _onReceiveData(data, {required BuildContext context}) async {
    if (data == null) {
      return;
    }

    String? id = data[0];
    int? status = data[1];
    int? progress = data[2];

    DownloadTaskStatus downloadTaskStatus = DownloadTaskStatus(status!);

    int index = _itemDownloadTasks.indexWhere((task) => task.taskId == id);

    if (index == -1) {
      return;
    }
    _itemDownloadTasks[index].setStatus(downloadTaskStatus);
    _itemDownloadTasks[index].setProgress(progress!);

    notifyListeners();
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
