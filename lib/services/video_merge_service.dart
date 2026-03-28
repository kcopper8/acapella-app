import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recording.dart';

class VideoMergeService {
  /// 여러 녹화 파일을 그리드 형태로 합치기
  Future<String?> mergeToGrid(List<Recording> recordings) async {
    if (recordings.isEmpty) return null;

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/acapella_merged_${DateTime.now().millisecondsSinceEpoch}.mp4';

    if (recordings.length == 1) {
      return recordings.first.videoPath;
    }

    // 2개: 좌우 배치
    // 3~4개: 2x2 그리드
    final command = _buildMergeCommand(recordings, outputPath);
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }
    return null;
  }

  String _buildMergeCommand(List<Recording> recordings, String outputPath) {
    final inputs = recordings.map((r) => '-i "${r.videoPath}"').join(' ');

    if (recordings.length == 2) {
      // 좌우 배치 (hstack)
      return '$inputs -filter_complex '
          '"[0:v]scale=640:480[v0];[1:v]scale=640:480[v1];[v0][v1]hstack=inputs=2[v];'
          '[0:a][1:a]amix=inputs=2[a]" '
          '-map "[v]" -map "[a]" '
          '-c:v libx264 -c:a aac "$outputPath"';
    } else if (recordings.length <= 4) {
      // 2x2 그리드 (xstack)
      final videoFilters = recordings
          .asMap()
          .entries
          .map((e) => '[${e.key}:v]scale=640:480[v${e.key}]')
          .join(';');

      final stackInputs = List.generate(recordings.length, (i) => '[v$i]').join('');
      final audioMix = recordings
          .asMap()
          .entries
          .map((e) => '[${e.key}:a]')
          .join('');

      final layout = recordings.length == 3
          ? '0_0|w0_0|0_h0'
          : '0_0|w0_0|0_h0|w0_h0';

      return '$inputs -filter_complex '
          '"$videoFilters;${stackInputs}xstack=inputs=${recordings.length}:layout=$layout[v];'
          '${audioMix}amix=inputs=${recordings.length}[a]" '
          '-map "[v]" -map "[a]" '
          '-c:v libx264 -c:a aac "$outputPath"';
    }

    // 5개 이상은 일단 첫 4개만
    return _buildMergeCommand(recordings.take(4).toList(), outputPath);
  }
}
