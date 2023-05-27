import 'package:downloads_module/model/custom_download_task.dart';
import 'package:downloads_module/state/download_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DownloadsResponse {
  goToDownloads,
  pauseDownload,
  cancelDownload,
  removeDownload,
}

class DownloadsBottomSheet extends StatelessWidget {
  const DownloadsBottomSheet({super.key});

  static Future<T> show<T>(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (context) => const DownloadsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DownloadState downloadState =
        Provider.of<DownloadState>(context, listen: false);

    CustomDownloadTask customDownloadTask = downloadState.currentDownloadTask!;

    Widget _optionTile({
      required DownloadsResponse response,
      required IconData icon,
      required String title,
    }) {
      return GestureDetector(
        onTap: () => Navigator.pop(context, response),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            if (customDownloadTask.isComplete)
              _optionTile(
                response: DownloadsResponse.removeDownload,
                icon: Icons.cancel,
                title: "Remove From Downloads",
              ),
            if (customDownloadTask.isRunning)
              _optionTile(
                response: DownloadsResponse.cancelDownload,
                icon: Icons.cancel,
                title: "Cancel Download",
              ),
            if (customDownloadTask.isRunning)
              _optionTile(
                response: DownloadsResponse.pauseDownload,
                icon: Icons.pause,
                title: "Pause Download",
              ),
            _optionTile(
              response: DownloadsResponse.goToDownloads,
              icon: Icons.download,
              title: "Go To Downloads",
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
