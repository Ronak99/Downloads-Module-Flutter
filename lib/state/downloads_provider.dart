import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/service/hive_service.dart';
import 'package:downloads_module/state/download_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadsProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<DownloadItem> _downloadedItems = [];
  List<DownloadItem> get downloadedItems => _downloadedItems;

  refreshDownloads() async {
    _downloadedItems = await _hiveService.getAllDownloads();
    notifyListeners();
  }

  removeFromDownloads(DownloadItem downloadItem,
      {required BuildContext context}) async {
    Provider.of<DownloadState>(context, listen: false)
        .removeTask(taskId: downloadItem.taskId);
    await _hiveService.removeDownload(downloadItem);
    refreshDownloads();
  }

  removeAll() async {
    await _hiveService.removeAll();
    refreshDownloads();
  }
}
