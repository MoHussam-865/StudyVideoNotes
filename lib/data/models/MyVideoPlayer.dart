import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_notes/data/interfaces/MyPlayer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MyVideoPlayer extends MyPlayer {
  final player = Player();
  VideoController? controller;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String videoPath = '';

  @override
  int get currentTime => _position.inMilliseconds;

  @override
  int get durationInMs => _duration.inMilliseconds;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Duration get position => _position;

  @override
  String get name => videoPath;

  @override
  Duration get duration => _duration;

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await player.seek(position);
  }

  @override
  Future start(String path) async {
    final x = _isYoutubeUrl(path);
    debugPrint('path: $path, x: $x');

    if (x) {
      final link = await getYoutubeVideoUrl(path);
      debugPrint('Youtube link: $link');
      path = link;
    }

    controller = VideoController(player);

    await player.open(Media(path));

    final file = File(path);
    final videoPath = file.absolute.path;
    this.videoPath = videoPath;

    player.stream.playing.listen((value) {
      _isPlaying = value;
    });

    player.stream.position.listen((value) {
      _position = value;
    });

    player.stream.duration.listen((value) {
      _duration = value;
    });
  }

  @override
  Future<void> dispose() async {
    await player.dispose();
  }

  bool _isYoutubeUrl(String url) {
    final host = url.toLowerCase();
    return host.contains("youtube.com");
  }

  Future<String> getYoutubeVideoUrl(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      // Try mixed first
      final muxed = manifest.muxed;
      if (muxed.isNotEmpty) {
        return muxed.withHighestBitrate().url.toString();
      }

      // Fallback: pick best video + audio (separate streams)
      final videoStream = manifest.videoOnly.withHighestBitrate();
      //final audioStream = manifest.audioOnly.withHighestBitrate();

      // ❗ media_kit needs a single playable URL.
      // If you want to play both video & audio together, you'd need to
      // provide both Media() objects to Player.open().
      // For example:
      // await player.open(Media(videoStream.url.toString()), Media(audioStream.url.toString()));

      return videoStream.url.toString();
    } finally {
      yt.close();
    }
  }
}
