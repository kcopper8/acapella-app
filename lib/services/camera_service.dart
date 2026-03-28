import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isRecording = false;

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  CameraController? get controller => _controller;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // 전면 카메라 우선 선택
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  Future<String?> startRecording() async {
    if (!_isInitialized || _controller == null || _isRecording) return null;
    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording || _controller == null) return null;
    try {
      final file = await _controller!.stopVideoRecording();
      _isRecording = false;
      return file.path;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _isInitialized = false;
  }
}
