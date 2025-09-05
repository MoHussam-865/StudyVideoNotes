


import 'dart:ui';


abstract class MyPlayer {


  int get currentTime;
  int get durationInMs;
  bool get isPlaying;
  Duration get duration;
  Duration get position;
  String get name;

  Future start(String video);

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(Duration position);

  Future<void> dispose();

}