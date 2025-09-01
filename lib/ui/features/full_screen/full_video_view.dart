import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/video_controls.dart';
import 'full_video_view_model.dart';

class FullVideoView extends StatefulWidget {


  const FullVideoView({super.key});

  @override
  State<FullVideoView> createState() => _FullVideoViewState();
}

class _FullVideoViewState extends State<FullVideoView> {
  late FullVideoViewModel viewModel;
  bool _showList = false;

  @override
  void initState() {
    super.initState();

    viewModel = context.read();
    viewModel.videoController.addListener(_onControllerUpdate);

  }


  void _addNoteAndBack() {
    Navigator.pop(context, viewModel.position);
  }



  @override
  void dispose() {
    viewModel.videoController.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Add Note'),
                          onPressed: _addNoteAndBack,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: Icon(_showList ? Icons.close : Icons.list),
                          label: Text(_showList ? 'Hide List' : 'Show List'),
                          onPressed: () {
                            setState(() {
                              _showList = !_showList;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: AspectRatio(
                      aspectRatio: viewModel.aspectRatio,
                      child: VideoPlayer(viewModel.videoController),
                    ),
                  ),
                  VideoControls(
                    c: viewModel.videoController,
                    onFullScreenClicked: () {
                      Navigator.of(context).pop();
                    },
                    refresh: () => setState(() {}),
                    color: Colors.white,
                  ),
                  // Positioned(
                  //   bottom: 24,
                  //   left: 24,
                  //   right: 24,
                  //   child: Row(
                  //     children: [
                  //       IconButton(
                  //         icon: Icon(
                  //           viewModel.isPlaying
                  //               ? Icons.pause
                  //               : Icons.play_arrow,
                  //           color: Colors.white,
                  //         ),
                  //         onPressed: () {
                  //           if (viewModel.isPlaying) {
                  //             viewModel.pause();
                  //           } else {
                  //             viewModel.play();
                  //           }
                  //         },
                  //       ),
                  //       Expanded(
                  //         child: Slider(
                  //           value: viewModel.position.inMilliseconds
                  //               .toDouble()
                  //               .clamp(
                  //                 0,
                  //                 viewModel.duration.inMilliseconds.toDouble(),
                  //               ),
                  //           min: 0,
                  //           max: viewModel.duration.inMilliseconds.toDouble(),
                  //           onChanged: (v) {
                  //             viewModel.seekTo(
                  //               Duration(milliseconds: v.toInt()),
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //       IconButton(
                  //         icon: const Icon(Icons.close, color: Colors.white),
                  //         onPressed: () {
                  //           Navigator.of(context).pop();
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            if (_showList) ...[
              VerticalDivider(width: 1, color: Colors.grey.shade700),
              Container(
                width: 320,
                color: Colors.black.withOpacity(0.85),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Timestamps',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.timestampedMessages.length,
                        itemBuilder: (context, index) {
                          final msg = viewModel.timestampedMessages[index];
                          String two(int v) => v.toString().padLeft(2, '0');
                          final h = msg.time.inHours;
                          final m = msg.time.inMinutes.remainder(60);
                          final s = msg.time.inSeconds.remainder(60);
                          final timeStr = h > 0
                              ? '${two(h)}:${two(m)}:${two(s)}'
                              : '${two(m)}:${two(s)}';
                          return ListTile(
                            title: Text(
                              timeStr,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              msg.message,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              viewModel.seekTo(msg.time);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
