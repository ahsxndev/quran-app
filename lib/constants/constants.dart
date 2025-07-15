import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

enum TranslationOption { none, english, urdu, both }


class Constants {
  static const String appName = 'Al-Quran';

  static int juzIndex = 0;


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

  static const kPrimary = Color(0xff8a51d1);
  static const kPurple = Color(0xFF4F0477);
  static const kMagenta = Color(0xFFB121BF);

  static const MaterialColor kSwatchColor =
      MaterialColor(0xff8A51D1, <int, Color>{
        50: Color(0xff9662d6),
        100: Color(0xffa174da),
        200: Color(0xffad85df),
        300: Color(0xffb997e3),
        400: Color(0xffcfa8e8),
        500: Color(0xffd0b9ed),
        600: Color(0xffdccbf1),
        700: Color(0xffe8dcf6),
        800: Color(0xfff3eefa),
        900: Color(0xffffffff),
      });

  static DateTime get now => DateTime.now();

  // Formatted Gregorian Date Parts
  static String getWeekday() => DateFormat('EEEE').format(now); // e.g. Monday
  static String getDay() => DateFormat('d').format(now); // e.g. 7
  static String getMonthYear() => DateFormat('MMMM y').format(now);

  // Convert Western digits to Arabic numerals
  static String toArabicNumbers(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], eastern[i]);
    }
    return input;
  }

  // Get Arabic Hijri Date
  static String getFormattedHijriDateArabic() {
    HijriCalendar.setLocal("ar");
    final hijri = HijriCalendar.now();
    return toArabicNumbers(
      '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ',
    );
  }

  // Label Style (e.g., "Hijri Date")
  static const hijriLabelStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );

  // Hijri Date Style (large)
  static const TextStyle hijriDateStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  // Gregorian Date Style (slightly larger, bold)
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
