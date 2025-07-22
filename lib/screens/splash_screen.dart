/// ---------------------------------------------------------------------------
/// 🕋 SplashScreen - Intro & Transition Screen with Branding Animations
///
/// 🧠 Purpose:
///   - Acts as the app’s initial entry point
///   - Shows branding, animated logo, and prepares user state
///   - Navigates user to either Onboarding or MainScreen
///
/// 🚀 Key Features:
///   ✅ Animated logo scaling and shimmer title effect
///   ✅ Fades and shimmering effects on text for elegance
///   ✅ Checks if the user has previously opened the app (`alreadyUsed`)
///   ✅ Uses shared_preferences for persistent app entry state
///   ✅ Custom Islamic geometric pattern drawn in background
///
/// 🧱 Structure:
///   - `SplashScreen` (Stateful)
///     - Animation Controllers: `_fadeController`, `_scaleController`, `_shimmerController`
///     - Animations: `_fadeAnimation`, `_scaleAnimation`, `_shimmerAnimation`
///     - Timer: navigates after 3 seconds based on shared pref
///     - `IslamicPatternPainter`: Draws faint geometric patterns
///
/// 📦 Dependencies:
///   - `shared_preferences` for persistent user session check
///   - `dart:math` for custom geometry painting
///   - `Constants` for themed gradients and colors
///
/// 🖼 Assets Required:
///   - `assets/images/al-quran.png`
///   - `assets/images/islamic.png` (optional decorative)
///
/// 🧑 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------


import 'dart:async';
import 'dart:math' as math;
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool alreadyUsed = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  void getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    alreadyUsed = prefs.getBool("alreadyUsed") ?? false;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _shimmerController.repeat();

    getData();

    Timer(
      const Duration(seconds: 3),
          () => Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          alreadyUsed ? const MainScreen() : const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Constants.kPurple, // Dark purple from constants
              Constants.kPrimary, // Primary purple from constants
              Constants.kMagenta, // Magenta from constants
              Constants.kSwatchColor[300]!, // Lighter shade from swatch
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: IslamicPatternPainter(),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo with animation
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(0x26), // 15% opacity
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: Colors.white.withAlpha(0x4D), // 30% opacity
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(0x4D), // 30% opacity
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Center(
                            child: Image.asset(
                            'assets/images/al-quran.png',
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),

                        ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    // App title with shimmer effect
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: const [
                                      Colors.white70,
                                      Colors.white,
                                      Colors.white70,
                                    ],
                                    stops: [
                                      0.0,
                                      0.5 + _shimmerAnimation.value * 0.3,
                                      1.0,
                                    ],
                                  ).createShader(bounds);
                                },
                                child:  Text(
                                  'Al-Quran',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2.5,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 4),
                                        blurRadius: 10,
                                        color: Colors.black38,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Subtitle
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value * 0.8,
                          child: const Text(
                            'القرآن الكريم',
                            style: TextStyle(
                              fontFamily: 'Uthmanic',
                              fontSize: 28,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Elegant loading text without spinner
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value * 0.7,
                          child: Text(
                            'Preparing your spiritual journey...',
                            style: TextStyle(
                              color: Colors.white.withAlpha(0xA0), // 60% opacity
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Decorative Islamic pattern (optional)
              Positioned(
                bottom: 0,
                top: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value * 0.2,
                      child: Transform.scale(
                        scale: 1.2, // Enlarged scale
                        child: Image.asset('assets/images/islamic.png',
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                                                ),
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for Islamic geometric patterns
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(0x14) // 8% opacity
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double spacing = 80.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        // Draw octagon
        drawOctagon(canvas, paint, Offset(x, y), 25);
      }
    }
  }

  void drawOctagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    const int sides = 8;
    const double angle = 2 * math.pi / sides;

    for (int i = 0; i < sides; i++) {
      final currentAngle = i * angle - math.pi / 2;
      final x = center.dx + radius * math.cos(currentAngle);
      final y = center.dy + radius * math.sin(currentAngle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}