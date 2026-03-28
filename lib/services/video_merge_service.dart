import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import '../models/recording.dart';

@JS('mergeVideosToGrid')
external JSPromise<JSAny?> _jsmergeVideosToGrid(JSArray<JSString> videoUrls);

@JS('initFFmpeg')
external JSPromise<JSBoolean> _jsInitFFmpeg();

class VideoMergeService {
  bool get isSupported => true; // 웹/모바일 모두 지원

  /// FFmpeg.wasm 사전 로드 (앱 시작 시 호출 권장)
  Future<bool> preload() async {
    if (!kIsWeb) return true;
    try {
      final result = await _jsInitFFmpeg().toDart;
      return result.toDart;
    } catch (_) {
      return false;
    }
  }

  /// 녹화 파일들을 그리드 영상으로 합치기
  Future<String?> mergeToGrid(List<Recording> recordings) async {
    if (recordings.isEmpty) return null;
    if (recordings.length == 1) return recordings.first.videoPath;

    if (kIsWeb) {
      return await _mergeWeb(recordings);
    } else {
      return await _mergeMobile(recordings);
    }
  }

  Future<String?> _mergeWeb(List<Recording> recordings) async {
    try {
      final urls = recordings.map((r) => r.videoPath.toJS).toList().toJS;
      final result = await _jsmergeVideosToGrid(urls).toDart;
      if (result == null) return null;
      return (result as JSString).toDart;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _mergeMobile(List<Recording> recordings) async {
    // 모바일 FFmpegKit 구현 (추후)
    return null;
  }
}
