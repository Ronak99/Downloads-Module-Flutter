import 'package:downloads_module/screens/widgets/pdf_viewer.dart';
import 'package:flutter/material.dart';

import 'package:downloads_module/enum/download_item_type.dart';
import 'package:downloads_module/model/download_item.dart';

class DetailPage extends StatelessWidget {
  final DownloadItem item;

  const DetailPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  static route(DownloadItem item) => MaterialPageRoute(
        builder: (context) => DetailPage(
          item: item,
        ),
      );

  Widget _getView() {
    switch (item.downloadItemType) {
      case DownloadItemType.image:
        return Image.network(item.url);
      case DownloadItemType.video:
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
              ),
            ),
          ],
        );
      case DownloadItemType.pdf:
        return PDFViewer(url: item.url);
      case DownloadItemType.apk:
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.android,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        );
      case DownloadItemType.undetermined:
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.download,
            ),
          ),
        ],
      ),
      body: _getView(),
    );
  }
}
