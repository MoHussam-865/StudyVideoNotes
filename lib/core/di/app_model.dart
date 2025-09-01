import 'package:get_it/get_it.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import '../../ui/features/full_screen/full_video_view_model.dart';
import '../../ui/features/main/video_notes_view_model.dart';

class AppModel {
  static List<SingleChildWidget> setupLocator() {
    final locator = GetIt.instance;

    // Singleton: same instance for whole app

    locator.registerLazySingleton<VideoNotesViewModel>(
      () => VideoNotesViewModel(),
    );

    // Factory: new instance every time, but injected with same VideoNotesViewModel
    locator.registerFactory(
      () => FullVideoViewModel(vm: locator<VideoNotesViewModel>()),
    );

    return [
      ChangeNotifierProvider(create: (_) => locator<VideoNotesViewModel>()),
      ChangeNotifierProvider(create: (_) => locator<FullVideoViewModel>()),
    ];
  }
}
