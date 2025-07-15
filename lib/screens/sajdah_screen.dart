import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/widgets/translation_menu_button.dart';

import '../constants/constants.dart'; // <-- Import widget

class SajdahScreen extends StatefulWidget {
  const SajdahScreen({super.key});

  @override
  State<SajdahScreen> createState() => _SajdahScreenState();
}

class _SajdahScreenState extends State<SajdahScreen> {
  List<Map<String, int>> sajdahList = [];
  final Map<int, TranslationOption> _translationOptions = {};

  @override
  void initState() {
    super.initState();
    for (var s = 1; s <= quran.totalSurahCount; s++) {
      final total = quran.getVerseCount(s);
      for (var v = 1; v <= total; v++) {
        if (quran.isSajdahVerse(s, v)) {
          sajdahList.add({'surah': s, 'ayah': v});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        title: const Text("Sajdah Verses", style: TextStyle(color: Constants.kPurple)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Constants.kPurple),
      ),
      body: ListView.builder(
        itemCount: sajdahList.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, i) {
          final surah = sajdahList[i]['surah']!;
          final ayah = sajdahList[i]['ayah']!;
          final arabic = quran.getVerse(surah, ayah, verseEndSymbol: false);
          final eng = quran.getVerseTranslation(
            surah,
            ayah,
            translation: quran.Translation.enSaheeh,
            verseEndSymbol: false,
          );
          final urdu = quran.getVerseTranslation(
            surah,
            ayah,
            translation: quran.Translation.urdu,
            verseEndSymbol: false,
          );

          final selected = _translationOptions[i] ?? TranslationOption.english;

          return _buildSajdahTile(
            index: i + 1,
            surah: surah,
            ayah: ayah,
            arabic: arabic,
            eng: eng,
            urdu: urdu,
            selectedOption: selected,
            onOptionChanged: (newOpt) {
              setState(() => _translationOptions[i] = newOpt);
            },
          );
        },
      ),
    );
  }

  Widget _buildSajdahTile({
    required int index,
    required int surah,
    required int ayah,
    required String arabic,
    required String eng,
    required String urdu,
    required TranslationOption selectedOption,
    required Function(TranslationOption) onOptionChanged,
  }) {
    final surahName = quran.getSurahName(surah);
    final place = quran.getPlaceOfRevelation(surah);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    '$surahName • Ayah $ayah • $place',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Constants.kPurple,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TranslationMenuButton(
                selectedOption: selectedOption,
                onSelected: onOptionChanged,
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Constants.kMagenta,
                radius: 16,
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabic,
              style: const TextStyle(
                fontSize: 22,
                color: Constants.kMagenta,
                fontWeight: FontWeight.bold,
                fontFamily: 'Uthmanic',
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 10),

          if (selectedOption == TranslationOption.english || selectedOption == TranslationOption.both)
            Text(
              eng,
              style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
              textAlign: TextAlign.left,
            ),

          if (selectedOption == TranslationOption.urdu || selectedOption == TranslationOption.both)
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                urdu,
                style: const TextStyle(fontSize: 15,
                    fontFamily: 'NotoNastaliqUrdu',
                    color: Colors.black54, height: 1.5),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
