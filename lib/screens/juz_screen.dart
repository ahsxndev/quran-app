/// ---------------------------------------------------------------------------
/// 📖 JuzScreen
///
/// 🧠 Purpose:
///   Displays all verses (ayat) within a selected Juz (Para) of the Quran
///   including Surah names, Ayah numbers, and translations (English/Urdu).
///
/// 📦 Dependencies:
///   - quran (for ayah data)
///   - TranslationMenuButton (custom widget)
///
/// 🔁 Features:
///   - Translation toggle menu
///   - Dynamic rendering of Surahs and Bismillah
///   - Header with Juz overview (start, end, total ayat)
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/constants/constants.dart';
import '../widgets/translation_menu_button.dart';

class JuzScreen extends StatefulWidget {
  static const String id = 'juz_screen';

  const JuzScreen({super.key});

  @override
  State<JuzScreen> createState() => _JuzScreenState();
}

class _JuzScreenState extends State<JuzScreen> {
  final int juzNumber = Constants.juzIndex;

  /// 🌍 Current selected translation type (English, Urdu, Both)
  TranslationOption selectedOption = TranslationOption.english;

  @override
  Widget build(BuildContext context) {
    // 🧠 Get all Surah-Ayah combinations in the selected Juz
    final Map<int, List<int>> surahRanges = quran.getSurahAndVersesFromJuz(juzNumber);
    final List<Map<String, int>> ayahList = [];

    surahRanges.forEach((surah, range) {
      for (int ayah = range[0]; ayah <= range[1]; ayah++) {
        ayahList.add({'surah': surah, 'ayah': ayah});
      }
    });

    final String startSurah = quran.getSurahName(ayahList.first['surah']!);
    final String endSurah = quran.getSurahName(ayahList.last['surah']!);
    final int totalAyat = ayahList.length;

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Constants.kPurple),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          // 🌐 Language menu for selecting translation
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TranslationMenuButton(
              selectedOption: selectedOption,
              onSelected: (opt) => setState(() => selectedOption = opt),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 🪪 Header showing Juz info
          SliverToBoxAdapter(
            child: _buildHeader(startSurah, endSurah, totalAyat),
          ),
          // 📜 Full list of ayat in this Juz
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final current = ayahList[index];
                final surahNum = current['surah']!;
                final ayahNum = current['ayah']!;

                final arabic = quran.getVerse(surahNum, ayahNum, verseEndSymbol: true);
                final surahNameArabic = quran.getSurahNameArabic(surahNum);
                final surahNameEng = quran.getSurahName(surahNum);
                final isNewSurah = ayahNum == 1;

                final english = quran.getVerseTranslation(
                  surahNum,
                  ayahNum,
                  translation: quran.Translation.enSaheeh,
                  verseEndSymbol: false,
                );
                final urdu = quran.getVerseTranslation(
                  surahNum,
                  ayahNum,
                  translation: quran.Translation.urdu,
                  verseEndSymbol: false,
                );

                final List<Widget> widgets = [];

                // 🆕 Add Surah Title if this is the first Ayah
                if (isNewSurah) {
                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 0),
                      child: Text(
                        'سورة $surahNameArabic',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Uthmanic',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Constants.kPurple,
                        ),
                      ),
                    ),
                  );

                  // 💠 Add Bismillah (except Surah 1 & 9)
                  if (surahNum != 1 && surahNum != 9) {
                    widgets.add(
                      const Padding(
                        padding: EdgeInsets.only(top: 12, bottom: 8),
                        child: Text(
                          quran.basmala,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Uthmanic',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Constants.kMagenta,
                          ),
                        ),
                      ),
                    );
                  }
                }

                widgets.add(_buildAyahCard(
                  ayahNum,
                  arabic,
                  english,
                  urdu,
                  surahNameEng,
                  ayahNum,
                  index,
                ));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widgets,
                );
              },
              childCount: ayahList.length,
            ),
          ),
        ],
      ),
    );
  }

  /// 🪪 Builds the header of the Juz page with background and stats
  Widget _buildHeader(String startSurah, String endSurah, int totalAyat) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 200;

    return Stack(
      children: [
        // 📷 Background image
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

        // 🖤 Overlay
        Container(
          height: headerHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0x4D000000),
          ),
        ),

        // 🧾 Text content
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
                    'Juz $juzNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Starts with: $startSurah\nEnd with: $endSurah',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(width: 100, height: 2, color: Colors.white54),
                  const SizedBox(height: 10),
                  Text(
                    '$totalAyat Ayat in total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📖 Renders a single Ayah block with Arabic + Translations
  Widget _buildAyahCard(
      int ayahNum,
      String arabic,
      String english,
      String urdu,
      String surahName,
      int ayahNumber,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          // 🔹 Surah Name + Ayah number + serial bubble
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$surahName • Ayah $ayahNumber',
                style: const TextStyle(
                  fontSize: 14,
                  color: Constants.kPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CircleAvatar(
                backgroundColor: Constants.kMagenta,
                radius: 16,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🕋 Arabic text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Constants.kMagenta,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🌐 English Translation (if selected)
          if (selectedOption == TranslationOption.english || selectedOption == TranslationOption.both)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                english,
                style: const TextStyle(
                  fontSize: 15,
                  color: Constants.kPurple,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
            ),

          const SizedBox(height: 6),

          // 🌙 Urdu Translation (if selected)
          if (selectedOption == TranslationOption.urdu || selectedOption == TranslationOption.both)
            Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  urdu,
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
}
