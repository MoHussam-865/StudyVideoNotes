import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/timestamped_note.dart';

class FileService {
  const FileService();

  Future<File> getNotesJsonFileForVideo(File videoFile) async {
    final String base = p.withoutExtension(videoFile.path);
    return File('$base.notes.json');
  }

  Future<File> getNotesTxtFileForVideo(File videoFile) async {
    final String base = p.withoutExtension(videoFile.path);
    return File('$base.notes.txt');
  }

  Future<void> saveNotesAsJson({
    required File videoFile,
    required List<TimestampedNote> notes,
  }) async {
    final File out = await getNotesJsonFileForVideo(videoFile);
    final List<Map<String, dynamic>> data = notes.map((n) => n.toJson()).toList(growable: false);
    final String contents = const JsonEncoder.withIndent('  ').convert(data);
    await out.writeAsString(contents);
  }

  Future<void> saveNotesAsTxt({
    required File videoFile,
    required List<TimestampedNote> notes,
  }) async {
    final File out = await getNotesTxtFileForVideo(videoFile);
    final StringBuffer buffer = StringBuffer();
    for (final TimestampedNote n in notes) {
      final Duration d = Duration(milliseconds: n.milliseconds);
      final String ts = _formatDuration(d);
      buffer.writeln('[$ts] ${n.plainText.trim()}');
    }
    await out.writeAsString(buffer.toString());
  }

  Future<List<TimestampedNote>> loadNotesFromJsonIfExists(File videoFile) async {
    final File f = await getNotesJsonFileForVideo(videoFile);
    if (!await f.exists()) return <TimestampedNote>[];
    final String contents = await f.readAsString();
    final dynamic decoded = jsonDecode(contents);
    if (decoded is! List) return <TimestampedNote>[];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map<TimestampedNote>(TimestampedNote.fromJson)
        .toList(growable: true);
  }

  String _formatDuration(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    final int ms = d.inMilliseconds.remainder(1000);
    if (h > 0) {
      return '${_two(h)}:${_two(m)}:${_two(s)}.${_three(ms)}';
    }
    return '${_two(m)}:${_two(s)}.${_three(ms)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  String _three(int v) => v.toString().padLeft(3, '0');
}


