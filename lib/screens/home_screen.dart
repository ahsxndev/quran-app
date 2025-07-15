import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  void setData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUsed",true );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;



    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: size.height * 0.25,
                  width: double.infinity,
                  child: const Image(
                    image: AssetImage('assets/images/background_img.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: size.height * 0.25,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x80000000), // Black with 50% opacity
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                Positioned(
                  top: size.height * 0.009,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF), // 20% White
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x4DFFFFFF)), // 30% White border
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000), // 20% black shadow
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(Constants.getWeekday(), style: Constants.gregorianWeekdayStyle),
                        const SizedBox(height: 4),
                        Text(Constants.getDay(), style: Constants.gregorianDayStyle),
                        const SizedBox(height: 2),
                        Text(Constants.getMonthYear(), style: Constants.gregorianMonthYearStyle),
                        const SizedBox(height: 16),
                        Text(Constants.getFormattedHijriDateArabic(), style: Constants.hijriDateStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(top: 10, bottom: 20),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      quran.RandomVerse randomVerse = quran.RandomVerse();
                      final verseNum =randomVerse.verseNumber;
                      final surahNum =randomVerse.surahNumber;
                      //final arabic = quran.getVerse(surahNum, randomVerse, verseEndSymbol: false);
                      final arabic = randomVerse.verse;
                      final surahName = quran.getSurahName(surahNum);
                      final translation = randomVerse.translation;

                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(blurRadius: 3, spreadRadius: 1, offset: Offset(0, 1))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Qur’an Ayah of the Day',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Constants.kMagenta
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(thickness: 1, color: Constants.kPurple),
                            const SizedBox(height: 12),

                            // Arabic Ayah
                            Text(
                              arabic,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Uthmanic',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // English Translation
                            Text(
                              translation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Surah Info
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Surah: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$surahName ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Constants.kMagenta,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '(Ayah $verseNum)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
