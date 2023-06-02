import 'package:better_player/better_player.dart';
import 'package:downloads_module/screens/widgets/download_button.dart';
import 'package:downloads_module/screens/widgets/pdf_viewer.dart';
import 'package:downloads_module/state/download_state.dart';
import 'package:flutter/material.dart';

import 'package:downloads_module/enum/download_item_type.dart';
import 'package:downloads_module/model/download_item.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
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

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();

    Provider.of<DownloadState>(context, listen: false)
        .intialize(downloadItem: widget.item);
  }

  Widget _getView() {
    switch (widget.item.downloadItemType) {
      case DownloadItemType.image:
        return Image.network(widget.item.url);
      case DownloadItemType.video:
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer.network(widget.item.url),
            ),
          ],
        );
      case DownloadItemType.pdf:
        return PDFViewer(url: widget.item.url);
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
        title: Text(widget.item.title),
        actions: [
          DownloadButton(item: widget.item),
        ],
      ),
      body: _getView(),
    );
  }
}
