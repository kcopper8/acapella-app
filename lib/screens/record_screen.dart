import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/song.dart';
import '../models/recording.dart';
import '../services/camera_service.dart';
import '../services/audio_service.dart';

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
  final _cameraService = CameraService();
  final _audioService = AudioService();

  bool _isRecording = false;
  bool _isCountingDown = false;
  bool _isCameraReady = false;
  int _countdown = 3;
  int _currentBeat = 0;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.initialize();
    if (mounted) {
      setState(() {
        _isCameraReady = _cameraService.isInitialized;
      });
    }
  }

  Future<void> _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    // 카운트다운 비프음 + 시각 효과
    for (int i = 3; i >= 1; i--) {
      await _audioService.playClick(isStrong: i == 3);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdown = i - 1);
    }

    if (!mounted) return;
    setState(() {
      _isCountingDown = false;
      _isRecording = true;
    });

    // 녹화 시작
    await _cameraService.startRecording();

    // 가이드 음 루프 재생
    _playGuideLoop();

    // 경과 시간 카운트
    _startElapsedTimer();
  }

  void _playGuideLoop() async {
    while (_isRecording && mounted) {
      await _audioService.playGuideSequence(widget.part.notes, widget.song.bpm);
      if (!_isRecording) break;
    }
  }

  void _startElapsedTimer() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() => _elapsedSeconds++);
      }
    }
  }

  Future<void> _stopRecording() async {
    final videoPath = await _cameraService.stopRecording();

    if (!mounted) return;

    final recording = Recording(
      partId: widget.part.id,
      partName: widget.part.name,
      videoPath: videoPath ?? '/tmp/recording_${widget.part.id}.mp4',
      recordedAt: DateTime.now(),
    );

    setState(() => _isRecording = false);
    Navigator.pop(context, recording);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _audioService.dispose();
    super.dispose();
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
          // 카메라 미리보기
          if (_isCameraReady && _cameraService.controller != null)
            Positioned.fill(
              child: CameraPreview(_cameraService.controller!),
            )
          else
            Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, color: Colors.grey, size: 80),
                    const SizedBox(height: 12),
                    Text(
                      _isCameraReady ? '' : '카메라 초기화 중...',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          // 가이드 음 패널
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
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
                  const SizedBox(height: 4),
                  const Text('가이드 음',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: widget.part.notes
                        .asMap()
                        .entries
                        .map((e) => AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (_isRecording &&
                                        _currentBeat % widget.part.notes.length ==
                                            e.key)
                                    ? Colors.yellow
                                    : Colors.deepPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: (_isRecording &&
                                          _currentBeat %
                                                  widget.part.notes.length ==
                                              e.key)
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 20, color: Colors.black)]),
              ),
            ),

          // 녹화 상태 표시
          if (_isRecording)
            Positioned(
              top: 140,
              right: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text('REC',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),

          // 녹화 버튼
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!_isRecording && !_isCountingDown)
                  const Text(
                    '버튼을 눌러 3초 카운트다운 후 녹화 시작',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                const SizedBox(height: 12),
                GestureDetector(
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
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10)
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isRecording ? Colors.white : Colors.red,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
