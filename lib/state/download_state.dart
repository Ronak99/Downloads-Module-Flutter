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
    // initialize current download item, when the screen is loaded
    _currentDownloadItem = downloadItem;

    // add the download item with basic details to _itemList
    // we don't have task id yet
    _addToItemDownloadTasks(
      CustomDownloadTask(
        url: downloadItem.url,
        itemId: downloadItem.id,
      ),
    );

    // query downloaded tasks
    List<DownloadTask>? downloadTaskList = await _loadDownloadTasks();

    // compare the two lists created above, and updated CustomDownloadTask with required properties
    // like taskId, status and progress, since FlutterDownloader has that information
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

  // this function ensures that no two custom download tasks of same taskId exist within itemDownloadTasks
  _addToItemDownloadTasks(CustomDownloadTask downloadTask) {
    if (downloadTask.taskId == null) return;
    int index = getTaskIndex(taskId: downloadTask.taskId);
    if (index != -1) {
      _itemDownloadTasks.removeAt(index);
    }
    _itemDownloadTasks.add(downloadTask);
  }

  // this function ensures that no two download items of same taskId exist within downloadItemList
  _addToDownloadItemList(DownloadItem downloadItem) {
    if (downloadItem.taskId == null) return;
    int index = getDownloadItemIndex(taskId: downloadItem.taskId);
    if (index != -1) {
      _downloadItemList.removeAt(index);
    }
    _downloadItemList.add(downloadItem);
  }

  // retrieves all the tasks created via FlutterDownloader
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
        removeFromDownloads();
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

      // initialized item download task and added it to the list
      CustomDownloadTask itemDownloadTask = CustomDownloadTask(
        url: item.url,
        itemId: item.id,
      )..setTaskId(taskId!);

      // create a download task with now available details, like taskId, fileName and filePath
      // then add it to the download task list
      _addToItemDownloadTasks(itemDownloadTask);

      // assign the task id to downloadItem, as it probably did not have that information
      // add the item to downloadItemList
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

      // Assign new task id to current download item
      _currentDownloadItem!.setTaskId(newTaskId!);

      // remove previous task, and add new task which is just resumed
      int oldTaskIndex = getTaskIndex(taskId: oldTaskId);

      // Update the taskId of downloadTask
      CustomDownloadTask downloadTask = _itemDownloadTasks[oldTaskIndex];
      downloadTask.setTaskId(newTaskId);

      // update itemDownloadTasks list, so as to replace the new downloadTask with the previous one
      _itemDownloadTasks.removeAt(oldTaskIndex);
      _itemDownloadTasks.insert(oldTaskIndex, downloadTask);

      // update the taskId of downloadItem at downloadItemIndex which belongs to new task
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

  removeAll() async {
    List<DownloadTask>? taskList = await FlutterDownloader.loadTasks();

    if (taskList != null && taskList.isNotEmpty) {
      for (DownloadTask t in taskList) {
        await FlutterDownloader.remove(taskId: t.taskId);
      }
    }
    _itemDownloadTasks.clear();
  }

  removeFromDownloads() async {
    String? taskId = _currentDownloadItem!.taskId;
    if (taskId == null) return;
    await FlutterDownloader.remove(taskId: taskId);

    int taskIndex = getTaskIndex(taskId: taskId);
    if (taskIndex != -1) {
      _itemDownloadTasks.removeAt(taskIndex);
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

    if (taskIndex == -1) {
      return;
    }
    _itemDownloadTasks[taskIndex].setStatus(downloadTaskStatus);
    _itemDownloadTasks[taskIndex].setProgress(progress!);

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
