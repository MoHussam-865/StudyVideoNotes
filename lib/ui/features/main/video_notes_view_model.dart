import 'package:video_notes/routes/routes.dart';
import 'package:video_notes/ui/features/full_screen/full_video_view.dart';
import '../../../data/models/timestamped_message.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import '../../../data/models/timestamped_note.dart';

class VideoNotesViewModel extends ChangeNotifier {

  List<TimestampedMessage> timestampedMessages = [];
  VideoPlayerController? videoController;
  Future<void>? initializeVideoFuture;
  final List<TimestampedNote> notes = [];
  int? selectedIndex;
  final quill.QuillController quillController = quill.QuillController.basic();
  bool isEditorVisible = false;
  String? videoPath;


 /// Loads timestamped messages from a .txt file with the same name as the video.
  /// Returns true if loaded, false if file not found or error.
  Future<bool> _loadTimestampedMessagesForVideo(String videoPath) async {
    try {
      final videoFile = File(videoPath);
      final videoDir = videoFile.parent.path;
      final videoName = path.basenameWithoutExtension(videoFile.path);
      final txtPath = '$videoDir${Platform.pathSeparator}$videoName.txt';
      final txtFile = File(txtPath);
      if (!await txtFile.exists()) {
        timestampedMessages = [];
        return false;
      }
      final lines = await txtFile.readAsLines();
      timestampedMessages = lines
          .where((line) => line.trim().isNotEmpty)
          .map((line) => TimestampedMessage.fromLine(line))
          .toList();
      return true;
    } catch (e) {
      timestampedMessages = [];
      return false;
    }
  }

  Future<void> navigateToFullVideoView(BuildContext context) async {
    if (videoController == null) return;
    try {
      final result = await Navigator.pushNamed(context, MyRouts.fullScreen.value) as Duration?;
      if (result != null) {
        // Pause video and open editor at this time
        await videoController!.pause();
        isEditorVisible = true;
        selectedIndex = null;
        quillController.document = quill.Document();
        // Seek to the returned time
        await videoController!.seekTo(result);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting duration $e');
    }
  }

  Future<void> pickAndOpenVideo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['mp4', 'm4v', 'mov', 'wmv', 'ts', 'webm'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      final videoPath = file.absolute.path;
      this.videoPath = videoPath;

      // Try to load existing notes from JSON file with same name
      await _loadNotesFromJson(videoPath);
      await _loadTimestampedMessagesForVideo(videoPath);
      await loadVideo(context, file);
    }
  }

  Future<void> _loadNotesFromJson(String videoPath) async {
    try {
      final videoFile = File(videoPath);
      final videoDir = videoFile.parent.path;
      final videoName = path.basenameWithoutExtension(videoFile.path);
      final jsonPath = '$videoDir${Platform.pathSeparator}$videoName.json';

      final jsonFile = File(jsonPath);
      if (await jsonFile.exists()) {
        final jsonString = await jsonFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        notes.clear();
        notes.addAll(
          jsonList.map((json) => TimestampedNote.fromJson(json)).toList(),
        );
        selectedIndex = null;
      } else {
        notes.clear();
        selectedIndex = null;
      }
    } catch (e) {
      // If loading fails, start with empty notes
      notes.clear();
      selectedIndex = null;
    }
  }

  Future<void> _saveNotesToJson() async {
    if (videoController == null || notes.isEmpty || videoPath == null) return;

    try {
      final videoFile = File(videoPath!);
      final videoDir = videoFile.parent.path;
      final videoName = path.basenameWithoutExtension(videoFile.path);
      final jsonPath = '$videoDir${Platform.pathSeparator}$videoName.json';

      final jsonList = notes.map((note) => note.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonString);
    } catch (e) {
      // Handle save errors silently for now
    }
  }

