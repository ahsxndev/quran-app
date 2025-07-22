/// ----------------------------------------------------------------------
/// 📄 Constants
///
/// 🧠 Purpose:
///   This file holds all globally shared values such as:
///   - Static colors for the theme
///   - Hijri and Gregorian date utilities
///   - Arabic numeral conversion
///   - Static lists like Para names
///
/// 👨‍💻 For Developers:
///   - Use this class to centralize and standardize visual and data formatting across screens.
///   - Use `Constants.kPrimary`, `Constants.toArabicNumbers()`, etc., instead of redefining.
///
/// 🔗 Dependencies:
///   - intl
///   - hijri
///   - http
///   - shared_preferences
/// ----------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Used to represent selected translation display
enum TranslationOption { none, english, urdu, both }

class Constants {
  /// Index to track currently selected Juz
  static int juzIndex = 0;

  /// List of all 30 Para (Juz) names
  static final List<Map<String, String>> paraNames = [
    {'arabic': 'آلم', 'english': 'Alif-Lam-Meem'},
    {'arabic': 'سيقول', 'english': 'Sayaqool'},
    {'arabic': 'تلك الرسل', 'english': 'Tilka Rusul'},
    {'arabic': 'لن تنالوا', 'english': 'Lan Tanaalu'},
    {'arabic': 'والمحصنات', 'english': 'Wal Mohsanat'},
    {'arabic': 'لا يحب الله', 'english': 'La Yuhibbu Allah'},
    {'arabic': 'وإذا سمعوا', 'english': 'Wa Iza Samiu'},
    {'arabic': 'ولو أننا', 'english': 'Wa Lau Annana'},
    {'arabic': 'قال الملا', 'english': 'Qalal Malao'},
    {'arabic': 'واعلموا', 'english': 'Wa A’lamu'},
    {'arabic': 'يعتذرون', 'english': 'Yatazeroon'},
    {'arabic': 'وما من دابة', 'english': 'Wa Mamin Da’abah'},
    {'arabic': 'وما أبرئ نفسي', 'english': 'Wa Ma Ubarriu Nafsi'},
    {'arabic': 'ربما', 'english': 'Rubama'},
    {'arabic': 'سبحان الذي', 'english': 'Subhanallazi'},
    {'arabic': 'قال ألم', 'english': 'Qal Alam'},
    {'arabic': 'اقترب للناس', 'english': 'Aqtarib Linnaas'},
    {'arabic': 'قد أفلح', 'english': 'Qadd Aflaha'},
    {'arabic': 'وقال الذين', 'english': 'Wa Qalallazina'},
    {'arabic': 'أمن خلق', 'english': 'A’man Khalaq'},
    {'arabic': 'اتل ما أوحي', 'english': 'Utlu Ma Oohi'},
    {'arabic': 'ومن يقنت', 'english': 'Wa Manyaqnut'},
    {'arabic': 'ومالي', 'english': 'Wa Mali'},
    {'arabic': 'فمن أظلم', 'english': 'Faman Azlam'},
    {'arabic': 'إليه يرد', 'english': 'Elahe Yuraddu'},
    {'arabic': 'حم', 'english': 'Ha Meem'},
    {'arabic': 'قال فما خطبكم', 'english': 'Qala Fama Khatbukum'},
    {'arabic': 'قد سمع الله', 'english': 'Qad Sami Allah'},
    {'arabic': 'تبارك الذي', 'english': 'Tabarakallazi'},
    {'arabic': 'عم يتساءلون', 'english': 'Amma Yatasa’aloon'},
  ];

  /// Theme Colors (Primary and Gradient Shades)
  static const kPrimary = Color(0xFF8A51D1);
  static const kPurple = Color(0xFF4F0477);
  static const kMagenta = Color(0xFFB121BF);

  /// Swatch used in gradients and color schemes
  static const MaterialColor kSwatchColor = MaterialColor(
    0xff8A51D1,
    <int, Color>{
      50: Color(0xFFF8E5FA),
      100: Color(0xFFF0C7F5),
      200: Color(0xFFE7A8F0),
      300: Color(0xFFDB86E8),
      400: Color(0xFFD064E1),
      500: Color(0xFFB943D0),
      600: Color(0xFF9832B0),
      700: Color(0xFF762290),
      800: Color(0xFF581670),
      900: Color(0xFF4F0477),
    },
  );

  /// Current date instance
  static DateTime get now => DateTime.now();

  /// Gregorian weekday name (e.g., Monday)
  static String getWeekday() => DateFormat('EEEE').format(now);

  /// Gregorian day (1, 2, 3…)
  static String getDay() => DateFormat('d').format(now);

  /// Gregorian month and year (e.g., July 2025)
  static String getMonthYear() => DateFormat('MMMM y').format(now);

  /// Convert western digits to Arabic numerals (٠ - ٩)
  static String toArabicNumbers(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], eastern[i]);
    }
    return input;
  }

  /// 📅 Get accurate Hijri date in Arabic using Aladhan API (with fallback)
  static Future<String> getAccurateHijriDateArabic() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final cachedDate = prefs.getString('hijri_cached_date');
    final cachedHijri = prefs.getString('hijri_cached_value');

    // 🧠 Use cached value if today's date already fetched
    if (cachedDate == today && cachedHijri != null) {
      return cachedHijri;
    }

    try {
      final formatted = DateFormat('dd-MM-yyyy').format(now);
      final url = Uri.parse('https://api.aladhan.com/v1/gToH?date=$formatted');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final hijri = json['data']['hijri'];

        final day = toArabicNumbers(hijri['day']);
        final month = hijri['month']['ar'];
        final year = toArabicNumbers(hijri['year']);
        final formattedHijri = '$day $month $year هـ';

        // Cache for future loads
        await prefs.setString('hijri_cached_date', today);
        await prefs.setString('hijri_cached_value', formattedHijri);

        return formattedHijri;
      }
    } catch (e) {
      debugPrint('Hijri API failed: $e');
    }

    // 🆘 Fallback to local Hijri calculation
    HijriCalendar.setLocal("ar");
    final hijri = HijriCalendar.now();
    return toArabicNumbers('${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ');
  }

  /// 📐 Text Styles for Date Header Widgets (Used in Quran App Home)
  static const TextStyle hijriDateStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  static const TextStyle gregorianWeekdayStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    fontFamily: 'Poppins',
  );

  static const TextStyle gregorianDayStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  static const TextStyle gregorianMonthYearStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: 'Poppins',
  );
}
