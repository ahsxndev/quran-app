/// ---------------------------------------------------------------------------
/// 🕌 Al-Quran App Entry Point
///
/// 📘 File: main.dart
///
/// 🔧 Responsibilities:
///   - Initializes core services:
///     • Flutter bindings
///     • Audio background service (just_audio_background)
///     • Timezone database (for prayer times or local events)
///
///   - Configures:
///     • Custom app-wide theming (Poppins font, magenta-purple UI)
///     • Navigation routes using named and argument-based routing
///
/// 🎧 Audio Background Setup:
///   - Enables persistent playback notifications
///   - Uses purple color theme for Android controls
///
/// 🕰️ Timezone:
///   - Initializes the latest IANA timezone data via `timezone` package
///
/// 📱 Home:
///   - SplashScreen is the landing page
///
/// 📂 Route Table:
///   - `JuzScreen.id`        → Juz listing screen
///   - `SurahDetailScreen.id` → Detailed view with passed surahNumber
///   - `/tasbeeh`            → Digital Tasbeeh Counter
///   - `/names`              → 99 Names of Allah
///
/// 🧩 Optional Suggestions:
///   - Consider using `go_router` or `auto_route` for structured deep linking
///   - Externalize the route table to a separate file if it grows
///
/// ---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:quran_app/constants/constants.dart';
import 'package:quran_app/screens/custom_licenses_screen.dart';
import 'package:quran_app/screens/juz_screen.dart';
import 'package:quran_app/screens/names_screen.dart';
import 'package:quran_app/screens/splash_screen.dart';
import 'package:quran_app/screens/surah_detail_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quran_app/screens/tasbih_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.chaneel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    notificationColor: const Color(0xFF4F0477), // Purple theme
  );

  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Al-Quran',
      theme: ThemeData(
        primaryColor: Constants.kPrimary,
        primarySwatch: Constants.kSwatchColor,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFB121BF), // Cursor color (magenta)
          selectionColor: Color(0xFF4F0477), // Background color of selected text
          selectionHandleColor: Color(0xFFB121BF), // Handle draggable knob color
        ),

      ),
      home: const SplashScreen(),
      routes: {
        JuzScreen.id: (context)=> JuzScreen(),
        SurahDetailScreen.id: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SurahDetailScreen(surahNumber: args['surahNumber']);
        },
        '/tasbeeh': (_) => const TasbeehScreen(),
        '/names': (_) => const NamesScreen(),
        '/license': (_) => const LicensesScreen(),
      },
    );
  }
}