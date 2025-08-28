import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../viewmodel/full_video_view_model.dart';
import '../models/timestamped_message.dart';

class FullVideoView extends StatefulWidget {
  final FullVideoViewModel vm;
  final List<TimestampedMessage> timestampedMessages;

  const FullVideoView({
    super.key,
    required this.vm,
    required this.timestampedMessages,
  });

  @override
  State<FullVideoView> createState() => _FullVideoViewState();
}

class _FullVideoViewState extends State<FullVideoView> {
  bool _showList = false;

  void _addNoteAndBack() {
    Navigator.of(context).pop(widget.vm.position);
  }

  @override
  void initState() {
    super.initState();
    widget.vm.videoController.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.vm.videoController.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
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
                      aspectRatio: vm.aspectRatio,
                      child: VideoPlayer(vm.videoController),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            vm.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (vm.isPlaying) {
                              vm.pause();
                            } else {
                              vm.play();
                            }
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: vm.position.inMilliseconds.toDouble().clamp(
                              0,
                              vm.duration.inMilliseconds.toDouble(),
                            ),
                            min: 0,
                            max: vm.duration.inMilliseconds.toDouble(),
                            onChanged: (v) {
                              vm.seekTo(Duration(milliseconds: v.toInt()));
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
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
                        itemCount: widget.timestampedMessages.length,
                        itemBuilder: (context, index) {
                          final msg = widget.timestampedMessages[index];
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
                              vm.seekTo(msg.time);
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
