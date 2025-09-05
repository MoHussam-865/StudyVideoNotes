import 'package:flutter/material.dart';
import 'package:video_notes/data/models/MyVideoPlayer.dart';
import 'package:video_notes/ui/features/main/video_notes_view_model.dart';

import '../../../data/interfaces/MyPlayer.dart';
import '../../../data/models/time_title.dart';

class FullVideoViewModel extends ChangeNotifier {

  bool get isPlaying => videoController.isPlaying;
  Duration get position => videoController.position;
  Duration get duration => videoController.duration;

  List<TimeTitle> get timestampedMessages => vm.timesTitle;
  MyVideoPlayer get videoController => vm.videoController!;
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
