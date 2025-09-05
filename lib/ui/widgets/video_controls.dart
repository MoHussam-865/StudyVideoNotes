import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_notes/data/interfaces/MyPlayer.dart';
import 'package:video_notes/data/models/MyVideoPlayer.dart';

class VideoControls extends StatefulWidget {
  final MyVideoPlayer c;
  final VoidCallback refresh;
  final VoidCallback onFullScreenClicked;
  final Color color;

  const VideoControls({
    super.key,
    required this.c,
    required this.onFullScreenClicked,
    required this.refresh,
    this.color = Colors.white,
  });

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  late Timer _timer;
  String time = '';
  late final controller = widget.c;

  String _formatTime(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          time = _formatTime(widget.c.position);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  widget.c.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.color,
                ),
                onPressed: () {
                  if (widget.c.isPlaying) {
                    widget.c.pause();
                  } else {
                    widget.c.play();
                  }
                  widget.refresh();
                },
              ),
              Expanded(
                child: Slider(
                  value: widget.c.position.inMilliseconds.toDouble().clamp(
                    0,
                    widget.c.duration.inMilliseconds.toDouble(),
                  ),
                  min: 0,
                  max: widget.c.duration.inMilliseconds.toDouble(),
                  onChanged: (v) {
                    widget.c.seekTo(Duration(milliseconds: v.toInt()));
                    widget.refresh();
                  },
                ),
              ),
              Text(time, style: TextStyle(color: widget.color)),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Fullscreen',
                icon: Icon(Icons.fullscreen, color: widget.color),
                onPressed: widget.onFullScreenClicked,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
