import 'package:flutter/material.dart';
import 'package:quran_app/constants/constants.dart';
import 'package:quran_app/screens/juz_screen.dart';
import 'package:quran_app/screens/splash_screen.dart';
import 'package:quran_app/screens/surah_detail_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.chaneel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
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
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: ThemeData(
        primaryColor: Constants.kPrimary,
        primarySwatch: Constants.kSwatchColor,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins'
      ),
      home: const SplashScreen(),
      routes: {
        JuzScreen.id: (context)=> JuzScreen(),
        SurahDetailScreen.id: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SurahDetailScreen(surahNumber: args['surahNumber']);
        },
      },
    );
  }
}