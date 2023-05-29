import 'package:downloads_module/state/downloads_provider.dart';
import 'package:downloads_module/screens/landing_page.dart';
import 'package:downloads_module/service/downloads_service.dart';
import 'package:downloads_module/service/hive_service.dart';
import 'package:downloads_module/state/download_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  await HiveService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DownloadState>(create: (_) => DownloadState()),
        ChangeNotifierProvider<DownloadsProvider>(
            create: (_) => DownloadsProvider()),
      ],
      child: const MaterialApp(
        home: DataInitializer(),
      ),
    );
  }
}

class DataInitializer extends StatefulWidget {
  const DataInitializer({super.key});

  @override
  State<DataInitializer> createState() => DataInitializerState();
}

class DataInitializerState extends State<DataInitializer> {
  late DownloadState _downloadState;

  @override
  void initState() {
    super.initState();

    _downloadState = Provider.of<DownloadState>(context, listen: false);
    _initializeDownloader();
  }

  _initializeDownloader() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await FlutterDownloader.registerCallback(
          DownloadsService.downloadCallback);
      _downloadState.bindBackgroundIsolate(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LandingPage();
  }
}
