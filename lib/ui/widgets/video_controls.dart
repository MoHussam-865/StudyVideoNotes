import 'package:flutter/material.dart';
import 'package:video_notes/data/interfaces/Player.dart';

class VideoControls extends StatelessWidget {
  final Player c;
  final VoidCallback refresh;
  final VoidCallback onFullScreenClicked;
  final Color color;

  const VideoControls({
    super.key,
    required this.c,
    required this.onFullScreenClicked,
    required this.refresh,
    this.color = Colors.black,
  });

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
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              c.isPlaying ? Icons.pause : Icons.play_arrow,
              color: color,
            ),
            onPressed: () {
              if (c.isPlaying) {
                c.pause();
              } else {
                c.play();
              }
              refresh();
            },
          ),
          Expanded(
            child: Slider(
              value: c.position.inMilliseconds.toDouble().clamp(
                0,
                c.duration.inMilliseconds.toDouble(),
              ),
              min: 0,
              max: c.duration.inMilliseconds.toDouble(),
              onChanged: (v) {
                c.seekTo(Duration(milliseconds: v.toInt()));
                refresh();
              },
            ),
          ),
          Text(
            '${_formatTime(c.position)} / ${_formatTime(c.duration)}',
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Fullscreen',
            icon: Icon(Icons.fullscreen, color: color),
            onPressed: onFullScreenClicked,
          ),
        ],
      ),
    );
  }
}
