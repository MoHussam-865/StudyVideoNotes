import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'video_notes_view_model.dart';
import 'video_notes_desktop_view.dart';
import 'video_notes_mobile_view.dart';

class VideoNotesView extends StatefulWidget {
  const VideoNotesView({super.key});

  @override
  State<VideoNotesView> createState() => _VideoNotesPageState();
}

class _VideoNotesPageState extends State<VideoNotesView> {
  late final VideoNotesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _showLinkDialog(BuildContext context) async {
    final TextEditingController linkController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Video Link'),
          content: TextField(
            controller: linkController,
            decoration: const InputDecoration(hintText: "Enter link here"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Future.delayed(Duration(microseconds: 1), () async {
                  final String link = linkController.text;
                  await viewModel.openVideoFromLink(context, link);
                  debugPrint("Submitted link: $link");
                  setState(() {});

                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Notes'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Open Video from Link',
            onPressed: () {
              _showLinkDialog(context);
            },
          ),
          IconButton(
            onPressed: () async {
              await viewModel.pickAndOpenVideo(context);
              setState(() {});
            },
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            onPressed: () {
              viewModel.closeVideoAndReset();
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
            return VideoNotesDesktopView(viewModel: viewModel);
          } else {
            return VideoNotesMobileView(viewModel: viewModel);
          }
        },
      ),
    );
  }
}
