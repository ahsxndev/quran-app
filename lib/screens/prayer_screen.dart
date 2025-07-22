/// ---------------------------------------------------------------------------
/// 🕌 PrayerScreen - Accurate Daily Salah Times
///
/// 🧠 Purpose:
///   Displays Islamic prayer timings dynamically using GPS or user-selected
///   cities. Also shows sunrise and midnight times with dynamic city search
///   (online/offline), shimmer loading, and current/next prayer info.
///
/// 📍 Features:
///   - Detects user’s location via GPS or manual city search
///   - Fetches prayer timings using `prayers_times` package
///   - Displays current and next prayer with time updates
///   - Offline and online city search (OpenStreetMap API)
///   - Custom time zone assignment for accurate salah times
///   - Shimmer loading placeholders while data loads
///   - Timezone and high-latitude rule handling
///
/// 📦 Dependencies:
///   - location, geocoding, shared_preferences
///   - connectivity_plus, http, shimmer
///   - prayers_times, timezone
///
/// 🧱 Structure:
///   - Header: Time, date, city, current & next prayer
///   - Search bar: Manual city selection with overlay suggestions
///   - Sun Info: Sunrise and Midnight widgets
///   - Prayer list: Custom tile UI for each prayer time
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------


import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as gps;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:prayers_times/prayers_times.dart';
import 'package:quran_app/widgets/prayer_custom_tile.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shimmer/shimmer.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});
  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  /* ---------- UI ---------- */
  late String _formattedTime, _formattedDate;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _loadingLocation = false;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  Timer? _clockTimer;



  /* ---------- Data ---------- */
  tz.Location? _currentLocation;
  final _offlineCities = const [
    'Makkah, Saudi Arabia',
    'Medinah, Saudi Arabia',
    'Lahore, Pakistan',
    'Karachi, Pakistan',
    'Islamabad, Pakistan',
    'London, UK',
    'New York, USA',
    'Istanbul, Turkey',
    'Dubai, UAE',
    'Kuwait City, Kuwait',
    'Doha, Qatar',
    'Muscat, Oman',
    'Manama, Bahrain',
    'Riyadh, Saudi Arabia',
    'Abu Dhabi, UAE',
    'Jakarta, Indonesia',
    'Kuala Lumpur, Malaysia',
    'Cairo, Egypt',
    'Cape Town, South Africa',
    'Nairobi, Kenya',
    'Lagos, Nigeria',
    'Khartoum, Sudan',
    'Beirut, Lebanon',
    'Amman, Jordan',
    'Tehran, Iran',
    'Baghdad, Iraq',
    'Damascus, Syria',
    'Bishkek, Kyrgyzstan',
    'Tashkent, Uzbekistan',
    'Astana, Kazakhstan',
    'Baku, Azerbaijan',
    'Tbilisi, Georgia',
    'Yerevan, Armenia',
    'Dushanbe, Tajikistan',
    'Ashgabat, Turkmenistan',
    'Male, Maldives',
    'Dhaka, Bangladesh',
    'New Delhi, India',
    'Mumbai, India',
    'Kolkata, India',
    'Hyderabad, India',
    'Chennai, India',
    'Bangalore, India',
    'Ahmedabad, India',
    'Pune, India',
  ];

  String _cityName = 'Unknown';
  String _currentPrayer = '';
  String _nextPrayer = '';
  String _nextPrayerTime = '';
  Map<String, String> _prayerTimes = {};


  Future<bool> _hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }



  /* ---------- Life-cycle ---------- */
  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    final now = DateTime.now();
    _formattedTime = DateFormat('hh:mm a').format(now);
    _formattedDate =
    '${DateFormat('EEEE').format(now)}, ${now.day} ${DateFormat('MMMM yyyy').format(now)}';

    _searchFocus.addListener(_onFocusChange);
    _initPrayerTimes();
    _startClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _searchFocus.removeListener(_onFocusChange);
    _searchFocus.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  /* ---------- Clock ---------- */
  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentLocation == null) return;
      final now = tz.TZDateTime.now(_currentLocation!);
      _setDateTime(now);
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }


  void _setDateTime(tz.TZDateTime localNow) {
    if (!mounted) return;
    setState(() {
      _formattedTime = DateFormat('hh:mm a').format(localNow);
      _formattedDate =
      '${DateFormat('EEEE').format(localNow)}, ${localNow.day} ${DateFormat('MMMM yyyy').format(localNow)}';
    });
  }

  /* ---------- Location init ---------- */
  Future<void> _initPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    if (lat == null || lng == null) {
      await _fetchFromGps();
      return;
    }
    final city = prefs.getString('city') ?? _offlineCities.first;
    await _fetchPrayerTimes(lat, lng, city);
  }

  /* ---------- Overlay ---------- */
  void _onFocusChange() =>
      _searchFocus.hasFocus ? _showOverlay() : _removeOverlay();

  void _showOverlay() {
    _removeOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = Overlay.of(context);

      _overlayEntry = OverlayEntry(
        builder: (_) => Positioned(
          width: MediaQuery.of(context).size.width - 32,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 52),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              child: SizedBox(height: 300, child: _buildSuggestionList()),
            ),
          ),
        ),
      );
      overlay.insert(_overlayEntry!);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /* ---------- Search list ---------- */
  Widget _buildSuggestionList() {
    final q = _searchController.text.trim();

    return FutureBuilder<List<String>>(
      future: q.length < 2
          ? Future.value([])
          : _hasInternet().then((hasNet) {
        if (hasNet) {
          return _fetchOnline(q);
        } else {
          // Show snackbar for no internet
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackbar('No internet connection', isError: true);
          });
          throw 'no-internet';
        }
      }),
      builder: (ctx, snap) {
        final children = <Widget>[
          ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Use current location'),
            onTap: () {
              _searchFocus.unfocus();
              _fetchFromGps();
            },
          ),
          ..._buildOffline(q),
        ];

        if (snap.connectionState == ConnectionState.waiting) {
          children.add(_shimmerSearchLoader());
        } else if (snap.hasError) {
          if (snap.error.toString().contains('no-internet')) {
            children.add(
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No internet connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }
        } else if (snap.hasData && snap.data!.isEmpty && q.length >= 2) {
          children.add(
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No suggestions found',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        } else if (snap.hasData) {
          children.addAll(
            snap.data!.map(
                  (c) => ListTile(
                leading: const Icon(Icons.public, color: Colors.blue),
                title: Text(c),
                onTap: () {
                  _searchFocus.unfocus();
                  _onCitySelect(c);
                },
              ),
            ),
          );
        }

        return ListView(padding: EdgeInsets.zero, children: children);
      },
    );
  }


  Widget _shimmerSearchLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
              (index) => ListTile(
            leading: const Icon(Icons.location_city, color: Colors.grey),
            title: Container(
              height: 14,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOffline(String q) => _offlineCities
      .where((c) => c.toLowerCase().contains(q.toLowerCase()))
      .map((c) => ListTile(
    leading: Icon(Icons.location_city,
        color: Theme.of(context).hintColor),
    title: Text(c),
    onTap: () {
      _searchFocus.unfocus();
      _onCitySelect(c);
    },
  ))
      .toList();

  Future<List<String>> _fetchOnline(String q) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': q,
      'format': 'json',
      'limit': '5',
    });
    try {
      final resp = await http.get(uri, headers: {'User-Agent': 'PrayerApp'});
      if (resp.statusCode != 200) return [];
      final list = json.decode(resp.body) as List;
      return list
          .map((e) =>
          (e['display_name'] as String).split(', ').take(3).join(', '))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /* ---------- City / GPS selection ---------- */
  Future<void> _onCitySelect(String city) async {
    _removeOverlay();
    _searchController.clear();
    _searchFocus.unfocus();

    try {
      final loc = await geo.locationFromAddress(city);
      final lat = loc.first.latitude;
      final lng = loc.first.longitude;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', lat);
      await prefs.setDouble('lng', lng);
      await prefs.setString('city', city);

      await _fetchPrayerTimes(lat, lng, city);

      _showSnackbar('Location set to $city');
    } catch (e) {
      debugPrint('City select error: $e');
      _showSnackbar('Failed to find location', isError: true);
    }
  }


  Future<void> _fetchFromGps() async {
    if (!mounted) return;
    setState(() => _loadingLocation = true);
    try {
      final location = gps.Location();
      if (!(await location.serviceEnabled())) {
        if (!(await location.requestService())) throw 'GPS not enabled';
      }
      final status = await location.hasPermission();
      if (status == gps.PermissionStatus.denied) {
        final newStatus = await location.requestPermission();
        if (newStatus != gps.PermissionStatus.granted) throw 'Permission denied';
      }

      final loc = await location.getLocation();
      final placemarks =
      await geo.placemarkFromCoordinates(loc.latitude!, loc.longitude!);
      final city =
          '${placemarks.first.locality ?? 'Unknown'}, ${placemarks.first.country ?? ''}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', loc.latitude!);
      await prefs.setDouble('lng', loc.longitude!);
      await prefs.setString('city', city);

      await _fetchPrayerTimes(loc.latitude!, loc.longitude!, city);

      _showSnackbar('Location set to $city');
    } catch (e) {
      debugPrint('GPS error: $e');
      await _fetchPrayerTimes(31.5497, 74.3436, 'Lahore, Pakistan');
      _showSnackbar('Failed to get location, using Lahore as fallback', isError: true);
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }


  String? _mapToValidPrayerName(String prayerId) {
    final lower = prayerId.toLowerCase();

    if (lower.contains('fajr')) return 'fajr';
    if (lower.contains('dhuhr')) return 'dhuhr';
    if (lower.contains('asr')) return 'asr';
    if (lower.contains('maghrib')) return 'maghrib';
    if (lower.contains('isha')) return 'isha';
    if (lower.contains('sunrise')) return 'sunrise';

    return null; // fallback for 'none' or unknowns
  }


  Future<void> _fetchPrayerTimes(
      double lat, double lng, String city) async {
    try {
      final tzName = _getTimezoneFromCoordinates(lat, lng);
      final location = tz.getLocation(tzName);
      _currentLocation = location;

      final now = tz.TZDateTime.now(location);
      final params = _calculationParametersFor(lat, lng);

      final pt = PrayerTimes(
        coordinates: Coordinates(lat, lng),
        calculationParameters: params,
        locationName: tzName,
        dateTime: now,
      );

      final cp = pt.currentPrayer();
      final np = pt.nextPrayer();
      final sun = SunnahInsights(pt);
      final mappedPrayer = _mapToValidPrayerName(np);
      final nt = mappedPrayer != null ? pt.timeForPrayer(mappedPrayer) : null;


      if (!mounted) return;
      setState(() {
        _prayerTimes = {
          'Fajr': DateFormat.jm().format(pt.fajrStartTime!),
          'Dhuhr': DateFormat.jm().format(pt.dhuhrStartTime!),
          'Asr': DateFormat.jm().format(pt.asrStartTime!),
          'Maghrib': DateFormat.jm().format(pt.maghribStartTime!),
          'Isha': DateFormat.jm().format(pt.ishaStartTime!),
          'Sunrise': DateFormat.jm().format(pt.sunrise!),
          'Midnight': DateFormat.jm().format(sun.middleOfTheNight),
        };
        _cityName = city;
        _currentPrayer = _resolvePrayer(cp);
        _nextPrayer = _resolvePrayer(np);
        _nextPrayerTime = nt != null ? DateFormat.jm().format(nt) : '--';

        _setDateTime(now);
      });
    } catch (e) {
      debugPrint('Prayer calc error: $e');
      final fallback = tz.getLocation('Asia/Karachi');
      _currentLocation = fallback;
      if (mounted) _setDateTime(tz.TZDateTime.now(fallback));
    }
  }

  /* ---------- Utilities ---------- */
  String _getTimezoneFromCoordinates(double lat, double lng) {
    // Basic timezone detection based on longitude
    if (lng >= 67.0 && lng <= 77.0 && lat >= 23.0 && lat <= 37.0) {
      return 'Asia/Karachi'; // Pakistan
    } else if (lng >= -10.0 && lng <= 2.0 && lat >= 50.0 && lat <= 60.0) {
      return 'Europe/London'; // UK
    } else if (lng >= -80.0 && lng <= -70.0 && lat >= 40.0 && lat <= 45.0) {
      return 'America/New_York'; // New York
    } else if (lng >= 28.0 && lng <= 32.0 && lat >= 40.0 && lat <= 42.0) {
      return 'Europe/Istanbul'; // Turkey
    } else if (lng >= -130.0 && lng <= -60.0) {
      // Americas
      if (lat >= 25.0) return 'America/New_York';
      return 'America/Mexico_City';
    } else if (lng >= -10.0 && lng <= 40.0) {
      // Europe/Africa
      if (lat >= 35.0) return 'Europe/London';
      return 'Africa/Cairo';
    } else if (lng >= 40.0 && lng <= 180.0) {
      // Asia/Pacific
      if (lat >= 35.0) return 'Asia/Tokyo';
      if (lat >= 20.0) return 'Asia/Shanghai';
      return 'Asia/Karachi';
    }

    return 'UTC'; // Default fallback
  }

  PrayerCalculationParameters _calculationParametersFor(double lat, double lng) {
    late PrayerCalculationParameters params;
    if (lng >= -11 && lng <= 3 && lat >= 49 && lat <= 60) {
      params = PrayerCalculationMethod.moonsightingCommittee();
    } else if (lng >= -140 && lng <= -50 && lat >= 20 && lat <= 60) {
      params = PrayerCalculationMethod.northAmerica();
    } else if (lng >= -10 && lng <= 40 && lat >= 35 && lat <= 60) {
      params = PrayerCalculationMethod.muslimWorldLeague();
    } else {
      params = PrayerCalculationMethod.karachi();
    }
    if (_needsHighLatitudeFix(lat)) {
      params.highLatitudeRule = HighLatitudeRule.middleOfTheNight;
    }
    return params;
  }

  bool _needsHighLatitudeFix(double lat) => lat.abs() > 48;

  String _resolvePrayer(String p) {
    switch (p.toLowerCase()) {
      case 'none':
        return '--';
      case 'isha':
      case 'ishaafter':
      case 'ishabefore':
      case 'ishastart':
        return 'Isha';
      case 'fajr':
      case 'fajrafter':
      case 'fajrbefore':
      case 'fajrstart':
        return 'Fajr';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Maghrib';
      case 'sunrise':
        return 'Sunrise';
      default:
        return p;
    }
  }

  /* ---------- Build ---------- */
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_searchFocus.hasFocus) {
                _searchFocus.unfocus();
                _removeOverlay();
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/prayer_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 8),
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSearchBar(Theme.of(context)),
                    const SizedBox(height: 8),
                    _buildSunRow(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: _prayerTimes.isEmpty
                            ? _shimmerList()
                            : _buildPrayerList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Prayer Times',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        Text(
          _formattedTime,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formattedDate,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          _cityName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        if (_loadingLocation)
          const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        const SizedBox(height: 8),
        if (_currentPrayer.isNotEmpty)
          Column(
            children: [
              Text(
                'Current: $_currentPrayer',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'Next: $_nextPrayer at $_nextPrayerTime',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (_) => _showOverlay(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search city…',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            filled: true,
            fillColor: Color(0x26FFFFFF),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSunRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoChip('Sunrise', _prayerTimes['Sunrise'] ?? '--'),
          _infoChip('Midnight', _prayerTimes['Midnight'] ?? '--'),
        ],
      ),
    );
  }

  Widget _infoChip(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPrayerList() {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: prayers.length,
      itemBuilder: (_, i) => PrayerCustomTile(
        prayerName: prayers[i],
        prayerTiming: _prayerTimes[prayers[i]] ?? '--',
      ),
    );
  }

  Widget _shimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 5,
        itemBuilder: (_, __) => ListTile(
          title: Container(height: 16, width: 100, color: Colors.white),
          subtitle: Container(height: 12, width: 60, color: Colors.white),
        ),
      ),
    );
  }

}