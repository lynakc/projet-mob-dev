import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audio_service/audio_service.dart';

import 'features/auth/lock_screen.dart';
import 'features/auth/reset_password.dart';
import 'core/theme/theme_manager.dart';
import 'core/theme/theme_state.dart';
import 'core/audio/audio_handler.dart';

late MyAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.audio',
        androidNotificationChannelName: 'Quran Playback',
        androidNotificationOngoing: true,
      ),
    );
  } catch (e) {
    debugPrint("AudioService init failed: $e");
  }

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeState.currentTheme,
      builder: (context, value, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeManager.getTheme(value),
          home: const LockScreen(),
          routes: {'/reset-password': (context) => ResetPasswordPage()},
        );
      },
    );
  }
}
