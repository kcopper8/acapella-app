import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/recording.dart';

class RecordScreen extends StatefulWidget {
  final Song song;
  final Part part;

  const RecordScreen({
    super.key,
    required this.song,
    required this.part,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isRecording = false;
  bool _isCountingDown = false;
  int _countdown = 3;

  Future<void> _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });
    for (int i = 3; i >= 1; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _countdown = i - 1);
    }
    if (mounted) {
      setState(() {
        _isCountingDown = false;
        _isRecording = true;
      });
    }
  }

  void _stopRecording() {
    // TODO: 실제 녹화 중단 및 파일 저장
    // 임시로 가짜 Recording 반환
    final recording = Recording(
      partId: widget.part.id,
      partName: widget.part.name,
      videoPath: '/tmp/recording_${widget.part.id}.mp4',
      recordedAt: DateTime.now(),
    );
    Navigator.pop(context, recording);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.part.name} 녹화'),
      ),
      body: Stack(
        children: [
          // 카메라 미리보기 영역 (추후 실제 카메라로 교체)
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.grey, size: 80),
            ),
          ),

          // 가이드 음 표시
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    widget.part.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('가이드 음',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.part.notes
                        .map((note) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(note,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // 카운트다운
          if (_isCountingDown)
            Center(
              child: Text(
                _countdown > 0 ? '$_countdown' : '시작!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.bold),
              ),
            ),

          // 녹화 중 표시
          if (_isRecording)
            Positioned(
              top: 140,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text('REC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          // 하단 컨트롤
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isRecording
                    ? _stopRecording
                    : (!_isCountingDown ? _startCountdown : null),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.white,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 4),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: _isRecording ? Colors.white : Colors.red,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),

          // 안내 텍스트
          if (!_isRecording && !_isCountingDown)
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '버튼을 눌러 녹화 시작',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
