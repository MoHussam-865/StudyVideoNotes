import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:video_notes/routes/app_routes.dart';
import 'package:video_notes/routes/routes.dart';
import 'core/di/app_model.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MultiProvider(
    // dependency injection
    providers: AppModel.dependancies,

    child: const MyApp(),
  ),);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('ar'),
        Locale('de'),
        Locale('da'),
        Locale('fr'),
        Locale('zh'),
        Locale('ru'),
        Locale('es'),
        Locale('ja'),
        Locale('ko'),
        Locale('pt'),
        Locale('it'),
        Locale('tr'),
        Locale('uk'),
      ],
      initialRoute: MyRouts.home.value,
      routes: AppRoutes.routes,
    );
  }
}
