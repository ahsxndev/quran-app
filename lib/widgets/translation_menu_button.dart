/// ---------------------------------------------------------------------------
/// 🌐 TranslationMenuButton - Dropdown Menu for Selecting Quran Translation
///
/// 🧠 Purpose:
///   - Provides a language selector (None, English, Urdu, Both) using
///     a styled `PopupMenuButton`.
///
/// 💡 Features:
///   - Highlights the selected option in purple
///   - Rounded corners and subtle background for visual consistency
///   - Customizable via `onSelected` callback
///
/// 🔧 Parameters:
///   - `selectedOption`  → The currently selected translation option
///   - `onSelected`      → Callback when a new option is selected
///
/// 🎨 Styling:
///   - Uses `Constants.kPurple` for selected state
///   - Light semi-transparent background
///
/// 📎 Example:
///   ```dart
///   TranslationMenuButton(
///     selectedOption: TranslationOption.english,
///     onSelected: (opt) => setState(() => selectedOption = opt),
///   )
///   ```
///
/// 📁 Typically used in:
///   - `SurahDetailScreen` AppBar actions
///
/// 🧑 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TranslationMenuButton extends StatelessWidget {
  final TranslationOption selectedOption;
  final ValueChanged<TranslationOption> onSelected;

  const TranslationMenuButton({
    super.key,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x144F0477),
        borderRadius: BorderRadius.circular(10),
      ),
      child: PopupMenuButton<TranslationOption>(
        initialValue: selectedOption,
        icon: const Icon(Icons.language, color: Constants.kPurple),
        onSelected: onSelected,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x224F0477)),
        ),
        itemBuilder: (_) => [
          _buildOption("No Translation", TranslationOption.none),
          _buildOption("English Only", TranslationOption.english),
          _buildOption("Urdu Only", TranslationOption.urdu),
          _buildOption("English & Urdu", TranslationOption.both),
        ],
      ),
    );
  }

  PopupMenuItem<TranslationOption> _buildOption(String text, TranslationOption value) {
    return PopupMenuItem(
      value: value,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: selectedOption == value ? Constants.kPurple : Colors.black87,
        ),
      ),
    );
  }
}
