import 'package:flutter_downloader/flutter_downloader.dart';

class CustomDownloadTask {
  final String url;
  String? fileName;
  String? filePath;
  final String itemId;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  CustomDownloadTask({
    required this.url,
    required this.itemId,
  });

  setStatus(DownloadTaskStatus status) {
    this.status = status;
  }

  setProgress(int progress) {
    this.progress = progress;
  }

  setTaskId(String taskId) {
    this.taskId = taskId;
  }

  setFileName(String fileName) {
    this.fileName = fileName;
  }

  setFilePath(String filePath) {
    this.filePath = filePath;
  }

  bool get isUndefined => status == DownloadTaskStatus.undefined;
  bool get isEnqueued => status == DownloadTaskStatus.enqueued;
  bool get isRunning => status == DownloadTaskStatus.running;
  bool get isComplete => status == DownloadTaskStatus.complete;
  bool get isFailed => status == DownloadTaskStatus.failed;
  bool get isCanceled => status == DownloadTaskStatus.canceled;
  bool get isPaused => status == DownloadTaskStatus.paused;
}
