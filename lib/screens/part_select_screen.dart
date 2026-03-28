import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/recording.dart';
import 'record_screen.dart';
import 'preview_screen.dart';

class PartSelectScreen extends StatefulWidget {
  final Song song;
  final List<Recording> recordings;

  const PartSelectScreen({
    super.key,
    required this.song,
    required this.recordings,
  });

  @override
  State<PartSelectScreen> createState() => _PartSelectScreenState();
}

class _PartSelectScreenState extends State<PartSelectScreen> {
  late List<Recording> _recordings;

  @override
  void initState() {
    super.initState();
    _recordings = List.from(widget.recordings);
  }

  bool _isRecorded(String partId) {
    return _recordings.any((r) => r.partId == partId);
  }

  @override
  Widget build(BuildContext context) {
    final allRecorded = widget.song.parts.every((p) => _isRecorded(p.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('파트를 선택해서 녹화하세요',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _recordings.length / widget.song.parts.length,
              backgroundColor: Colors.grey[200],
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 4),
            Text('${_recordings.length} / ${widget.song.parts.length} 파트 완료',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.song.parts.length,
                itemBuilder: (context, index) {
                  final part = widget.song.parts[index];
                  final recorded = _isRecorded(part.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: recorded ? Colors.green : Colors.deepPurple[100],
                        child: Icon(
                          recorded ? Icons.check : Icons.mic,
                          color: recorded ? Colors.white : Colors.deepPurple,
                        ),
                      ),
                      title: Text(part.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(part.description),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              3,
                              (i) => Icon(
                                Icons.star,
                                size: 14,
                                color: i < part.difficulty
                                    ? Colors.amber
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final recording = await Navigator.push<Recording>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordScreen(
                                song: widget.song,
                                part: part,
                              ),
                            ),
                          );
                          if (recording != null) {
                            setState(() {
                              _recordings.removeWhere((r) => r.partId == part.id);
                              _recordings.add(recording);
                            });
                          }
                        },
                        child: Text(
                          recorded ? '다시 녹화' : '녹화',
                          style: TextStyle(
                            color: recorded ? Colors.grey : Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (allRecorded) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreviewScreen(
                          song: widget.song,
                          recordings: _recordings,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.movie, color: Colors.white),
                  label: const Text('완성 영상 만들기',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
