import 'package:flutter/foundation.dart';
import 'dart:js_interop';

@JS('eval')
external void jsEval(String code);

class AudioService {
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
    '레b': 277.18,
  };

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<void> playNote(String noteName, {double durationMs = 500}) async {
    if (!kIsWeb) return;
    final freq = noteFrequencies[noteName];
    if (freq == null) return;
    try {
      jsEval('''
        (function() {
          var ctx = new (window.AudioContext || window.webkitAudioContext)();
          var osc = ctx.createOscillator();
          var gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.frequency.value = $freq;
          osc.type = 'sine';
          gain.gain.setValueAtTime(0.3, ctx.currentTime);
          gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + ${durationMs / 1000});
          osc.start(ctx.currentTime);
          osc.stop(ctx.currentTime + ${durationMs / 1000});
        })();
      ''');
    } catch (_) {}
  }

  Future<void> playClick({bool isStrong = false}) async {
    await playNote(isStrong ? '솔' : '미', durationMs: 80);
  }

  Future<void> playGuideSequence(List<String> notes, int bpm) async {
    _isPlaying = true;
    final intervalMs = (60000 / bpm).round();
    for (final note in notes) {
      if (!_isPlaying) break;
      await playNote(note, durationMs: intervalMs * 0.8);
      await Future.delayed(Duration(milliseconds: intervalMs));
    }
    _isPlaying = false;
  }

  void stop() => _isPlaying = false;

  Future<void> dispose() async => stop();
}
