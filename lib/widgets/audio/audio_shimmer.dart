/// ---------------------------------------------------------------------------
/// 🎶 AudioShimmer Widget
///
/// 📘 Purpose:
///   Provides a shimmering placeholder UI while audio data is being loaded
///   in the Quran Audio Player (`AudioScreen`). It enhances user experience
///   by displaying a visual loading state for:
///     - Surah cover image
///     - Surah title
///     - Verse count
///     - Audio progress bar
///     - Playback control buttons
///     - Next surah list
///
/// 🛠 Implementation:
///   - Uses the `shimmer` package to animate placeholders
///   - Placeholder layout closely mimics the actual player UI
///   - Dynamically adapts to screen width with responsive design
///
/// 📦 Dependencies:
///   - `shimmer: ^3.0.0` (or latest compatible)
///
/// 🔍 Usage:
/// ```dart
/// isLoading
///   ? const AudioShimmer()
///   : ActualAudioPlayerUI(),
/// ```
///
/// 🧩 Components:
///   - Image placeholder: 260px height container with rounded corners
///   - Title/verse count: Rectangular shimmer boxes
///   - Progress bar: Wide horizontal shimmer
///   - Controls: 5 circular shimmer buttons (larger center button)
///   - Next Surahs: 3 horizontal shimmer tiles
///
/// 🌈 Shimmer Colors:
///   - Base: `Colors.grey.shade300`
///   - Highlight: `Colors.white`
///
/// 🔁 Improvements (Optional):
///   - Accept optional layout configuration via constructor
///   - Animate shimmer direction or speed based on app theme
///
/// ---------------------------------------------------------------------------



import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AudioShimmer extends StatelessWidget {
  const AudioShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 📷 Surah Image Placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 📛 Surah Name Placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 📜 Verse Count Placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 📊 Progress Bar Placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 🎛️ Control Buttons Placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.white,
                  child: CircleAvatar(
                    radius: index == 2 ? 32 : 20,
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 40),
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Next Surahs",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          // 📚 Next Surah Tiles Placeholder
          Column(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.white,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
