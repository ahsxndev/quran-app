/// ---------------------------------------------------------------------------
/// 📖 Quran Audio Player - Stateful Widget Logic (AudioScreenState)
///
/// 🧠 Overview:
///   This widget manages playback of Quran Surahs using the `just_audio`
///   and `quran` packages, with full support for:
///     ✅ Online streaming with retry & timeout logic
///     ✅ Offline downloads with Dio and path_provider
///     ✅ Looping (off, repeat one, auto-next)
///     ✅ Playback speed control
///     ✅ Shimmer buffering effects
///     ✅ Download state management with shared_preferences
///     ✅ Connectivity checks with connectivity_plus
///
/// 📦 Key Components:
///   - `_audioPlayer`          → JustAudio player instance
///   - `_downloadProgress`     → Track Dio download state
///   - `_audioUrl`             → Local or remote source URL
///   - `_quranLoopMode`        → Enum to control loop behavior
///   - `_currentSurah`         → Surah currently loaded for playback
///   - `_hasConnection`        → Tracks live internet connection
///   - `_error`                → Displays user-facing error messages
///
/// 🛠 Features:
///   - ✅ **Dynamic audio source handling**: Loads from local or online
///   - ✅ **Persistent download info**: Uses shared_preferences
///   - ✅ **Retry logic**: Up to 4 attempts on audio load failure
///   - ✅ **Connectivity-aware**: Auto-handles playback based on network
///   - ✅ **Playback speed control**: Modal bottom sheet selector
///   - ✅ **Shimmer progress bar**: When buffering
///   - ✅ **Offline-friendly**: Fully functional without network if downloaded
///
/// 🎧 Audio Modes:
///   - `QuranLoopMode.off`: No loop
///   - `QuranLoopMode.repeatOne`: Loop same Surah
///   - `QuranLoopMode.autoNext`: Auto-play next Surah
///
/// 🎯 Extensible:
///   You can plug in additional features like:
///   - Bookmarks per verse
///   - Progress sync with cloud
///   - Custom audio download queues
///
/// 🔌 Dependencies:
///   - `just_audio`, `just_audio_background`
///   - `quran`, `dio`, `shared_preferences`
///   - `connectivity_plus`, `path_provider`, `shimmer`
///
/// 📝 Related Widgets:
///   - `AudioControls`
///   - `AudioNextSurahs`
///   - `AudioDownloader`
///   - `AudioShimmer`
///
/// 🔁 Retry Logic:
/// ```dart
/// while (!loaded && retryCount < maxRetries && mounted) {
///   try {
///     await _audioPlayer.setAudioSource(...);
///     loaded = true;
///   } catch (e) {
///     retryCount++;
///     await Future.delayed(Duration(seconds: 2 * (1 << retryCount)));
///   }
/// }
/// ```
///
/// 📋 Example Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => const AudioScreen(surahNumber: 36),
///   ),
/// );
/// ```
///
/// ---------------------------------------------------------------------------


import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/constants/constants.dart';
import 'package:quran_app/widgets/audio/audio_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import '../../screens/audio_screen.dart';
import 'audio_controls.dart';
import 'audio_downloader.dart';
import 'audio_next_surahs.dart';

enum QuranLoopMode { off, repeatOne, autoNext }

int _currentSurah = 0;
QuranLoopMode _quranLoopMode = QuranLoopMode.off;

