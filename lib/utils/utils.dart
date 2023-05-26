import 'package:downloads_module/enum/download_item_type.dart';

class Utils {
  static DownloadItemType deduceDownloadItemType(String url) {
    switch (url.split('.').last) {
      case 'mp4':
        return DownloadItemType.video;
      case 'jpg':
      case 'png':
        return DownloadItemType.image;
      case 'pdf':
        return DownloadItemType.pdf;
      case 'apk':
        return DownloadItemType.apk;
      default:
        return DownloadItemType.undetermined;
    }
  }
}
