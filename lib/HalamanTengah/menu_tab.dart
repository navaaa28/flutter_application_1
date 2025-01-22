import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuTab extends StatelessWidget {
  final Function(String) addAttendanceLog;
  final VoidCallback informasi;

  const MenuTab({
    super.key,
    required this.addAttendanceLog,
    required this.informasi,
  });

  @override
  Widget build(BuildContext context) {
    // Menghapus item menu "Pengaturan"
    final items = [
      {'icon': CupertinoIcons.check_mark_circled, 'label': 'Absen Masuk'},
      {'icon': CupertinoIcons.clear_circled, 'label': 'Absen Keluar'},
      {'icon': CupertinoIcons.doc_text, 'label': 'Lembur'},
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Halaman Menu'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index < 2) {
                final now = DateTime.now();
                final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
                final log = '${items[index]['label']} pada $formattedDate';
                addAttendanceLog(log);
              }
            },
            child: Card(
              color: CupertinoColors.lightBackgroundGray,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[index]['icon'] as IconData, size: 50),
                  const SizedBox(height: 8),
                  Text(
                    items[index]['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
