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
  int selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    QuranScreen(),
    AudioListScreen(),
    PrayerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
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
        backgroundColor: Constants.kPrimary,
        activeColor: Colors.white,
        color: Color(0xB3FFFFFF),
        initialActiveIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

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
