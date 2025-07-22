/// ---------------------------------------------------------------------------
/// 🌟 NamesScreen - Asma Ul Husna
///
/// 🧠 Purpose:
///   Displays the 99 Names of Allah with their Arabic name, transliteration,
///   and English meaning loaded from local JSON.
///
/// 📁 Asset Used:
///   - assets/json/asmaul_husna.json
///
/// 📦 Dependencies:
///   - constants.dart for styling constants
///
/// 🧱 Structure:
///   - AppBar with title
///   - GridView with styled cards for each Name
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quran_app/constants/constants.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  /// 📦 Holds decoded 99 Names list
  List<dynamic> names = [];

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  /// 📥 Loads JSON data from assets
  Future<void> _loadNames() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/json/asmaul_husna.json');
      final List<dynamic> jsonData = json.decode(jsonStr);
      setState(() => names = jsonData);
    } catch (e) {
      debugPrint('Error loading Asma ul Husna: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔺 App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Constants.kPurple),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          '99 Names of Allah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.kPurple,
          ),
        ),
      ),

      // 🔽 Body
      body: names.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: names.length,
        itemBuilder: (_, i) {
          final item = names[i];
          return _buildNameCard(i + 1, item);
        },
      ),
    );
  }

  /// 🧱 Single Name Card Builder
  Widget _buildNameCard(int number, dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 🔘 Top-right Number Badge
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Constants.kMagenta,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // 📃 Name Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // 🕌 Arabic Name
                Flexible(
                  child: Text(
                    item['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Uthmanic',
                      fontWeight: FontWeight.w600,
                      color: Constants.kMagenta,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // 🔤 Transliteration
                Flexible(
                  child: Text(
                    item['transliteration'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Constants.kPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // 💬 English Meaning
                Flexible(
                  child: Text(
                    item['meaning'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.visible,
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
