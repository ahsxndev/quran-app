import 'package:flutter/material.dart';
import 'package:quran_app/constants/constants.dart';

import 'audio/audio_downloader.dart';

class QuranCustomTile extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final String arabicName;
  final VoidCallback onTap;

  final bool showIcon; // For showing play/pause icon
  final bool isPlaying;
  final bool showSubtitle;
  final bool isSurahTile; // To distinguish between surah and para tiles
  final bool? isDownloaded; // Optional: if null, will check automatically
  final bool showDownloadedIcon;

  const QuranCustomTile({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.arabicName,
    required this.onTap,
    this.showIcon = false,
    this.isPlaying = false,
    this.showSubtitle = true,
    this.isSurahTile = true,
    this.isDownloaded,
    this.showDownloadedIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isDownloaded != null
          ? Future.value(isDownloaded)
          : isSurahTile
          ? AudioDownloader.isDownloaded(number)
          : Future.value(false),
      builder: (context, snapshot) {
        final downloaded = snapshot.data ?? false;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: [
                // Star number icon
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/star.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constants.kPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (showSubtitle)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),

                // Arabic name
                Text(
                  arabicName,
                  style: const TextStyle(
                    fontFamily: 'Uthmanic',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Constants.kMagenta,
                  ),
                ),

                if (downloaded && isSurahTile && showDownloadedIcon) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.download_done,
                    color: Colors.green,
                    size: 20,
                  ),
                ],


                if (showIcon) ...[
                  const SizedBox(width: 12),
                  Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Constants.kPurple,
                    size: 28,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}