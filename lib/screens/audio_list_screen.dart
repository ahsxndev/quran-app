import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../constants/constants.dart';
import '../widgets/quran_custom_tile.dart';
import 'audio_screen.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  int? _currentPlayingSurah;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Audio List',
        style: TextStyle(
          color: Constants.kPurple,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: 114,
        itemBuilder: (context, index) {
          final surahNumber = index + 1;
          final englishName = quran.getSurahName(surahNumber);
          final arabicName = quran.getSurahNameArabic(surahNumber);

          return QuranCustomTile(
            number: surahNumber,
            title: englishName,
            subtitle: 'Tap to load audio',
            arabicName: arabicName,
            showIcon: true,
            isPlaying: _currentPlayingSurah == surahNumber,
            showDownloadedIcon: true,
            onTap: () async {
              setState(() {
                _currentPlayingSurah = surahNumber;
              });
                  // Navigate to audio player screen
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioScreen(surahNumber: surahNumber),
                ),
              );

              // Reset the current playing surah when returning
              setState(() {
                _currentPlayingSurah = null;
              });
            },
          );
        },
      ),
    );
  }
}
