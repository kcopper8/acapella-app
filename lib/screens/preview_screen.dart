import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/song.dart';
import '../models/recording.dart';
import '../services/video_merge_service.dart';

class PreviewScreen extends StatefulWidget {
  final Song song;
  final List<Recording> recordings;

  const PreviewScreen({
    super.key,
    required this.song,
    required this.recordings,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _mergeService = VideoMergeService();
  VideoPlayerController? _videoController;
  bool _isMerging = false;
  bool _isMerged = false;
  String? _mergedPath;
  String? _errorMessage;

  Future<void> _mergeVideos() async {
    setState(() {
      _isMerging = true;
      _errorMessage = null;
    });

    try {
      final outputPath = await _mergeService.mergeToGrid(widget.recordings);

      if (outputPath != null) {
        // 웹: blob URL, 모바일: 파일 경로
        final controller = kIsWeb
            ? VideoPlayerController.networkUrl(Uri.parse(outputPath))
            : VideoPlayerController.networkUrl(Uri.parse(outputPath));
        await controller.initialize();
        await controller.setLooping(true);

        setState(() {
          _mergedPath = outputPath;
          _videoController = controller;
          _isMerged = true;
          _isMerging = false;
        });

        await controller.play();
      } else {
        setState(() {
          _isMerging = false;
          _errorMessage = '영상 합치기에 실패했어요. 다시 시도해보세요.';
        });
      }
    } catch (e) {
      setState(() {
        _isMerging = false;
        _errorMessage = '오류가 발생했어요: $e';
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('완성 영상'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_isMerged)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유 기능은 곧 추가됩니다!')),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 영상 미리보기 / 그리드 썸네일
            Expanded(
              child: _isMerged && _videoController != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isMerging
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.deepPurple),
                                  SizedBox(height: 16),
                                  Text('영상 합치는 중...',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    widget.recordings.length <= 2 ? widget.recordings.length : 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: widget.recordings.length,
                              itemBuilder: (context, index) {
                                final recording = widget.recordings[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.videocam,
                                          color: Colors.white, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        recording.partName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        recording.videoPath.split('/').last,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),

            const SizedBox(height: 12),

            // 에러 메시지
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

            // 비디오 재생 컨트롤
            if (_isMerged && _videoController != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.deepPurple,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                      });
                    },
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // 합치기 버튼
            if (!_isMerged)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isMerging ? null : _mergeVideos,
                  icon: _isMerging
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.merge_type, color: Colors.white),
                  label: Text(
                    _isMerging ? '합치는 중... (시간이 걸릴 수 있어요)' : '영상 합치기',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.all(16),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
