import 'dart:isolate';
import 'dart:ui';

import 'package:downloads_module/constants/constants.dart';

class DownloadsService {
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    try {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

      final SendPort downloadsPort =
          IsolateNameServer.lookupPortByName(kDownloadsPort)!;

      // Send the progress and id as the download progresses
      downloadsPort.send([id, status, progress]);
    } catch (e) {
      print("Error sending callbacks : $e");
    }
  }
}
