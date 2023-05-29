import 'dart:io';

import 'package:hive/hive.dart';

import 'package:downloads_module/enum/download_item_type.dart';
import 'package:downloads_module/utils/utils.dart';

part 'download_item.g.dart';

@HiveType(typeId: 0)
class DownloadItem extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String url;
  @HiveField(4)
  String? savedFilePath;
  @HiveField(5)
  String? fileName;
  @HiveField(6)
  String? taskId;

  DownloadItemType downloadItemType;

  DownloadItem({
    required this.id,
    required this.title,
    required this.url,
    this.savedFilePath,
    this.fileName,
  }) : downloadItemType = Utils.deduceDownloadItemType(url);

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'] ?? '',
    );
  }

  setTaskId(String taskId) {
    this.taskId = taskId;
  }

  assignDownloadDetails({
    required String filePath,
    required String fileName,
  }) {
    savedFilePath = filePath;
    this.fileName = fileName;
  }

  bool get isVideoItem => downloadItemType == DownloadItemType.video;
  bool get isImageItem => downloadItemType == DownloadItemType.image;
  bool get isPdfItem => downloadItemType == DownloadItemType.pdf;

  bool get isDownloaded => savedFilePath != null;

  File get getFile => File(savedFilePath!);
}
