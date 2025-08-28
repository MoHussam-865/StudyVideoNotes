import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullVideoViewModel extends ChangeNotifier {
  final VideoPlayerController videoController;
  FullVideoViewModel({required this.videoController});

  bool get isPlaying => videoController.value.isPlaying;
  Duration get position => videoController.value.position;
  Duration get duration => videoController.value.duration;
  double get aspectRatio => videoController.value.aspectRatio;

  void play() {
    videoController.play();
    notifyListeners();
  }

  void pause() {
    videoController.pause();
    notifyListeners();
  }

  void seekTo(Duration position) {
    videoController.seekTo(position);
    notifyListeners();
  }
}
