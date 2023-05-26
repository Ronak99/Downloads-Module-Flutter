import 'dart:isolate';
import 'dart:ui';

import 'package:downloads_module/constants/constants.dart';
import 'package:downloads_module/screens/landing_page.dart';
import 'package:downloads_module/state/download_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _initializeDownloader();
  }

  _initializeDownloader() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await FlutterDownloader.registerCallback(_downloadCallback);
    });
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DownloadState>(create: (_) => DownloadState()),
      ],
      child: const MaterialApp(
        home: LandingPage(),
      ),
    );
  }
}
