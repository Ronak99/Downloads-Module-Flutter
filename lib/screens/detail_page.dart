import 'dart:async';
import 'dart:io';

import 'package:downloads_module/screens/widgets/download_button.dart';
import 'package:downloads_module/state/download_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
        .intialize(itemUrl: widget.item.url);
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
              child: Container(
                color: Colors.black,
              ),
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

class PDFViewer extends StatefulWidget {
  final String url;

  const PDFViewer({Key? key, required this.url}) : super(key: key);

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String? remotePDFpath;

  @override
  void initState() {
    super.initState();

    createFileOfPdfUrl().then((f) {
      if (mounted) {
        setState(() {
          remotePDFpath = f.path;
        });
      }
    });
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      String url = widget.url;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (remotePDFpath != null)
          PDFView(
            filePath: remotePDFpath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (pages) {
              setState(() {
                pages = pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
        errorMessage.isEmpty
            ? remotePDFpath == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
            : Center(
                child: Text(errorMessage),
              )
      ],
    );
  }
}
