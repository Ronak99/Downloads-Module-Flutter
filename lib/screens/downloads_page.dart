import 'package:flutter/material.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  static route() =>
      MaterialPageRoute(builder: (context) => const DownloadsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads Page'),
      ),
      body: Container(),
    );
  }
}
