import 'package:flutter/material.dart';
import 'package:video_notes/ui/features/main/video_notes_view_model.dart';
import 'package:video_player/video_player.dart';

import '../../../data/interfaces/Player.dart';
import '../../../data/models/time_title.dart';

class FullVideoViewModel extends ChangeNotifier {

  bool get isPlaying => videoController.isPlaying;
  Duration get position => videoController.position;
  Duration get duration => videoController.duration;
  double get aspectRatio => videoController.aspectRatio;

  List<TimeTitle> get timestampedMessages => vm.timesTitle;
  Player get videoController => vm.videoController!;
  final VideoNotesViewModel vm;

  FullVideoViewModel({required this.vm});



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
