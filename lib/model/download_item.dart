import 'package:downloads_module/enum/download_item_type.dart';
import 'package:downloads_module/utils/utils.dart';

class DownloadItem {
  String id;
  String title;
  String url;
  DownloadItemType downloadItemType;

  DownloadItem({
    required this.id,
    required this.title,
    required this.url,
  }) : downloadItemType = Utils.deduceDownloadItemType(url);

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'] ?? '',
    );
  }

  bool get isVideoItem => downloadItemType == DownloadItemType.video;
  bool get isImageItem => downloadItemType == DownloadItemType.image;
  bool get isPdfItem => downloadItemType == DownloadItemType.pdf;
}
