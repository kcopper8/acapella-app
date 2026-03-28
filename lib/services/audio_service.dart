import 'package:just_audio/just_audio.dart';

/// 박자(클릭 트랙)와 가이드 음을 재생하는 서비스
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // 음이름 → 주파수(Hz) 매핑 (4옥타브 기준)
  static const Map<String, double> noteFrequencies = {
    '도': 261.63,
    '레': 293.66,
    '미': 329.63,
    '미b': 311.13,
    '파': 349.23,
    '솔': 392.00,
    '라': 440.00,
    '시': 493.88,
    '시b': 466.16,
    '도샵': 277.18,
  };

  /// 카운트다운 비프음 재생 (웹 호환)
  Future<void> playBeep() async {
    // 웹에서는 Web Audio API로 비프음 생성
    // 모바일에서는 짧은 오디오 파일 사용
    // 현재는 진동/시각적 피드백으로 대체
  }

  /// 메트로놈 틱 (BPM 기반)
  Stream<int> metronomeStream(int bpm) async* {
    final intervalMs = (60000 / bpm).round();
    int beat = 0;
    while (true) {
      await Future.delayed(Duration(milliseconds: intervalMs));
      yield beat++;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
