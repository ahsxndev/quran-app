/// ---------------------------------------------------------------------------
/// 🌟 OnboardingScreen - Introductory walkthrough
///
/// 🧠 Purpose:
///   Introduces users to the key features of the Quran app through a
///   beautiful multi-page onboarding experience.
///
/// 📁 Assets Used:
///   - assets/images/quran.png
///   - assets/images/prayer.png
///   - assets/images/zakat.png
///
/// 📦 Dependencies:
///   - introduction_screen (for walkthrough functionality)
///   - constants.dart (for color and style constants)
///
/// 🧱 Structure:
///   - Gradient background
///   - IntroductionScreen with 3 pages
///   - Reusable builder functions for title, body, image, next & done buttons
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:quran_app/screens/main_screen.dart';
import '../constants/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  Widget build(BuildContext context) {
    // 📐 Capture screen width for responsive image sizing
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 🎨 Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Constants.kPurple,
              Constants.kPrimary,
              Constants.kMagenta,
              Constants.kSwatchColor[300]!,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),

        // 🚀 Introduction Pages
        child: IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: [
            // 📄 Page 1 - Quran
            _buildPage(
              title: "Read Quran",
              body: "Customize your reading view, explore translations, and listen to audio recitations.",
              imagePath: 'assets/images/quran.png',
              imageWidth: screenWidth * 0.7,
            ),

            // 📄 Page 2 - Prayer
            _buildPage(
              title: "Prayer Timings",
              body: "Accurate prayer times based on your location with a beautiful, clean layout.",
              imagePath: 'assets/images/prayer.png',
              imageWidth: screenWidth * 0.85,
            ),

            // 📄 Page 3 - Habits
            _buildPage(
              title: "Build Better Habits",
              body: "Incorporate Islamic practices into your daily life through reflection and consistency.",
              imagePath: 'assets/images/zakat.png',
              imageWidth: screenWidth * 0.9,
            ),
          ],

          // ⏭️ Navigation Buttons
          showNextButton: true,
          next: _buildNextButton(),
          done: _buildDoneButton(),

          // ✅ Done Action
          onDone: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },

          // 🔘 Dot Indicators
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(22.0, 10.0),
            activeColor: Colors.white,
            color: Colors.white38,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }

  /// 🧱 Reusable Page Builder
  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
    required double imageWidth,
  }) {
    return PageViewModel(
      titleWidget: Text(title, style: _titleTextStyle()),
      bodyWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(body, textAlign: TextAlign.center, style: _bodyTextStyle()),
      ),
      image: Image.asset(imagePath, width: imageWidth, fit: BoxFit.contain),
    );
  }

  /// ✏️ Title Text Style
  TextStyle _titleTextStyle() {
    return const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.2,
      shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
    );
  }

  /// 📝 Body Text Style
  TextStyle _bodyTextStyle() {
    return const TextStyle(
      fontSize: 16,
      height: 1.6,
      color: Colors.white70,
      fontFamily: 'Poppins',
    );
  }

  /// ⏭️ Next Button UI
  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.arrow_forward_ios, size: 20, color: Constants.kPrimary),
    );
  }

  /// ✅ Done Button UI
  Widget _buildDoneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        "Done",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Constants.kPrimary,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
