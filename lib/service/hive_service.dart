import 'dart:io';

import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/utils/custom_exception.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  String downloadsBox = 'userDownloads';

  Future<Box> getDownloadsBox() async {
    return Hive.openBox(downloadsBox);
  }

  Future<void> init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(DownloadItemAdapter());
  }

  Future<void> addDownload(DownloadItem downloadItem) async {
    try {
      Box box = await getDownloadsBox();
      box.add(downloadItem);
      await Hive.close();
    } catch (e) {
      throw CustomException("Error in addDownload: ${e.toString()}");
    }
  }

  Future<void> removeDownload(DownloadItem downloadItem) async {
    try {
      await Hive.openBox(downloadsBox);
      await downloadItem.delete();
    } catch (e) {
      throw CustomException("Error in removeDownload: ${e.toString()}");
    }
  }

  Future<List<DownloadItem>> getAllDownloads() async {
    try {
      Box box = await getDownloadsBox();
      return box.values.map((e) => e as DownloadItem).toList();
    } catch (e) {
      throw CustomException("getAllDownloads: $e");
    }
  }

  removeAll() async {
    Box box = await getDownloadsBox();
    await box.clear();
  }
}
