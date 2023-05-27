import 'package:downloads_module/model/custom_download_task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:downloads_module/model/download_item.dart';
import 'package:downloads_module/state/download_state.dart';

class DownloadButton extends StatelessWidget {
  final DownloadItem item;

  const DownloadButton({
    Key? key,
    required this.item,
  }) : super(key: key);

  Widget _getView({
    required CustomDownloadTask? downloadTask,
    required BuildContext context,
  }) {
    if (downloadTask == null) {
      return const Icon(Icons.download);
    } else {
      if (downloadTask.isUndefined ||
          downloadTask.isCanceled ||
          downloadTask.isFailed) {
        return const Icon(Icons.download);
      } else if (downloadTask.isRunning) {
        return _progressView(downloadTask.progress! / 100);
      } else if (downloadTask.isPaused) {
        return _pausedView(downloadTask.progress! / 100);
      } else if (downloadTask.isComplete) {
        return const Icon(Icons.check);
      } else if (downloadTask.isEnqueued) {
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _progressView(double progress) {
    return Stack(
      children: [
        Center(
          child: CircularProgressIndicator(
            value: progress,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const Center(
          child: Icon(
            Icons.pause,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _pausedView(double progress) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(
              value: progress,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const Center(
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var downloadState = Provider.of<DownloadState>(context);

    return GestureDetector(
      onTap: () => downloadState.onDownloadButtonTap(
        item: item,
        context: context,
      ),
      child: SizedBox(
        height: 50,
        width: 50,
        child: Center(
          child: _getView(
            downloadTask: downloadState.currentItemDownloadTask,
            context: context,
          ),
        ),
      ),
    );
  }
}
