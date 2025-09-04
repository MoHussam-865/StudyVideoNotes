


import 'dart:ui';


abstract class Player {

  dynamic get controller;

  int get currentTime;
  int get durationInMs;
  bool get isPlaying;
  double get aspectRatio;
  Duration get duration;
  Duration get position;
  String get name;

  Future start(String video);

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(Duration position);

  Future<void> dispose();

  void addListener(VoidCallback onControllerUpdate);

  void removeListener(VoidCallback onControllerUpdate);


}