import 'package:flutter/material.dart';
import '../widgets/audio/audio_screen_body.dart';

class AudioScreen extends StatefulWidget {
  final int surahNumber;
  const AudioScreen({super.key, required this.surahNumber});

  @override
  State<AudioScreen> createState() => AudioScreenState();
}