class AudioScreenState extends State<AudioScreen> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _shimmerController;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isDownloaded = false;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  int _totalSize = 0;

  bool _hasConnection = true;
  String? _error;
  String? _audioUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surahNumber;
    _audioPlayer = AudioPlayer();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // Initialize player state subscription
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_quranLoopMode == QuranLoopMode.repeatOne) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else if (_quranLoopMode == QuranLoopMode.autoNext) {
          _playNextSurah();
        }
      }
    });

    // Initialize connectivity subscription
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        final hasConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet);
        if (!hasConnection && _hasConnection && _audioUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("No internet connection. Playback may continue if buffered."),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: "Retry",
                onPressed: () async {
                  final newResults = await Connectivity().checkConnectivity();
                  if (newResults.any((result) =>
                  result == ConnectivityResult.wifi ||
                      result == ConnectivityResult.mobile ||
                      result == ConnectivityResult.ethernet)) {
                    setState(() {
                      _hasConnection = true;
                      _error = null;
                    });
                    if (_audioUrl == null) {
                      _loadSurahAudio(_currentSurah);
                    }
                  }
                },
              ),
            ),
          );
        }
        setState(() {
          _hasConnection = hasConnection;
        });
      }
    });

    // Load surah after checking download status first
    _initializeSurah();
  }

  Future<void> _initializeSurah() async {
    // First check if surah is downloaded
    final isDownloaded = await AudioDownloader.isDownloaded(_currentSurah);
    if (isDownloaded && mounted) {
      setState(() {
        _isDownloaded = true;
      });
    }

    // Then proceed with normal load
    _loadSurahAudio(_currentSurah);
  }

  Future<void> _loadSurahAudio(int surah) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _audioUrl = null;
      _error = null;
    });

    // First try to load from local storage
    if (_isDownloaded) {
      final path = await AudioDownloader.getDownloadPath(surah);
      if (path != null && await File(path).exists()) {
        try {
          await _audioPlayer.stop();
          await _audioPlayer.setAudioSource(
            AudioSource.uri(
              Uri.file(path),
              tag: MediaItem(
                id: 'surah_$surah',
                album: 'Al Quran',
                title: quran.getSurahName(surah),
                artist: 'Quran Recitation',
                artUri: Uri.parse('https://example.com/album_art.jpg'), // Replace with actual URL or local asset
              ),
            ),
          );

          if (mounted) {
            setState(() {
              _currentSurah = surah;
              _audioUrl = path;
              _error = null;
              _hasConnection = true;
              _isLoading = false;
            });
          }
          await _audioPlayer.play();
          return;
        } catch (e) {
          debugPrint('Error playing local file: $e');
          // Fall through to online loading
        }
      }
    }

    // Only check internet if we don't have a downloaded file
    final connectivityResults = await Connectivity().checkConnectivity();
    if (!connectivityResults.any((result) =>
    result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet)) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
          _error = "No internet connection and no offline copy available.";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await _loadAudioWithRetries(surah);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is TimeoutException
              ? "Loading timed out for Surah ${quran.getSurahName(surah)}."
              : e.toString().contains("Empty audio URL")
              ? "Audio not available for Surah ${quran.getSurahName(surah)}."
              : "Failed to load audio for Surah ${quran.getSurahName(surah)}.";
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: "Retry",
              onPressed: () => _loadSurahAudio(_currentSurah),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadAudioWithRetries(int surah) async {
    // Check for downloaded file first
    final isDownloaded = await AudioDownloader.isDownloaded(surah);
    final path = await AudioDownloader.getDownloadPath(surah);

    if (isDownloaded && path != null && await File(path).exists()) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.file(path),
            tag: MediaItem(
              id: 'surah_$surah',
              album: 'Al Quran',
              title: quran.getSurahName(surah),
              artist: 'Quran Recitation',
              artUri: Uri.parse('https://example.com/album_art.jpg'), // Replace with actual URL or local asset
            ),
          ),
        );

        if (mounted) {
          setState(() {
            _currentSurah = surah;
            _audioUrl = path;
            _error = null;
            _hasConnection = true; // Still mark as connected
            _isLoading = false;
            _isDownloaded = true;
          });
        }
        await _audioPlayer.play();
        return;
      } catch (e) {
        debugPrint('Error playing local file: $e');
        // Fall through to online loading
      }
    }

    // Original online loading code...
    final url = quran.getAudioURLBySurah(surah);
    debugPrint("Audio URL for Surah $surah: $url");

    if (url.isEmpty) {
      throw Exception("Empty audio URL for Surah $surah");
    }

    await _audioPlayer.stop();

    bool loaded = false;
    int retryCount = 0;
    const maxRetries = 4;
    while (!loaded && retryCount < maxRetries && mounted) {
      try {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(
              id: 'surah_$_currentSurah',
              album: 'Al Quran',
              title: quran.getSurahName(_currentSurah),
              artist: 'Quran Recitation',
              artUri: Uri.parse('https://example.com/album_art.jpg'), // Replace with actual URL or local asset
            ),
          ),
          preload: true,
        ).timeout(const Duration(seconds: 8), onTimeout: () {
          throw Exception("Audio source loading timed out");
        });
        loaded = true;
      } catch (e) {
        debugPrint("Retry $retryCount failed for Surah $_currentSurah: $e");
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception("Failed after $maxRetries retries for Surah $_currentSurah");
        }
        await Future.delayed(Duration(seconds: 2 * (1 << retryCount)));
      }
    }

    if (loaded && mounted) {
      setState(() {
        _currentSurah = surah;
        _audioUrl = url;
        _error = null;
        _hasConnection = true;
        _isLoading = false;
        _isDownloaded = false; // Not downloaded yet
      });
      await _audioPlayer.play();
    }
  }

  void _playNextSurah() async {
    if (!mounted) return;
    final nextSurah = _currentSurah % 114 + 1;
    await _audioPlayer.stop();
    await _loadSurahAudio(nextSurah);
  }

  void _playPreviousSurah() async {
    if (!mounted) return;
    final previousSurah = _currentSurah == 1 ? 114 : _currentSurah - 1;
    await _audioPlayer.stop();
    await _loadSurahAudio(previousSurah);
  }

  void _togglePlay() async {
    if (_audioPlayer.playerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  IconData _getLoopIcon() {
    switch (_quranLoopMode) {
      case QuranLoopMode.off:
        return Icons.repeat;
      case QuranLoopMode.repeatOne:
        return Icons.repeat_one;
      case QuranLoopMode.autoNext:
        return Icons.playlist_play;
    }
  }

  void _toggleLoopMode() {
    if (mounted) {
      setState(() {
        _quranLoopMode = QuranLoopMode.values[(_quranLoopMode.index + 1) % QuranLoopMode.values.length];
      });
    }
  }

  Future<void> _handleDownload() async {
    if (_isDownloaded) {
      await _confirmDelete();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Download Surah',
          style: TextStyle(fontWeight: FontWeight.bold, color: Constants.kPurple),
        ),
        content: const Text(
          'Do you want to download this Surah for offline playback?',
          style: TextStyle(fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.kPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _downloadCurrentSurah();
    }
  }

  Future<void> _downloadCurrentSurah() async {
    if (_audioUrl == null || _isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _totalSize = 0;
    });

    await AudioDownloader.downloadSurah(
      surahNumber: _currentSurah,
      url: _audioUrl!,
      onProgress: (received, total) {
        if (mounted) {
          setState(() {
            _downloadProgress = received;
            _totalSize = total;
          });
        }
      },
      onComplete: (path) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download completed!')),
          );
          setState(() {
            _isDownloading = false;
            _isDownloaded = true;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $error')),
          );
          setState(() {
            _isDownloading = false;
          });
        }
      },
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Download',
          style: TextStyle(fontWeight: FontWeight.bold, color: Constants.kPurple),
        ),
        content: const Text(
          'Are you sure you want to delete the downloaded Surah?',
          style: TextStyle(fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AudioDownloader.deleteDownload(_currentSurah);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download deleted')),
        );
        setState(() {
          _isDownloaded = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final surahName = quran.getSurahName(_currentSurah);

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4F0477), size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _error != null && !_isDownloaded
          ? _buildError()
          : (!_hasConnection && _audioUrl == null && !_isDownloaded)
          ? _buildNoConnection()
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isLoading || _audioUrl == null
            ? AudioShimmer()
            : _buildPlayerUI(surahName),
      ),
    );
  }


  Widget _buildNoConnection() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, color: Colors.grey, size: 48),
        const SizedBox(height: 16),
        const Text(
          "No internet connection.\nPlease check your network and try again.",
          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (mounted) {
              setState(() {
                _error = null;
                _audioUrl = null;
                _isLoading = true;
              });
              _loadSurahAudio(_currentSurah);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F0477),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Retry",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(
          _error ?? "An unknown error occurred.",
          style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _error = null;
                    _audioUrl = null;
                    _isLoading = true;
                  });
                  _loadSurahAudio(_currentSurah);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F0477),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Retry",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _playNextSurah,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Skip",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildShimmerBuffer(Duration position, Duration duration) {
    final total = duration.inSeconds > 0 ? duration.inSeconds : 1;
    final current = position.inSeconds.clamp(0, total).toDouble();

    return Stack(
      children: [
        ProgressBar(
          progress: Duration(seconds: current.toInt()),
          buffered: Duration.zero,
          total: duration,
          onSeek: (newPosition) => _audioPlayer.seek(newPosition),
          baseBarColor: Colors.grey.shade300,
          bufferedBarColor: Colors.transparent,
          progressBarColor: const Color(0xFF4F0477),
          thumbColor: const Color(0xFF4F0477),
          timeLabelTextStyle: const TextStyle(color: Colors.black),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;
              final progressRatio = current / total;
              double shimmerStart = fullWidth * progressRatio;
              if (progressRatio < 0.25) {
                shimmerStart += 11.3;
              } else if (progressRatio >= 0.25 && progressRatio < 0.50) {
                shimmerStart += 9.5;
              } else if (progressRatio >= 0.50 && progressRatio < 0.75) {
                shimmerStart += 7.5;
              } else {
                shimmerStart += 5.5;
              }

              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: shimmerStart),
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Colors.white70,
                      direction: ShimmerDirection.ltr,
                      period: const Duration(seconds: 2),
                      child: Container(
                        height: 6,
                        width: fullWidth,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            'assets/images/background_img.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showSpeedSelector() {
    final speeds = [0.75, 1.0, 1.25, 1.5, 1.75];
    final currentSpeed = _audioPlayer.speed;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Playback Speed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F0477)),
              ),
              const SizedBox(height: 12),
              for (var speed in speeds)
                ListTile(
                  leading: Icon(
                    currentSpeed == speed ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: currentSpeed == speed ? const Color(0xFF4F0477) : Colors.grey,
                  ),
                  title: Text(
                    speed == 1.0 || speed == 1.5
                        ? "${speed.toStringAsFixed(1)}x"
                        : "${speed.toStringAsFixed(2)}x",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: currentSpeed == speed ? FontWeight.bold : FontWeight.normal,
                      color: currentSpeed == speed ? const Color(0xFF4F0477) : Colors.black,
                    ),
                  ),
                  onTap: () {
                    _audioPlayer.setSpeed(speed);
                    if (mounted) {
                      setState(() {});
                    }
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildPlayerUI(String surahName) {
    final totalAyahs = quran.getVerseCount(_currentSurah);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildImage(),
          const SizedBox(height: 24),
          Text(surahName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Total Verses: $totalAyahs', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),

          /// Progress Bar
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, posSnapshot) {
              final position = posSnapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration ?? Duration.zero;

              return StreamBuilder<Duration>(
                stream: _isDownloaded ? null : _audioPlayer.bufferedPositionStream,
                builder: (context, bufSnapshot) {
                  final buffered = _isDownloaded ? duration : (bufSnapshot.data ?? Duration.zero);
                  final isBuffering = !_isDownloaded && buffered <= position;

                  return isBuffering
                      ? _buildShimmerBuffer(position, duration)
                      : ProgressBar(
                    progress: position,
                    buffered: buffered,
                    total: duration,
                    onSeek: (newPosition) => _audioPlayer.seek(newPosition),
                    baseBarColor: Colors.grey.shade300,
                    bufferedBarColor: _isDownloaded ? Colors.green : Constants.kMagenta,
                    progressBarColor: Constants.kPurple,
                    thumbColor: Constants.kPurple,
                    timeLabelTextStyle: const TextStyle(color: Colors.black),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),

          /// Controls
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder<bool>(
              future: AudioDownloader.isDownloaded(_currentSurah),
              builder: (context, snapshot) {

                return AudioControls(
                  player: _audioPlayer,
                  onNext: _playNextSurah,
                  onPrev: _playPreviousSurah,
                  onPlayPause: _togglePlay,
                  onSpeedTap: _showSpeedSelector,
                  onLoopToggle: _toggleLoopMode,
                  onDownload: _handleDownload,
                  loopIcon: _getLoopIcon(),
                  isDownloading: _isDownloading,
                  isDownloaded: _isDownloaded,
                  downloadProgress: _downloadProgress,
                  totalSize: _totalSize,
                  speed:  _audioPlayer.speed,
                );
              },
            ),
          ),


          const Divider(thickness: 1, height: 40),
          const Text("Next Surahs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          AudioNextSurahs(
            currentSurah: _currentSurah,
            onSelect: (nextSurah) {
              _audioPlayer.stop();
              _loadSurahAudio(nextSurah);
            },
          ),

        ],
      ),
    );
  }
}
