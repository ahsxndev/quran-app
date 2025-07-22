/// 📄 LicensesScreen
///
/// 🧠 Purpose:
///   This screen displays all licenses used in the app (including Flutter packages)
///   along with your custom MIT license.
///
/// 🔁 Navigated from:
///   - Settings or About page
///
/// 🛠 Features:
///   - Async loading of license data from `LicenseRegistry`
///   - Shimmer effect while loading
///   - ExpansionTiles for package-wise license viewing
///
/// 📦 Dependencies:
///   - `shimmer` package for loading effect
///
/// 👤 Author: Ahsan Zaman
/// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late final Future<List<_LicenseItem>> _licenses;

  @override
  void initState() {
    super.initState();
    _licenses = _loadLicenses();
  }

  /// 🔁 Loads license information, including your custom MIT license and all packages.
  Future<List<_LicenseItem>> _loadLicenses() async {
    final items = <_LicenseItem>[];
    final seen = <String>{}; // To avoid duplicate package entries

    // ✅ Add your custom app license
    items.add(const _LicenseItem(
      package: 'AlQuran – developed by Ahsan Zaman',
      body: '''
MIT Licence
Copyright © 2024 Ahsan Zaman
https://github.com/ahsxndev/quran-app

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''',
    ));

    // 🔄 Add all package licenses provided by Flutter
    try {
      await for (final l in LicenseRegistry.licenses) {
        for (final pkg in l.packages) {
          if (seen.add(pkg)) {
            final body = l.paragraphs.map((p) => p.text).join('\n');
            items.add(_LicenseItem(package: pkg, body: body));
          }
        }
      }
    } catch (_) {
      // Gracefully handle failure
    }

    return items;
  }

  /// 🔄 Shows shimmer loading placeholders
  Widget _shimmerList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  /// ℹ️ Displayed if no licenses are available
  Widget _empty() => const Center(
    child: Text('No licences available.',
        style: TextStyle(color: Colors.white70)),
  );

  /// 📋 Main list of licenses (including your MIT + packages)
  Widget _list(List<_LicenseItem> items) {
    if (items.isEmpty) return _empty();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];

        // 🏷️ Show your MIT license at the top
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SelectableText(
              item.body,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          );
        }

        // 📦 Show other package licenses in expandable cards
        return Card(
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          child: ExpansionTile(
            iconColor: Colors.white,
            title: Text(item.package,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SelectableText(
                  item.body,
                  style:
                  const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Licenses'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: FutureBuilder<List<_LicenseItem>>(
        future: _licenses,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _shimmerList();
          }
          return _list(snap.data ?? []);
        },
      ),
    );
  }
}

/// 📦 License data model
class _LicenseItem {
  final String package;
  final String body;
  const _LicenseItem({required this.package, required this.body});
}
