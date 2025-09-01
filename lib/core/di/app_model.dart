

import 'package:video_notes/core/services/file_service.dart';
import 'package:provider/provider.dart';

import '../../ui/features/full_screen/full_video_view_model.dart';
import '../../ui/features/main/video_notes_view_model.dart';


class AppModel {
  static var dependancies = [
    Provider(create: (context) => FileService()),
    ChangeNotifierProvider(
      create: (context) => VideoNotesViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => FullVideoViewModel(videoViewModel: context.read()),
    ),
  ];
}