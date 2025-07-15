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
    return Scaffold(
      backgroundColor: Colors.white,
      body: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
            titleWidget: Text(
              "Read Quran",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Constants.kPrimary,
              ),
            ),
            bodyWidget: Column(
              children: const [
                SizedBox(height: 16),
                Text(
                  "Customize your reading view, read in multiple languages, and listen to different audio recitations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
            image: Image.asset(
              'assets/images/quran.png',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Prayer Alerts",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Constants.kPrimary,
              ),
            ),
            bodyWidget: Column(
              children: const [
                SizedBox(height: 16),
                Text(
                  "Choose your adhan, select which prayer to be notified for, and control how often alerts repeat.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
            image: Image.asset(
              'assets/images/prayer.png',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Build Better Habits",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Constants.kPrimary,
              ),
            ),
            bodyWidget: Column(
              children: const [
                SizedBox(height: 16),
                Text(
                  "Make Islamic practices a part of your daily routine in a way that best suits your lifestyle.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
            image: Image.asset(
              'assets/images/zakat.png',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
          ),
        ],
        showNextButton: true,
        next: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Constants.kPrimary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.white,
          ),
        ),
        done: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Constants.kPrimary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Done",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        onDone: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(22.0, 10.0),
          activeColor: Constants.kPrimary,
          color: Colors.grey.shade300,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
