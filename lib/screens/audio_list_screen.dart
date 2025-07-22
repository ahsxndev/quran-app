/// ----------------------------------------------------------------------
/// 📄 AudioListScreen
///
/// 🔊 Displays a scrollable list of all 114 Quranic Surahs with tap-to-play audio.
/// 🔹 Highlights the currently selected Surah.
/// 🔹 Tapping a tile navigates to the `AudioScreen`.
///
/// 🛠️ Dev Notes:
/// - Uses `quran` package to fetch Surah names.
/// - `QuranCustomTile` is a reusable widget for styling list tiles.
/// - Customize the visual theme using `Constants.kPurple`.
/// ----------------------------------------------------------------------

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
        title: const Text(
          'Quran Audio List',
          style: TextStyle(
            color: Constants.kPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: 114, // Total number of Surahs in the Quran
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
              // Highlight the currently playing Surah
              setState(() {
                _currentPlayingSurah = surahNumber;
              });

              // Navigate to the audio playback screen
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioScreen(surahNumber: surahNumber),
                ),
              );

              // Reset highlight when user returns
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
