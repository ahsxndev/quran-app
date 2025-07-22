/// ---------------------------------------------------------------------------
/// 🧿 TasbeehScreen - Digital Tasbeeh Counter with Custom Zikr Support
///
/// 🧠 Purpose:
///   - Allows users to count Tasbeeh (Zikr) with haptic feedback
///   - Enables custom Zikr input, persistent selection, and history
///
/// 🚀 Key Features:
///   ✅ Predefined & Custom Zikr (Subhan Allah, Alhamdulillah, etc.)
///   ✅ Persistent counter & zikr state using `SharedPreferences`
///   ✅ Add/Delete custom Zikr dynamically
///   ✅ Beautiful UI with vibration feedback on increment
///   ✅ Confirmation dialogs for reset & delete
///
/// 📦 State Keys:
///   - `tasbeeh_count` – stores current counter
///   - `tasbeeh_zikr` – stores selected zikr
///   - `custom_zikr_list` – stores list of added custom zikr
///
/// 🧱 Structure:
///   - Dropdown for Zikr Selection (+ Custom Add/Delete)
///   - Display Box for Zikr and Counter
///   - Circular FAB-like tap button to increment
///   - Reset & delete operations with dialogs
///
/// 📦 Dependencies:
///   - `shared_preferences` – for local storage
///   - `vibration` – for haptic feedback
///   - `Constants` – centralized styling and color constants
///
/// 📌 Usage Flow:
///   - User selects zikr → taps to count → app vibrates
///   - Custom zikr can be added and stored
///   - State is retained across app restarts
///
/// 📎 Example Usage:
///   ```dart
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehScreen()));
///   ```
///
/// 🧑 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:quran_app/constants/constants.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _count = 0;
  String _selectedZikr = 'Subhan Allah';

  final String _countKey = 'tasbeeh_count';
  final String _zikrKey = 'tasbeeh_zikr';

  final List<String> _baseZikrList = [
    'None',
    'Subhan Allah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
  ];
  List<String> _customZikrList = [];
  List<String> get _zikrList => [..._baseZikrList, ..._customZikrList, 'Custom...'];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedZikr = prefs.getString(_zikrKey) ?? _baseZikrList.first;
    final customZikrs = prefs.getStringList('custom_zikr_list') ?? [];

    setState(() {
      _count = prefs.getInt(_countKey) ?? 0;
      _customZikrList = customZikrs.toSet().toList(); // Ensure uniqueness
      if (!_zikrList.contains(savedZikr)) {
        _customZikrList.add(savedZikr);
      }
      _selectedZikr = savedZikr;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
    await prefs.setString(_zikrKey, _selectedZikr);
    await prefs.setStringList('custom_zikr_list', _customZikrList);
  }

  void _increment() async {
    setState(() => _count++);
    _savePrefs();
    if (await Vibration.hasVibrator() ) {
      Vibration.vibrate(duration: 15);
    }
  }

  void _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Counter?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Constants.kPurple),
        ),
        content: const Text(
          'Are you sure you want to reset the Tasbeeh counter to 0?',
          style: TextStyle(fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.kPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _count = 0);
      _savePrefs();
    }
  }


  Future<String?> _showCustomZikrDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Custom Zikr',
          style: TextStyle(fontWeight: FontWeight.bold, color: Constants.kPurple),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Ya Rahman',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.kPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteZikrDialog(String zikr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Zikr?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text('Are you sure you want to delete "$zikr"?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _customZikrList.remove(zikr);
        if (_selectedZikr == zikr) {
          _selectedZikr = _baseZikrList.first;
          _count = 0;
        }
      });
      _savePrefs();
    }
  }


  void _handleZikrChange(String? value) async {
    if (value == null) return;
    if (value == 'Custom...') {
      final custom = await _showCustomZikrDialog();
      if (custom != null && custom.isNotEmpty && !_zikrList.contains(custom)) {
        setState(() {
          _customZikrList.add(custom);
          _selectedZikr = custom;
          _count = 0;
        });
        _savePrefs();
      }
    } else {
      setState(() {
        _selectedZikr = value;
        _count = 0;
      });
      _savePrefs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Constants.kPurple),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Tasbeeh Counter',
          style: TextStyle(fontWeight: FontWeight.bold, color: Constants.kPurple),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height - AppBar().preferredSize.height - 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Column(
              children: [
                /// 🕌 Dropdown Selector
                DropdownButtonFormField<String>(
                  value: _selectedZikr,
                  items: _zikrList.map((zikr) {
                    return DropdownMenuItem<String>(
                      value: zikr,
                      child: Text(
                        zikr,
                        style: TextStyle(
                          color: _customZikrList.contains(zikr) ? Constants.kMagenta : Colors.black87,
                          fontWeight: _selectedZikr == zikr ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _handleZikrChange,
                  decoration: InputDecoration(
                    labelText: 'Select Zikr',
                    labelStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  dropdownColor: Colors.white,
                ),


                /// 🗑 Delete current custom zikr
                if (_customZikrList.contains(_selectedZikr))
                  TextButton.icon(
                    onPressed: () => _deleteZikrDialog(_selectedZikr),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete Zikr', style: TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 24),

                /// 📦 Count Box
                Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(blurRadius: 3, spreadRadius: 1, offset: Offset(0, 1))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('$_count', style: const TextStyle(fontSize: 60,
                          color: Constants.kMagenta, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_selectedZikr != 'None')
                        Text('Zikr: $_selectedZikr',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Constants.kPurple)),
                      const SizedBox(height: 8),
                      const Text('Tap the button below to count your Tasbeeh',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                /// ➕ Main Tap Button
                GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Constants.kMagenta,
                      boxShadow: [BoxShadow(color: Color.fromRGBO(255, 0, 255, 0.3), blurRadius: 10, offset: const Offset(0, 6))],
                    ),
                    child: const Icon(Icons.add, size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                /// 🔁 Reset
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt, color: Constants.kPurple),
                  label: const Text('Reset', style: TextStyle(color: Constants.kPurple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
