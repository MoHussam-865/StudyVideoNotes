import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:video_player/video_player.dart';

import '../viewmodel/video_notes_view_model.dart';
import '../models/timestamped_note.dart';

class VideoNotesView extends StatefulWidget {
  const VideoNotesView({super.key});

  @override
  State<VideoNotesView> createState() => _VideoNotesPageState();
}

class _VideoNotesPageState extends State<VideoNotesView> {
  late final VideoNotesViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = VideoNotesViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Notes'),
        actions: <Widget>[
          IconButton(onPressed: () async { await vm.pickAndOpenVideo(context); setState(() {}); }, icon: const Icon(Icons.folder_open)),
          IconButton(
            onPressed: () {
              vm.closeVideoAndReset();
              setState(() {});
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close Video',
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Column(
              children: <Widget>[
                if (vm.videoController == null)
                  const Expanded(
                    child: Center(child: Text('Open a video to begin')),
                  )
                else
                  FutureBuilder<void>(
                    future: vm.initializeVideoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Expanded(child: Center(child: CircularProgressIndicator()));
                      }
                      final VideoPlayerController c = vm.videoController!;
                      return Expanded(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: AspectRatio(
                                aspectRatio: c.value.aspectRatio,
                                child: VideoPlayer(c),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(c.value.isPlaying ? Icons.pause : Icons.play_arrow),
                                    onPressed: () {
                                      setState(() {
                                        if (c.value.isPlaying) {
                                          c.pause();
                                        } else {
                                          c.play();
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: c.value.position.inMilliseconds
                                          .toDouble()
                                          .clamp(0, c.value.duration.inMilliseconds.toDouble()),
                                      min: 0,
                                      max: c.value.duration.inMilliseconds.toDouble(),
                                      onChanged: (v) {
                                        c.seekTo(Duration(milliseconds: v.toInt()));
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Text(_formatTime(c.value.position) + ' / ' + _formatTime(c.value.duration)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'Fullscreen',
                                    icon: const Icon(Icons.fullscreen),
                                    onPressed: () => _openFullscreen(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!vm.canAddNote()) return;
                          // Pause video when adding note
                          if (vm.videoController != null && vm.videoController!.value.isPlaying) {
                            await vm.videoController!.pause();
                          }
                          if (!vm.isEditorVisible) {
                            // Open editor for new note
                            vm.ensureEditorVisibleForNewNote();
                            setState(() {});
                            return;
                          } else {
                            // Save note
                            final bool ok = vm.addNoteAtCurrentTime(context);
                            if (ok) {
                              if (vm.videoController != null) {
                                await vm.videoController!.play();
                              }
                              setState(() {});
                            }
                          }
                        },
                        icon: Icon(vm.isEditorVisible ? Icons.save : Icons.add),
                        label: Text(vm.isEditorVisible ? 'Save Note' : 'Add Note at Current Time'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey.shade300),
          if (vm.isEditorVisible)
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  quill.QuillSimpleToolbar(controller: vm.quillController),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: quill.QuillEditor.basic(controller: vm.quillController),
                    ),
                  ),
                ],
              ),
            ),
          VerticalDivider(width: 1, color: Colors.grey.shade300),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.notes.length,
                    itemBuilder: (context, index) {
                      final TimestampedNote n = vm.notes[index];
                      final String title = n.plainText.split('\n').isNotEmpty ? n.plainText.split('\n').first : '';
                      return ListTile(
                        selected: index == vm.selectedIndex,
                        title: Text(title),
                        subtitle: Text(_formatTime(Duration(milliseconds: n.milliseconds))),
                        onTap: () async {
                          vm.selectNote(index);
                          await vm.seekToNote(index);
                          setState(() {});
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Load into editor',
                              icon: const Icon(Icons.edit),
                              onPressed: () { vm.selectedIndex = index; vm.quillController.document = vm.notes[index].document; vm.isEditorVisible = true; setState(() {}); },
                            ),
                            IconButton(
                              tooltip: 'Update this note',
                              icon: const Icon(Icons.save),
                              onPressed: () { final ok = vm.updateNoteAt(context, index); if (ok) setState(() {}); },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                              onPressed: () { 
                                final ok = vm.deleteNoteAt(index);
                                if (ok) setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  Future<void> _openFullscreen(BuildContext context) async {
    if (vm.videoController == null) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => _FullscreenVideo(
        controller: vm.videoController!,
        onAddNote: () async {
          if (vm.videoController != null && vm.videoController!.value.isPlaying) {
            await vm.videoController!.pause();
          }
          // From fullscreen, just open the editor for composing a new note
          vm.isEditorVisible = true;
          vm.selectedIndex = null;
          vm.quillController.document = quill.Document();
          Navigator.of(context).pop();
        },
      ),
    ));
    setState(() {});
  }
}

class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.controller, required this.onAddNote});

  final VideoPlayerController controller;
  final VoidCallback onAddNote;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  String _formatTime(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController controller = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: <Widget>[
                  IconButton(
                    color: Colors.white,
                    icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () async {
                      if (controller.value.isPlaying) {
                        await controller.pause();
                      } else {
                        await controller.play();
                      }
                      if (mounted) setState(() {});
                    },
                  ),
                  Expanded(
                    child: Slider(
                      value: controller.value.position.inMilliseconds
                          .toDouble()
                          .clamp(0, controller.value.duration.inMilliseconds.toDouble()),
                      min: 0,
                      max: controller.value.duration.inMilliseconds.toDouble(),
                      onChanged: (double v) async {
                        await controller.seekTo(Duration(milliseconds: v.toInt()));
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
                  Text(
                    '${_formatTime(controller.value.position)} / ${_formatTime(controller.value.duration)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: FloatingActionButton(
                onPressed: widget.onAddNote,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                mini: true,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


