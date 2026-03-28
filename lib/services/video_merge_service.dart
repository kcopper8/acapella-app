import 'package:flutter/foundation.dart';
import '../models/recording.dart';

class VideoMergeService {
  /// 웹에서는 영상 합치기 불가 (FFmpeg는 모바일 전용)
  bool get isSupported => !kIsWeb;

  Future<String?> mergeToGrid(List<Recording> recordings) async {
    if (kIsWeb) return null;
    if (recordings.isEmpty) return null;

    // 모바일 전용 FFmpeg 처리
    try {
      // dart:io 및 ffmpeg_kit은 웹에서 import 불가이므로
      // 모바일 빌드 시 별도 구현 필요
      return null;
    } catch (e) {
      return null;
    }
  }
}
