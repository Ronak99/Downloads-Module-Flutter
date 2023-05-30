import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'package:downloads_module/model/download_item.dart';

class VideoPlayer extends StatefulWidget {
  final DownloadItem downloadItem;

  const VideoPlayer({
    Key? key,
    required this.downloadItem,
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late Widget _videoView;

  @override
  void initState() {
    super.initState();

    if (widget.downloadItem.isDownloaded) {
      _videoView = BetterPlayer.file(widget.downloadItem.savedFilePath!);
    } else {
      _videoView = BetterPlayer.network(widget.downloadItem.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _videoView,
    );
  }
}
