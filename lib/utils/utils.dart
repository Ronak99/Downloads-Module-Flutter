import 'package:downloads_module/enum/download_item_type.dart';

class Utils {
  static DownloadItemType deduceDownloadItemType(String url) {
    switch (getExtensionFromUrl(url)) {
      case 'mp4':
        return DownloadItemType.video;
      case 'jpg':
      case 'png':
        return DownloadItemType.image;
      case 'pdf':
        return DownloadItemType.pdf;
      case 'apk':
        return DownloadItemType.apk;
      // If the file extension is not recognized, we simply return DownloadItemType.undetermined.
      default:
        return DownloadItemType.undetermined;
    }
  }

  static String getExtensionFromUrl(String url) => url.split('.').last;
}
