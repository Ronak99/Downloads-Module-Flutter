import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/screens/detail_page.dart';
import 'package:downloads_module/state/downloads_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  static route() =>
      MaterialPageRoute(builder: (context) => const DownloadsPage());

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<DownloadsProvider>(context, listen: false).refreshDownloads();
  }

  @override
  Widget build(BuildContext context) {
    DownloadsProvider downloadsProvider =
        Provider.of<DownloadsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads Page'),
      ),
      body: downloadsProvider.downloadedItems.isEmpty
          ? const Center(
              child: Text('No Downloads'),
            )
          : ListView.builder(
              itemCount: downloadsProvider.downloadedItems.length,
              itemBuilder: (context, i) {
                DownloadItem v = downloadsProvider.downloadedItems[i];

                return ListTile(
                  onTap: () => Navigator.push(context, DetailPage.route(v)),
                  title: Text(v.title),
                  subtitle: Text(
                    v.isDownloaded
                        ? v.savedFilePath!
                        : "File has not been downloaded!",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  trailing: const RotatedBox(
                    quarterTurns: 2,
                    child: Icon(Icons.arrow_back_ios),
                  ),
                );
              },
            ),
    );
  }
}
