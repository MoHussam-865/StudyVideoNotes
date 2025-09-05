



import 'package:video_notes/routes/routes.dart';
import 'package:video_notes/ui/features/test_view.dart';

import '../ui/features/full_screen/full_video_view.dart';
import '../ui/features/main/video_notes_page.dart';

class AppRoutes {

  static var routes = {
    MyRouts.fullScreen.value: (context) => FullVideoView(),
    MyRouts.home.value: (context) => VideoNotesView(),
    MyRouts.test.value: (context) => TestView(),

  };

}