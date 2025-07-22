/// ---------------------------------------------------------------------------
/// 📖 SurahDetailScreen - View for a Specific Surah in the Quran
///
/// 🧠 Purpose:
///   - Displays detailed verses (Ayahs) of a selected Surah
///   - Shows Arabic text with optional English and Urdu translations
///   - Allows translation toggle via a reusable dropdown menu
///
/// 🚀 Key Features:
///   ✅ Displays Surah metadata (name, translation, place, Ayah count)
///   ✅ Highlights Basmala based on Surah index rules
///   ✅ Animated, custom-styled header with background image
///   ✅ Translation selection using `TranslationMenuButton`
///   ✅ Dynamically rendered Ayahs with direction and language-aware layout
///
/// 🧱 Structure:
///   - Stateful widget with:
///     - `TranslationOption` state
///     - `_buildHeader()` for top info and style
///     - `_buildAyahCard()` to render each verse with translations
///
/// 📦 Dependencies:
///   - `quran` package for verse data
///   - `Constants` for colors and design
///   - `translation_menu_button.dart` (custom widget)
///
/// 📌 Navigation:
///   - Navigated via named route using:
///       Navigator.pushNamed(context, SurahDetailScreen.id, arguments: { 'surahNumber': x });
///
/// 🖼 Assets Required:
///   - `assets/images/Bg.png`
///   - `assets/images/bismillah.png`
///
/// 📎 Example Usage:
///   ```dart
///   Navigator.pushNamed(context, SurahDetailScreen.id, arguments: { 'surahNumber': 36 });
///   ```
///
/// 🧑 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../constants/constants.dart';
import '../widgets/translation_menu_button.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  const SurahDetailScreen({super.key, required this.surahNumber});
  static const String id = "surahDetail_screen";

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  TranslationOption selectedOption = TranslationOption.english;

  @override
  Widget build(BuildContext context) {
    final surahNo = widget.surahNumber;
    final totalAyahs = quran.getVerseCount(surahNo);
    final engTransName = quran.getSurahNameEnglish(surahNo);
    final englishName = quran.getSurahName(surahNo);
    final place = quran.getPlaceOfRevelation(surahNo);
    final isBismillah = quran.basmala != '' && surahNo != 1 && surahNo != 9;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 200;

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Constants.kPurple, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TranslationMenuButton(
              selectedOption: selectedOption,
              onSelected: (opt) => setState(() => selectedOption = opt),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              statusBarHeight,
              headerHeight,
              englishName,
              engTransName,
              place,
              totalAyahs,
              isBismillah,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: totalAyahs,
              itemBuilder: (context, idx) {
                final ayahIndex = idx + 1;
                if (ayahIndex > totalAyahs) return const SizedBox();

                final arabic = quran.getVerse(surahNo, ayahIndex, verseEndSymbol: true);
                final english = quran.getVerseTranslation(surahNo, ayahIndex,
                    translation: quran.Translation.enSaheeh, verseEndSymbol: false);
                final urdu = quran.getVerseTranslation(surahNo, ayahIndex,
                    translation: quran.Translation.urdu, verseEndSymbol: false);

                return _buildAyahCard(ayahIndex, arabic, english, urdu);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahCard(int ayahNum, String arabic, String eng, String ur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Constants.kPurple, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                arabic,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constants.kMagenta,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (selectedOption == TranslationOption.english || selectedOption == TranslationOption.both)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                eng,
                style: const TextStyle(
                  fontSize: 15,
                  color: Constants.kPurple,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          const SizedBox(height: 4),
          if (selectedOption == TranslationOption.urdu || selectedOption == TranslationOption.both)
            Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  ur,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'NotoNastaliqUrdu',
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      double statusBarHeight,
      double headerHeight,
      String englishName,
      String engTransName,
      String place,
      int totalAyahs,
      bool isBismillah,
      ) {
    return Stack(
      children: [
        Container(
          height: headerHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage('assets/images/Bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: headerHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0x4D000000),
          ),
        ),
        SizedBox(
          height: headerHeight,
          width: double.infinity,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: statusBarHeight - 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    englishName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    engTransName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 2,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$place • $totalAyahs Ayat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isBismillah) ...[
                    const SizedBox(height: 14),
                    Image.asset(
                      'assets/images/bismillah.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}