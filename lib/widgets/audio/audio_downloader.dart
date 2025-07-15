import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioDownloader {
  static final Dio _dio = Dio();
  static const String _prefsKey = 'downloaded_surahs';

  static Future<String?> getDownloadPath(int surahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_$surahNumber.mp3';
  }

  static Future<bool> isDownloaded(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_prefsKey) ?? [];
    if (downloaded.contains(surahNumber.toString())) {
      final path = await getDownloadPath(surahNumber);
      return await File(path!).exists();
    }
    return false;
  }

  static Future<void> downloadSurah({
    required int surahNumber,
    required String url,
    required void Function(int received, int total) onProgress,
    required void Function(String path) onComplete,
    required void Function(String error) onError,
  }) async {
    try {
      final path = await getDownloadPath(surahNumber);
      if (path == null) throw Exception('Could not get download path');

      await _dio.download(
        url,
        path,
        onReceiveProgress: onProgress,
        deleteOnError: true,
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList(_prefsKey) ?? [];
      if (!downloaded.contains(surahNumber.toString())) {
        downloaded.add(surahNumber.toString());
        await prefs.setStringList(_prefsKey, downloaded);
      }

      onComplete(path);
    } catch (e) {
      onError(e.toString());
    }
  }

  static Future<void> deleteDownload(int surahNumber) async {
    try {
      final path = await getDownloadPath(surahNumber);
      if (path != null && await File(path).exists()) {
        await File(path).delete();
      }

      // Remove from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList(_prefsKey) ?? [];
      downloaded.remove(surahNumber.toString());
      await prefs.setStringList(_prefsKey, downloaded);
    } catch (e) {
      debugPrint('Error deleting download: $e');
    }
  }
}