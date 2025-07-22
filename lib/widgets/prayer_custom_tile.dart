/// ---------------------------------------------------------------------------
/// 🕌 PrayerCustomTile - A reusable widget for displaying a single prayer time
///
/// 🧠 Purpose:
///   - Presents prayer name and its timing in a stylized row
///   - Can be reused in daily prayer timetable or reminders
///
/// 🎨 Design:
///   - Magenta-colored text for both name and time
///   - Bottom magenta line as a separator
///   - Responsive padding and clean typography
///
/// 🔧 Parameters:
///   - `prayerName`   → Name of the prayer (e.g., Fajr, Maghrib)
///   - `prayerTiming` → Corresponding prayer time (default: "-")
///
/// 🧱 Structure:
///   - Row: prayerName (left) and prayerTiming (right)
///   - Colored divider below the row
///
/// 📎 Example:
///   ```dart
///   PrayerCustomTile(
///     prayerName: 'Fajr',
///     prayerTiming: '04:30 AM',
///   )
///   ```
///
/// 🧑 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:quran_app/constants/constants.dart';

class PrayerCustomTile extends StatelessWidget {

  final String prayerName;
  final String prayerTiming;

  const PrayerCustomTile({
    super.key,
    required this.prayerName,
    this.prayerTiming = '-'
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Tile Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayerName,
                style: const TextStyle(
                  color: Constants.kMagenta,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                prayerTiming,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: Constants.kMagenta,

                ),
              ),
            ],
          ),
        ),

        // 🔹 Bottom Colored Line
        Container(
          height: 2,
          width: double.infinity,
          color: Constants.kMagenta,
        ),
        SizedBox(
          height: 7,
        )
      ],
    );
  }
}
