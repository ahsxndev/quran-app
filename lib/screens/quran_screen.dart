import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/constants/constants.dart';
import 'package:quran_app/screens/sajdah_screen.dart';
import 'package:quran_app/screens/juz_screen.dart';
import 'package:quran_app/screens/surah_detail_screen.dart';
import '../widgets/quran_custom_tile.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final double headerHeight = statusBarHeight + 150;

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: headerHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 16), // No full-width
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
                      color: Color(0x4D000000)
                    ),
                  ),

                  SizedBox(
                    height: 160,
                    child: Stack(
                      children: [
                        Positioned(
                          top: statusBarHeight + 5,
                          left: 32,
                          child: IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quran.basmala,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Uthmanic',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                  height: 8,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Let\'s read the Quran',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 120, // control the max height
                            margin: const EdgeInsets.only(right: 20),
                            child: Image.asset(
                              'assets/images/quran2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),



                  Positioned(
                    bottom: 10,
                    left: 32,
                    right: 32,
                    child: const TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      tabs: [
                        Tab(text: 'Surah'),
                        Tab(text: 'Para(Juz)'),
                        Tab(text: 'Sajda'),
                      ],
                    ),
                  ),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    ListView.builder(
                      itemCount: 114,
                      itemBuilder: (context, index) {
                        final surahNum = index + 1;
                        return QuranCustomTile(
                          number: surahNum,
                          title: quran.getSurahName(surahNum),
                          subtitle: '${quran.getPlaceOfRevelation(surahNum)} • ${quran.getVerseCount(surahNum)} Ayat',
                          arabicName: 'سورة ${quran.getSurahNameArabic(surahNum)}',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SurahDetailScreen.id,
                              arguments: {'surahNumber': surahNum},
                            );
                          },
                        );
                      },
                    ),
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final juzNum = index + 1;
                        final paraData = Constants.paraNames[index];

                        final Map<int, List<int>> surahRanges = quran.getSurahAndVersesFromJuz(juzNum);
                        final List<Map<String, int>> ayahList = [];

                        surahRanges.forEach((surah, range) {
                          for (int ayah = range[0]; ayah <= range[1]; ayah++) {
                            ayahList.add({'surah': surah, 'ayah': ayah});
                          }
                        });

                        final int totalAyat = ayahList.length;
                        return QuranCustomTile(
                          number: juzNum,
                          title: paraData['english']!,
                          subtitle: '$totalAyat Ayat',
                          arabicName: paraData['arabic']!,
                          onTap: () {
                            Constants.juzIndex = juzNum;
                            Navigator.pushNamed(context, JuzScreen.id);
                          },
                        );
                      },
                    ),
                    const SajdahScreen(),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

