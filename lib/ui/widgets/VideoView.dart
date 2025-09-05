import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_notes/ui/widgets/video_controls.dart';

import '../features/main/video_notes_view_model.dart';

class VideoView extends StatelessWidget {
  final VideoNotesViewModel vm;
  final VoidCallback refresh;
  final Future<void> Function() onFullScreenClicked;

  const VideoView({
    super.key,
    required this.onFullScreenClicked,
    required this.vm,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    final controller = vm.videoController?.controller;
    return (vm.videoController == null && !vm.isLoading)
        ? Center(child: Text('Open a video to begin'))
        : (vm.isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: <Widget>[
                    if (controller != null)
                      SizedBox.expand(
                        child: Center(
                          child: Video(
                            controller: controller,
                            controls: (state) {
                              return VideoControls(
                                c: vm.videoController!,
                                onFullScreenClicked: () async {
                                  await onFullScreenClicked();
                                  refresh();
                                },
                                refresh: refresh,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ));
  }
}
