import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../controller/downloads_db.dart';

class DownloadedVideosPage extends StatefulWidget {
  const DownloadedVideosPage({super.key});

  @override
  State<DownloadedVideosPage> createState() => _DownloadedVideosPageState();
}

class _DownloadedVideosPageState extends State<DownloadedVideosPage> {
  List<Map<String, dynamic>> _downloads = [];
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final data = await DownloadsDB.getAllDownloads();
    setState(() {
      _downloads = data;
    });
  }

  Future<void> _playVideo(String path) async {
    if (_controller != null) {
      await _controller!.dispose();
      _chewie?.dispose();
    }

    _controller = VideoPlayerController.file(File(path));
    await _controller!.initialize();

    _chewie = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
      looping: false,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewie?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الفيديوهات المحمّلة"),
        backgroundColor: Colors.purple,
      ),
      body: _downloads.isEmpty
          ? const Center(child: Text("لا يوجد فيديوهات محمّلة بعد."))
          : ListView.builder(
        itemCount: _downloads.length,
        itemBuilder: (context, index) {
          final video = _downloads[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading:
              const Icon(Icons.video_library, color: Colors.purple),
              title: Text(video['title'] ?? 'بدون عنوان'),
              subtitle: Text(video['localPath']),
              onTap: () => _playVideo(video['localPath']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await DownloadsDB.deleteDownload(video['id']);
                  setState(() {
                    _downloads.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _chewie != null
          ? SizedBox(height: 250, child: Chewie(controller: _chewie!))
          : null,
    );
  }
}
