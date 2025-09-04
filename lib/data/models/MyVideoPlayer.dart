


import 'dart:io';
import 'dart:ui';

import 'package:video_notes/data/interfaces/Player.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends Player {

  VideoPlayerController? videoController;

  VideoPlayerController? get myController => videoController;

  String videoPath = '';

  @override
  double get aspectRatio => videoController?.value.aspectRatio ?? 0.0;
  @override
  int get currentTime => videoController?.value.position.inMilliseconds ?? 0;
  @override
  int get durationInMs => videoController?.value.duration.inMilliseconds ?? 0;
  @override
  Duration get duration => videoController?.value.duration ?? Duration();
  @override
  bool get isPlaying => videoController?.value.isPlaying ?? false;
  @override
  Duration get position => videoController?.value.position ?? Duration();

  @override
  Future<void> pause() async {
    await videoController?.pause();
  }

  @override
  Future<void> play() async {
    await videoController?.play();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await videoController?.seekTo(position);
  }

  @override
  Future start(String path) async {
    final file = File(path);
    final videoPath = file.absolute.path;
    this.videoPath = videoPath;
    VideoPlayerController controller = VideoPlayerController.file(file);
    videoController = controller;

    try {
      Future<void> initializeVideoFuture = controller.initialize();
      await initializeVideoFuture;
      if (!controller.value.isInitialized) {
        throw StateError(
          controller.value.errorDescription ?? 'Failed to initialize video',
        );
      }
      controller.addListener(() {});
      await controller.play();
      return initializeVideoFuture;
    } catch (e) {
      await controller.dispose();
      videoController = null;
      throw StateError('Cannot open video: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await videoController?.dispose();
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
  String get name => videoPath;

  @override

  get controller => videoController;

}