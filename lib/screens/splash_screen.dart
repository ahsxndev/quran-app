import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quran_app/screens/main_screen.dart';
import 'package:quran_app/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool alreadyUsed = false;

  void getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    alreadyUsed = prefs.getBool("alreadyUsed")?? false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    Timer(
      Duration(seconds: 3),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return  alreadyUsed ? MainScreen() : OnboardingScreen();
        }),
      ),
    );

  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Text(Constants.appName, style: TextStyle(
                color: Colors.black,
                fontSize: 30
              ), ),
            ),
            Positioned(
                bottom: 0,
                top: 0,
                right: 0,
                child: Image.asset('assets/images/islamic.png'),
            )
          ],
        ),
      ),
    );
  }
}
