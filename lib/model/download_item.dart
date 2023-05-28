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
  /*
  This type of initialization is called a constructor initializer in Dart. It allows you to set the value of a final member variable at the time an object is created, using the : syntax followed by the assignment expression. In this case, the downloadItemType property is being initialized to the result of a call to the Utils.deduceDownloadItemType method, which is determined based on the url parameter passed in to the constructor.
  */

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
