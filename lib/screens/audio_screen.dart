/// ----------------------------------------------------------------------
/// 📄 AudioScreen
///
/// 🧠 Purpose:
///   Displays the full audio player screen for a specific Surah.
///
/// 🔁 Navigated from:
///   - AudioListScreen (on Surah tap)
///
/// ✅ Requires:
///   - `surahNumber`: the index of the Surah to be played (1–114)
///
/// 📦 Uses:
///   - `AudioScreenBody` widget to build the UI
///
/// 📌 Note for other developers:
///   - Do NOT use this screen without passing a valid `surahNumber`.
/// ----------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../widgets/audio/audio_screen_body.dart';

class AudioScreen extends StatefulWidget {
  final int surahNumber;
  const AudioScreen({super.key, required this.surahNumber});

  @override
  State<AudioScreen> createState() => AudioScreenState();
}
