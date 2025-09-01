import 'package:flutter/material.dart';
import 'package:video_notes/ui/features/main/video_notes_view_model.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/timestamped_message.dart';

class FullVideoViewModel extends ChangeNotifier {
  List<TimestampedMessage> timestampedMessages = [];
  late VideoPlayerController videoController;
  final VideoNotesViewModel videoViewModel;

  FullVideoViewModel({required this.videoViewModel}) {
    videoController = videoViewModel?.videoController;
    timestampedMessages = videoViewModel.timestampedMessages;
  }

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
