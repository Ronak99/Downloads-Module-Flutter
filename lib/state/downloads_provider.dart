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

  removeFromDownloads(
    String itemId, {
    required BuildContext context,
  }) async {
    DownloadItem d = _downloadedItems.firstWhere((e) => e.id == itemId);

    Provider.of<DownloadState>(context, listen: false)
        .removeFromDownloads(taskId: d.taskId!);
    await _hiveService.removeDownload(d);
    refreshDownloads();
  }

  addToDownloads(DownloadItem downloadItem) async {
    // this will be created locally
    await _hiveService.addDownload(downloadItem);
    refreshDownloads();
  }

  removeAll() async {
    await _hiveService.removeAll();
    refreshDownloads();
  }
}
