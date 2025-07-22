/// ---------------------------------------------------------------------------
/// 🎵 AudioControls - Quran Audio Playback UI Controller
///
/// 🧠 Purpose:
///   - Provides playback control buttons for Quran audio: play, pause,
///     next, previous, loop, download, and speed control.
///
/// 🔧 Constructor Parameters:
///   - `player`             → JustAudio `AudioPlayer` instance to stream state
///   - `onNext`             → Callback for skipping to the next track
///   - `onPrev`             → Callback for going to the previous track
///   - `onPlayPause`        → Toggles play/pause
///   - `onSpeedTap`         → Opens a speed selection menu
///   - `onLoopToggle`       → Toggles repeat/loop mode
///   - `onDownload`         → Initiates or manages audio download
///   - `loopIcon`           → Icon to show current loop state (e.g. `Icons.repeat_one`)
///   - `isDownloading`      → True if download is in progress
///   - `isDownloaded`       → True if audio has already been downloaded
///   - `downloadProgress`   → Current download progress in bytes
///   - `totalSize`          → Total audio size in bytes
///   - `speed`              → Current playback speed (e.g. 1.0, 1.25, 1.5)
///
/// 💡 Features:
///   - Displays CircularProgressIndicator when downloading
///   - Download icon toggles between `download` and `download_done`
///   - Speed button shows current speed with fine granularity
///   - StreamBuilder listens to `player.playerStateStream` to reflect
///     real-time play/pause icon updates
///
/// 📎 Typically used in:
///   - Quran audio player footer or bottom sheet
///
/// 📁 Related Files:
///   - `audio/audio_downloader.dart` for managing download states
///
/// 🧑 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../constants/constants.dart';

class AudioControls extends StatelessWidget {
  final AudioPlayer player;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onPlayPause;
  final VoidCallback onSpeedTap;
  final VoidCallback onLoopToggle;
  final VoidCallback onDownload;
  final IconData loopIcon;
  final bool isDownloading;
  final bool isDownloaded;
  final int? downloadProgress;
  final int? totalSize;
  final double speed;


  const AudioControls({
    super.key,
    required this.player,
    required this.onNext,
    required this.onPrev,
    required this.onPlayPause,
    required this.onSpeedTap,
    required this.onLoopToggle,
    required this.onDownload,
    required this.loopIcon,
    this.isDownloading = false,
    this.isDownloaded = false,
    this.downloadProgress,
    this.totalSize,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(loopIcon,
                  color: loopIcon == Icons.repeat ? Colors.grey : Constants.kMagenta),
              onPressed: onLoopToggle,
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: onPrev,
            ),
            IconButton(
              iconSize: 64,
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Constants.kPurple,
              ),
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: onNext,
            ),
            // Download button or progress indicator
            if (isDownloading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: totalSize != null && totalSize! > 0
                      ? downloadProgress! / totalSize!
                      : null,
                  strokeWidth: 2,
                  color: Constants.kPurple,
                ),
              )
            else
              IconButton(
                icon: Icon(
                  isDownloaded ? Icons.download_done : Icons.download,
                  color: isDownloaded ? Colors.green : Colors.black,
                ),
                onPressed: onDownload,
              ),
            // Speed control
            GestureDetector(
              onTap: onSpeedTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.speed, size: 18),
                    const SizedBox(width: 6),
                    Text(speed == 1.0 || speed == 1.5
                        ? "${speed.toStringAsFixed(1)}x"
                        : "${speed.toStringAsFixed(2)}x"),
                    const Icon(Icons.keyboard_arrow_up_rounded),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}