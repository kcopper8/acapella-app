class Part {
  final String id;
  final String name;
  final String description;
  final List<String> notes; // 가이드 음 목록
  final int difficulty; // 1~3

  const Part({
    required this.id,
    required this.name,
    required this.description,
    required this.notes,
    required this.difficulty,
  });
}

class Song {
  final String id;
  final String title;
  final String artist;
  final int bpm;
  final List<Part> parts;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.parts,
  });
}

// 샘플 곡 데이터
final sampleSongs = [
  Song(
    id: 'sample1',
    title: '학교 종',
    artist: '동요',
    bpm: 100,
    parts: [
      Part(
        id: 'melody',
        name: '멜로디',
        description: '주선율을 담당해요',
        notes: ['솔', '솔', '라', '솔', '솔'],
        difficulty: 1,
      ),
      Part(
        id: 'bass',
        name: '베이스',
        description: '낮은 음으로 리듬을 잡아요',
        notes: ['도', '도', '파', '도', '도'],
        difficulty: 2,
      ),
    ],
  ),
];
