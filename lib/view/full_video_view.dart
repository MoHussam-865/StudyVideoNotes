import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../viewmodel/full_video_view_model.dart';

class FullVideoView extends StatefulWidget {
  final FullVideoViewModel vm;
  const FullVideoView({super.key, required this.vm});

  @override
  State<FullVideoView> createState() => _FullVideoViewState();
}

class _FullVideoViewState extends State<FullVideoView> {
  void _addNoteAndBack() {
    // Use Navigator.pop with result to pass the current time back
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
    );
  }
}
