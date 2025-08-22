import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:video_player/video_player.dart';
import '../viewmodel/video_notes_view_model.dart';
import '../models/timestamped_note.dart';

class VideoNotesDesktopView extends StatelessWidget {
  final VideoNotesViewModel vm;
  const VideoNotesDesktopView({Key? key, required this.vm}) : super(key: key);

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
    return Row(
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
                                    (context as Element).markNeedsBuild();
                                    if (c.value.isPlaying) {
                                      c.pause();
                                    } else {
                                      c.play();
                                    }
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
                                      (context as Element).markNeedsBuild();
                                    },
                                  ),
                                ),
                                Text('${_formatTime(c.value.position)} / ${_formatTime(c.value.duration)}'),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Fullscreen',
                                  icon: const Icon(Icons.fullscreen),
                                  onPressed: () {
                                    // This should be handled by the parent
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (!vm.isEditorVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!vm.canAddNote()) return;
                          if (vm.videoController != null && vm.videoController!.value.isPlaying) {
                            await vm.videoController!.pause();
                          }
                          vm.ensureEditorVisibleForNewNote();
                          (context as Element).markNeedsBuild();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Note at Current Time'),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!vm.canAddNote()) return;
                            if (vm.videoController != null && vm.videoController!.value.isPlaying) {
                              await vm.videoController!.pause();
                            }
                            if (vm.selectedIndex == null) {
                              final bool ok = vm.addNoteAtCurrentTime(context);
                              if (ok) {
                                if (vm.videoController != null) {
                                  await vm.videoController!.play();
                                }
                                (context as Element).markNeedsBuild();
                              }
                            } else {
                              final ok = vm.updateNoteAt(context, vm.selectedIndex!);
                              if (ok) {
                                if (vm.videoController != null) {
                                  await vm.videoController!.play();
                                }
                                (context as Element).markNeedsBuild();
                              }
                            }
                          },
                          icon: Icon(vm.selectedIndex == null ? Icons.save : Icons.update),
                          label: Text(vm.selectedIndex == null ? 'Save Note' : 'Update Note'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            vm.isEditorVisible = false;
                            vm.selectedIndex = null;
                            vm.quillController.document = quill.Document();
                            (context as Element).markNeedsBuild();
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Discard'),
                        ),
                      ),
                    ],
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
                    // Prevent index out of range if notes were deleted during rebuild
                    if (index < 0 || index >= vm.notes.length) {
                      return const SizedBox.shrink();
                    }
                    final TimestampedNote n = vm.notes[index];
                    final String title = n.plainText.split('\n').isNotEmpty ? n.plainText.split('\n').first : '';
                    return ListTile(
                      selected: index == vm.selectedIndex,
                      title: Text(title),
                      subtitle: Text(_formatTime(Duration(milliseconds: n.milliseconds))),
                      onTap: () async {
                        vm.selectNote(index);
                        await vm.seekToNote(index);
                        (context as Element).markNeedsBuild();
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Load into editor',
                            icon: const Icon(Icons.edit),
                            onPressed: () { vm.loadNoteForEditing(index); (context as Element).markNeedsBuild(); },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                            onPressed: () { 
                              final ok = vm.deleteNoteAt(index);
                              if (ok) (context as Element).markNeedsBuild();
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
    );
  }
}
