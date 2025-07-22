/// ---------------------------------------------------------------------------
/// 🕌 HomeScreen
///
/// 🧠 Purpose:
///   This is the main dashboard of the Al-Quran App. It shows the current
///   Gregorian and Hijri date, a random Quranic verse of the day, and
///   navigation shortcuts to features like Asma Ul Husna and Tasbeeh.
///
/// 📌 Key Components:
///   - Gregorian + Hijri Date Display
///   - Random Ayah of the Day (Arabic + Translation)
///   - Feature Shortcuts (99 Names, Tasbeeh)
///   - Developer Info Dialog with social links
///
/// 📦 Dependencies:
///   - shared_preferences
///   - url_launcher
///   - shimmer
///   - quran (package for ayah data)
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/constants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late quran.RandomVerse _randomVerse;
  String? _hijriDate;

  @override
  void initState() {
    super.initState();
    _randomVerse = quran.RandomVerse();
    _setData();
    _loadHijriDate();
  }

  Future<void> _setData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUsed", true);
  }

  Future<void> _loadHijriDate() async {
    final date = await Constants.getAccurateHijriDateArabic();
    setState(() {
      _hijriDate = date;
    });
  }

  void _showDeveloperInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xF2FFFFFF),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Constants.kPrimary,
                      child: Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ahsan Zaman',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Constants.kPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Developer of Al-Quran App',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Follow Developer on',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Constants.kPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDialogButton(
                          icon: Icons.link,
                          label: "LinkedIn",
                          color: Colors.blue.shade700,
                          url: 'https://www.linkedin.com/in/ahxanzaman',
                        ),
                        _buildDialogButton(
                          icon: Icons.code,
                          label: "GitHub",
                          color: Colors.black87,
                          url: 'https://github.com/ahsxndev',
                        ),
                        _buildDialogButton(
                          icon: Icons.alternate_email,
                          label: "Twitter / X",
                          color: Colors.blue,
                          url: 'https://x.com/ahsxn_dev',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Support the Developer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Constants.kPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDialogButton(
                          icon: Icons.volunteer_activism,
                          label: "Patreon",
                          color: Color(0xFFf96854),
                          url: 'https://www.patreon.com/c/ahsxn',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.article_outlined, color: Constants.kPurple),
                      label: const Text("View Licenses", style: TextStyle(color: Constants.kPurple)),
                      onPressed: () => Navigator.pushNamed(context, '/license'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 13),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // 🔹 Header with Date and Hijri
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
                      colors: [Color(0x80000000), Colors.transparent],
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
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x4DFFFFFF)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 10),
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
                        _hijriDate != null
                            ? Text(_hijriDate!, style: Constants.hijriDateStyle)
                            : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.white,
                          child: Container(height: 20, width: 150, color: Colors.grey[300]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🔹 Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(top: 10, bottom: 20),
                child: Column(
                  children: [
                    // 📖 Quran Ayah Box
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: const [BoxShadow(blurRadius: 3, spreadRadius: 1, offset: Offset(0, 1))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Qur’an Ayah of the Day',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Constants.kMagenta)),
                          const SizedBox(height: 12),
                          Divider(thickness: 1, color: Constants.kPurple),
                          const SizedBox(height: 12),
                          Text(
                            _randomVerse.verse,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Uthmanic',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _randomVerse.translation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Surah: ',
                                  style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: '${quran.getSurahName(_randomVerse.surahNumber)} ',
                                  style: const TextStyle(fontSize: 14, color: Constants.kMagenta, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '(Ayah ${_randomVerse.verseNumber})',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/names'),
                              child: _featureBox('assets/images/name.png', '99 Names', 'Asma Ul Husna'),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/tasbeeh'),
                              child: _featureBox('assets/images/tasbeeh.png', 'Tasbeeh', 'Daily Dhikr'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔹 About the Developer
                    Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 20),
                      child: GestureDetector(
                        onTap: _showDeveloperInfoDialog,
                        child: Column(
                          children: const [
                            Icon(Icons.info_outline_rounded, size: 28, color: Constants.kPrimary),
                            SizedBox(height: 6),
                            Text('About the Developer',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Constants.kPrimary)),
                            Text('Tap for credits & support', style: TextStyle(fontSize: 12, color: Colors.black45)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureBox(String image, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, height: 70, width: 70, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Constants.kMagenta)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}
