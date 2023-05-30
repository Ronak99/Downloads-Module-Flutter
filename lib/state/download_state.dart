// ignore_for_file: avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:downloads_module/constants/constants.dart';
import 'package:downloads_module/model/custom_download_task.dart';
import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/screens/downloads_page.dart';
import 'package:downloads_module/screens/widgets/downloads_bottom_sheet.dart';
import 'package:downloads_module/state/downloads_provider.dart';
import 'package:downloads_module/utils/custom_exception.dart';
import 'package:downloads_module/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DownloadState extends ChangeNotifier {
  // port
  final ReceivePort _receivePort = ReceivePort();
  StreamSubscription? _portStateUpdates;

  final List<CustomDownloadTask> _itemDownloadTasks = [];
  final List<DownloadItem> _downloadItemList = [];

  DownloadItem? _currentDownloadItem;

  CustomDownloadTask? get currentItemDownloadTask {
    int index = getTaskIndex(taskId: _currentDownloadItem!.taskId);

    if (index == -1) {
      return null;
    } else {
      return _itemDownloadTasks[index];
    }
  }

  int getTaskIndex({required String? taskId}) {
    return _itemDownloadTasks.indexWhere((task) => task.taskId == taskId);
  }

  int getDownloadItemIndex({required String? taskId}) {
    return _downloadItemList.indexWhere((item) => item.taskId == taskId);
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
    if (downloadTask.taskId == null) return;
    int index = getTaskIndex(taskId: downloadTask.taskId);
    if (index != -1) {
      _itemDownloadTasks.removeAt(index);
    }
    _itemDownloadTasks.add(downloadTask);
  }

  _addToDownloadItemList(DownloadItem downloadItem) {
    if (downloadItem.taskId == null) return;
    int index = getDownloadItemIndex(taskId: downloadItem.taskId);
    if (index != -1) {
      _downloadItemList.removeAt(index);
    }
    _downloadItemList.add(downloadItem);
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
    } else if (currentItemDownloadTask!.isComplete ||
        currentItemDownloadTask!.isRunning) {
      // show go to downloads, and remove from downloads options
      _handleUserAction(context);
    } else if (currentItemDownloadTask!.isPaused) {
      _resumeDownload();
    } else {
      _enqueueDownload(item);
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
        Provider.of<DownloadsProvider>(context, listen: false)
            .removeFromDownloads(_currentDownloadItem!.id, context: context);
        break;
    }
  }

  _enqueueDownload(DownloadItem item) async {
    // Download
    try {
      String directoryPath = await _findDirectory();

      String fileName = '${item.title}.${Utils.getExtensionFromUrl(item.url)}';

      String? taskId = await FlutterDownloader.enqueue(
        url: item.url,
        savedDir: directoryPath,
        showNotification: true,
        openFileFromNotification: false,
        fileName: fileName,
      );

      // initialized item download task and added it to the list
      CustomDownloadTask itemDownloadTask = CustomDownloadTask(
        url: item.url,
        itemId: item.id,
      )
        ..setTaskId(taskId!)
        ..setFileName(fileName)
        ..setFilePath("$directoryPath/$fileName");

      _addToItemDownloadTasks(itemDownloadTask);

      item.setTaskId(taskId);
      _addToDownloadItemList(item);
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
      String oldTaskId = currentItemDownloadTask!.taskId!;
      String? newTaskId = await FlutterDownloader.resume(taskId: oldTaskId);
      _currentDownloadItem!.setTaskId(newTaskId!);

      // remove previous task, and add new task which is just resumed
      int oldTaskIndex = getTaskIndex(taskId: oldTaskId);

      CustomDownloadTask downloadTask = _itemDownloadTasks[oldTaskIndex];
      downloadTask.setTaskId(newTaskId);

      _itemDownloadTasks.removeAt(oldTaskIndex);
      _itemDownloadTasks.insert(oldTaskIndex, downloadTask);

      // replace the new task id
      int downloadItemIndex = getDownloadItemIndex(taskId: newTaskId);
      _downloadItemList[downloadItemIndex].setTaskId(newTaskId);

      notifyListeners();
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

  removeAll({required BuildContext context}) async {
    List<DownloadTask>? taskList = await FlutterDownloader.loadTasks();

    if (taskList != null && taskList.isNotEmpty) {
      for (DownloadTask t in taskList) {
        await FlutterDownloader.remove(taskId: t.taskId);
      }
    }
    _itemDownloadTasks.clear();
    Provider.of<DownloadsProvider>(context, listen: false).removeAll();
  }

  removeFromDownloads({required String taskId}) async {
    await FlutterDownloader.remove(taskId: taskId);
    int taskIndex = getTaskIndex(taskId: taskId);
    if (taskIndex != -1) {
      _itemDownloadTasks.removeAt(taskIndex);
    }
    int itemIndex = getDownloadItemIndex(taskId: taskId);
    if (itemIndex != -1) {
      _downloadItemList.removeAt(itemIndex);
    }
    notifyListeners();
  }

  _onReceiveData(data, {required BuildContext context}) async {
    if (data == null) {
      return;
    }

    String? id = data[0];
    int? status = data[1];
    int? progress = data[2];

    DownloadTaskStatus downloadTaskStatus = DownloadTaskStatus(status!);

    int taskIndex = getTaskIndex(taskId: id);

    log("Task ID: $id | task index: $taskIndex", name: "onReceiveData");

    if (taskIndex == -1) {
      return;
    }
    _itemDownloadTasks[taskIndex].setStatus(downloadTaskStatus);
    _itemDownloadTasks[taskIndex].setProgress(progress!);

    if (downloadTaskStatus == DownloadTaskStatus.complete) {
      int downloadItemIndex = getDownloadItemIndex(taskId: id);

      if (downloadItemIndex != -1) {
        DownloadItem downloadItem = _downloadItemList[downloadItemIndex];

        Provider.of<DownloadsProvider>(context, listen: false).addToDownloads(
          DownloadItem(
            id: downloadItem.id,
            title: downloadItem.title,
            url: downloadItem.url,
            fileName: _itemDownloadTasks[taskIndex].fileName ?? '-',
            savedFilePath: _itemDownloadTasks[taskIndex].filePath ?? '-',
          )..setTaskId(id!),
        );
      }
    }

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
