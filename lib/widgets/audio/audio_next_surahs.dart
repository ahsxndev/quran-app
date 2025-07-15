import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class AudioNextSurahs extends StatelessWidget {
  final int currentSurah;
  final Function(int) onSelect;

  const AudioNextSurahs({
    super.key,
    required this.currentSurah,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        final nextSurah = (currentSurah + index) % 114 + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(nextSurah),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.library_music_rounded, color: Color(0xFF4F0477)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Surah ${quran.getSurahName(nextSurah)}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${quran.getVerseCount(nextSurah)} verses",
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF4F0477), size: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