  Future<void> loadVideo(BuildContext context, File file) async {
    await videoController?.dispose();
    final VideoPlayerController controller = VideoPlayerController.file(file);
    videoController = controller;
    try {
      initializeVideoFuture = controller.initialize();
      await initializeVideoFuture;
      if (!controller.value.isInitialized) {
        throw StateError(
          controller.value.errorDescription ?? 'Failed to initialize video',
        );
      }
      controller.addListener(() {});
      await controller.play();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot open video: $e')));
      await controller.dispose();
      videoController = null;
    }
  }

  bool canAddNote() => videoController != null;

  bool ensureEditorVisibleForNewNote() {
    if (!isEditorVisible) {
      isEditorVisible = true;
      selectedIndex = null;
      quillController.document = quill.Document();
      return false; // first click opens editor
    }
    return true; // editor already visible, proceed to save
  }

  bool addNoteAtCurrentTime(BuildContext context) {
    if (!canAddNote()) return false;

    final currentTime = videoController!.value.position.inMilliseconds;
    final note = TimestampedNote(
      milliseconds: currentTime,
      document: quillController.document,
    );

    notes.add(note);
    selectedIndex = notes.indexOf(note);
    quillController.document = quill.Document();
    isEditorVisible = false; // Hide editor after adding note

    // Automatically save to JSON
    _saveNotesToJson();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note added.')));
    return true;
  }

  void selectNote(int index) {
    selectedIndex = index;
    quillController.document = quill.Document();
  }

  bool updateNoteAt(BuildContext context, int index) {
    if (index < 0 || index >= notes.length) return false;

    final note = notes[index];
    final updatedNote = TimestampedNote(
      milliseconds: note.milliseconds,
      document: quillController.document,
      createdAt: note.createdAt,
    );

    notes[index] = updatedNote;
    selectedIndex = null;
    quillController.document = quill.Document();
    isEditorVisible = false;

    // Automatically save to JSON
    _saveNotesToJson();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note updated.')));
    return true;
  }

  bool deleteNoteAt(int index) {
    if (index < 0 || index >= notes.length) return false;

    notes.removeAt(index);

    if (selectedIndex != null) {
      if (selectedIndex == index) {
        // If the deleted note was being edited, close the editor
        selectedIndex = null;
        isEditorVisible = false;
        quillController.document = quill.Document();
      } else if (selectedIndex! > index) {
        // If a note before the selected one was deleted, shift the index
        selectedIndex = selectedIndex! - 1;
      }
    }

    _saveNotesToJson();
    return true;
  }

  Future<void> seekToNote(int index, {BuildContext? context}) async {
    if (videoController == null) return;
    if (index < 0 || index >= notes.length) return;
    final int noteMs = notes[index].milliseconds;
    final int videoMs = videoController!.value.duration.inMilliseconds;
    if (videoMs == 0) return;
    int seekMs = noteMs;
    if (noteMs < 0) seekMs = 0;
    if (noteMs > videoMs) {
      seekMs = videoMs;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Note time is beyond video length. Seeking to end of video.',
            ),
          ),
        );
      }
    }
    try {
      await videoController!.seekTo(Duration(milliseconds: seekMs));
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to seek to note: $e')));
      }
    }
  }

  void loadNoteForEditing(int index) {
    selectedIndex = index;
    // Clone the document to avoid mutating the original until saved
    quillController.document = quill.Document.fromJson(
      notes[index].document.toDelta().toJson(),
    );
    isEditorVisible = true;
  }

  // Remove manual save methods since they're no longer needed
  // Future<void> saveNotesJson(BuildContext context) async { ... }
  // Future<void> saveNotesTxt(BuildContext context) async { ... }

  void closeVideoAndReset() {
    videoController?.dispose();
    videoController = null;
    initializeVideoFuture = null;
    notes.clear();
    selectedIndex = null;
    videoPath = null;
    isEditorVisible = false;
    quillController.document = quill.Document();
    notifyListeners();
  }

  @override
  void dispose() {
    videoController?.dispose();
    quillController.dispose();
    super.dispose();
  }
}
