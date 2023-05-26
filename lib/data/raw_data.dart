import "dart:convert";

import 'package:downloads_module/model/download_item.dart';

const data = '''
{
  "data": [
    {
      "id": "android_programming_cookbook",
      "title":"Android Programming Cookbook",
      "url":"http://www.pdf995.com/samples/pdf.pdf"
    },
    {
      "id": "ios_programming_guide",
      "title":"iOS Programming Guide",
      "url":"http://www.pdf995.com/samples/pdf.pdf"
    },
    {
      "id": "arches_national_park",
      "title":"Arches National Park",
      "url":"https://upload.wikimedia.org/wikipedia/commons/6/60/The_Organ_at_Arches_National_Park_Utah_Corrected.jpg"
    },
    {
      "id": "canyon_national_park",
      "title":"Canyonlands National Park",
      "url":"https://upload.wikimedia.org/wikipedia/commons/7/78/Canyonlands_National_Park%E2%80%A6Needles_area_%286294480744%29.jpg"
    },
    {
      "id": "bug_buck_bunny",
      "title":"Big Buck Bunny",
      "url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    },
    {
      "id": "elephant_dream",
      "title":"Elephant Dream",
      "url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
    },
    {
      "id": "spitfire_apk",
      "title":"Spitfire APK",
      "url":"https://github.com/bartekpacia/spitfire/releases/download/v1.2.0/spitfire.apk"
    }
  ]
}
''';

var rawJson = jsonDecode(data) as Map<String, dynamic>;
var dataList = rawJson["data"] as List;

List<DownloadItem> videoItemList =
    dataList.map((e) => DownloadItem.fromMap(e)).toList();
