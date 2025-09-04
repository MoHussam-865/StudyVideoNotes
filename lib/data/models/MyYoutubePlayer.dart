

import 'dart:ui';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../interfaces/Player.dart';

class MyYoutubePlayer extends Player {

  String url = '';
  YoutubePlayerController? videoController;

  YoutubePlayerController? get myController => videoController;

  @override
  double get aspectRatio => 16 / 9;
  @override
  int get currentTime => videoController?.value.position.inMilliseconds ?? 0;
  @override
  int get durationInMs => videoController?.metadata.duration.inMilliseconds ?? 0;
  @override
  Duration get duration => videoController?.metadata.duration ?? Duration();
  @override
  bool get isPlaying => videoController?.value.isPlaying ?? false;
  @override
  Duration get position => videoController?.value.position ?? Duration();

  @override
  Future<void> pause() async {
    videoController?.pause();
  }

  @override
  Future<void> play() async {
    videoController?.play();
  }

  @override
  Future<void> seekTo(Duration position) async {
    videoController?.seekTo(position);
  }

  @override
  Future<void> dispose() async {
    videoController?.dispose();
  }

  @override
  void addListener(VoidCallback onControllerUpdate) {
    videoController?.addListener(onControllerUpdate);
  }

  @override
  void removeListener(VoidCallback onControllerUpdate) {
    videoController?.removeListener(onControllerUpdate);
  }

  @override
  String get name => url;


  @override
  Future start(String url) async {

    final id = getYoutubeId(url);

    videoController = YoutubePlayerController(
      initialVideoId: id,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    this.url = url;
    return () {};
  }


  String getYoutubeId(String url) {
    final regExp = RegExp(
      r"(?:v=|\/)([0-9A-Za-z_-]{11}).*",
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return match != null ? match.group(1)! : "";
  }

  @override
  get controller => videoController;

}
