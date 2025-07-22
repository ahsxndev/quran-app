/// ---------------------------------------------------------------------------
/// 🧭 MainScreen
///
/// 🧠 Purpose:
///   Acts as the root layout with a Convex Bottom Navigation Bar
///   to switch between key screens: Home, Quran, Audio, and Prayer.
///
/// 📦 Dependencies:
///   - convex_bottom_bar: Stylish, animated bottom navigation bar
///
/// 🧱 Contains:
///   - HomeScreen
///   - QuranScreen
///   - AudioListScreen
///   - PrayerScreen
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:quran_app/constants/constants.dart';
import 'package:quran_app/screens/audio_list_screen.dart';
import 'package:quran_app/screens/home_screen.dart';
import 'package:quran_app/screens/prayer_screen.dart';
import 'package:quran_app/screens/quran_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// 🚩 Currently selected index of the bottom nav
  int selectedIndex = 0;

  /// 📋 List of screens navigated by bottom bar
  final List<Widget> _screens = const [
    HomeScreen(),
    QuranScreen(),
    AudioListScreen(),
    PrayerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🧱 Active screen displayed based on nav index
      body: _screens[selectedIndex],

      // 🔻 Bottom Navigation Bar using ConvexAppBar
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: Constants.kPrimary,
        activeColor: Colors.white,
        color: const Color(0xB3FFFFFF),
        initialActiveIndex: selectedIndex,

        items: [
          TabItem(
            icon: _buildNavIcon('assets/images/home.png'),
            title: 'Home',
          ),
          TabItem(
            icon: _buildNavIcon('assets/images/holyQuran.png'),
            title: 'Quran',
          ),
          TabItem(
            icon: _buildNavIcon('assets/images/audio.png'),
            title: 'Audio',
          ),
          TabItem(
            icon: _buildNavIcon('assets/images/mosque.png'),
            title: 'Prayer',
          ),
        ],

        // 🟢 On tap, update selected index
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  /// 🖼️ Builds custom icon from asset with unified size and color
  Widget _buildNavIcon(String assetPath) {
    return SizedBox(
      height: 28,
      width: 28,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        color: Colors.white,
      ),
    );
  }
}
