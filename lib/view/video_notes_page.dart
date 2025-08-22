import 'package:flutter/material.dart';
import '../viewmodel/video_notes_view_model.dart';
import 'video_notes_desktop_view.dart';
import 'video_notes_mobile_view.dart';

class VideoNotesView extends StatefulWidget {
  const VideoNotesView({super.key});

  @override
  State<VideoNotesView> createState() => _VideoNotesPageState();
}

class _VideoNotesPageState extends State<VideoNotesView> {
  late final VideoNotesViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = VideoNotesViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Notes'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await vm.pickAndOpenVideo(context);
              setState(() {});
            },
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            onPressed: () {
              vm.closeVideoAndReset();
              setState(() {});
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close Video',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return VideoNotesDesktopView(vm: vm);
          } else {
            return VideoNotesMobileView(vm: vm);
          }
        },
      ),
    );
  }
}


