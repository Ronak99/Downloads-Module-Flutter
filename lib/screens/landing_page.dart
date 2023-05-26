import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/data/raw_data.dart';
import 'package:downloads_module/screens/downloads_page.dart';
import 'package:downloads_module/screens/detail_page.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads Module"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => Navigator.push(
              context,
              DownloadsPage.route(),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: videoItemList.length,
        itemBuilder: (context, i) {
          DownloadItem v = videoItemList[i];

          return ListTile(
            onTap: () => Navigator.push(context, DetailPage.route(v)),
            title: Text(v.title),
            subtitle: Text(
              v.url,
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
