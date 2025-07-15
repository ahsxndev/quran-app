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
