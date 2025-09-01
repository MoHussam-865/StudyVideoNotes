import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:video_player/video_player.dart';
import '../../widgets/video_controls.dart';
import 'video_notes_view_model.dart';
import '../../../data/models/timestamped_note.dart';

class VideoNotesMobileView extends StatefulWidget {
  final VideoNotesViewModel viewModel;
  const VideoNotesMobileView({super.key, required this.viewModel});

  @override
  State<VideoNotesMobileView> createState() => _VideoNotesMobileViewState();
}

class _VideoNotesMobileViewState extends State<VideoNotesMobileView> {
  int _selectedIndex = 0;

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
    final vm = widget.viewModel;
    final List<Widget> pages = [
      // Video Page
      Column(
        children: <Widget>[
          if (vm.videoController == null)
            const Expanded(child: Center(child: Text('Open a video to begin')))
          else
            FutureBuilder<void>(
              future: vm.initializeVideoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
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
                      VideoControls(
                        c: c,
                        onFullScreenClicked: () async {
                          await vm.navigateToFullVideoView(context);
                          setState(() {});
                        },
                        refresh: () => setState(() {}),
                      ),
                      // Positioned(
                      //   bottom: 16,
                      //   left: 16,
                      //   right: 16,
                      //   child: Row(
                      //     children: <Widget>[
                      //       IconButton(
                      //         icon: Icon(
                      //           c.value.isPlaying
                      //               ? Icons.pause
                      //               : Icons.play_arrow,
                      //         ),
                      //         onPressed: () {
                      //           setState(() {
                      //             if (c.value.isPlaying) {
                      //               c.pause();
                      //             } else {
                      //               c.play();
                      //             }
                      //           });
                      //         },
                      //       ),
                      //       Expanded(
                      //         child: Slider(
                      //           value: c.value.position.inMilliseconds
                      //               .toDouble()
                      //               .clamp(
                      //                 0,
                      //                 c.value.duration.inMilliseconds
                      //                     .toDouble(),
                      //               ),
                      //           min: 0,
                      //           max: c.value.duration.inMilliseconds.toDouble(),
                      //           onChanged: (v) {
                      //             c.seekTo(Duration(milliseconds: v.toInt()));
                      //             setState(() {});
                      //           },
                      //         ),
                      //       ),
                      //       Text(
                      //         '${_formatTime(c.value.position)} / ${_formatTime(c.value.duration)}',
                      //       ),
                      //       const SizedBox(width: 8),
                      //       IconButton(
                      //         tooltip: 'Fullscreen',
                      //         icon: const Icon(Icons.fullscreen),
                      //         onPressed: () =>
                      //             vm.navigateToFullVideoView(context),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!vm.canAddNote()) return;
                      if (vm.videoController != null &&
                          vm.videoController!.value.isPlaying) {
                        await vm.videoController!.pause();
                      }
                      vm.ensureEditorVisibleForNewNote();
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Note at Current Time'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Notes Page
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vm.notes.length,
              itemBuilder: (context, index) {
                final TimestampedNote n = vm.notes[index];
                final String title = n.plainText.split('\n').isNotEmpty
                    ? n.plainText.split('\n').first
                    : '';
                return ListTile(
                  selected: index == vm.selectedIndex,
                  title: Text(title),
                  subtitle: Text(
                    _formatTime(Duration(milliseconds: n.milliseconds)),
                  ),
                  onTap: () async {
                    vm.selectNote(index);
                    await vm.seekToNote(index);
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Load into editor',
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          vm.loadNoteForEditing(index);
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
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
      // Editor Page
      if (vm.isEditorVisible)
        Column(
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
                        if (vm.videoController != null &&
                            vm.videoController!.value.isPlaying) {
                          await vm.videoController!.pause();
                        }
                        if (vm.selectedIndex == null) {
                          final bool ok = vm.addNoteAtCurrentTime(context);
                          if (ok) {
                            if (vm.videoController != null) {
                              await vm.videoController!.play();
                            }
                            setState(() {
                              _selectedIndex = 0;
                            });
                          }
                        } else {
                          final ok = vm.updateNoteAt(
                            context,
                            vm.selectedIndex!,
                          );
                          if (ok) {
                            if (vm.videoController != null) {
                              await vm.videoController!.play();
                            }
                            setState(() {
                              _selectedIndex = 0;
                            });
                          }
                        }
                      },
                      icon: Icon(
                        vm.selectedIndex == null ? Icons.save : Icons.update,
                      ),
                      label: Text(
                        vm.selectedIndex == null ? 'Save Note' : 'Update Note',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        vm.isEditorVisible = false;
                        vm.selectedIndex = null;
                        vm.quillController.document = quill.Document();
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Discard'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      else
        const Center(child: Text('No note selected for editing.')),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() {
          _selectedIndex = i;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video),
            label: 'Video',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Editor'),
        ],
      ),
    );
  }
}
