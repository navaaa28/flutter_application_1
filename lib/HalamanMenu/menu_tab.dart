import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanMenu/absensikeluar_page.dart';
import 'package:flutter_application_1/HalamanMenu/izincuti_page.dart';
import 'absensimasuk_page.dart';

class MenuTab extends StatelessWidget {
  final VoidCallback informasi;
  final String username;

  const MenuTab({
    super.key,
    required this.informasi,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': CupertinoIcons.check_mark_circled, 'label': 'Absen Masuk'},
      {'icon': CupertinoIcons.clear_circled, 'label': 'Absen Keluar'},
      {'icon': CupertinoIcons.doc_text, 'label': 'Lembur'},
      {'icon': CupertinoIcons.calendar_badge_minus, 'label': 'Izin / Cuti'},
      {'icon': CupertinoIcons.exclamationmark_triangle, 'label': 'Coming Soon'},
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 76, 178, 229),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('images/logo.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                      if (index == 0) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                AbsenMasukPage(username: username),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                AbsenKeluarPage(username: username),
                          ),
                        );
                      } else if (index == 2) {
                        // Navigasi ke halaman Lembur
                      } else if (index == 3) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                IzinCutiPage(),
                          ),
                        );
                      } else {
                        _showComingSoonDialog(context);
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
            ),
          ],
        ),
      ),
    );
  }

  void _showIzinCutiDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Pengajuan Izin / Cuti'),
          message: const Text('Isi formulir untuk mengajukan izin atau cuti.'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _showForm(context);
              },
              child: const Text('Isi Formulir'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context) {
    // Kode untuk form izin/cuti tidak diubah
  }

  void _showComingSoonDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Coming Soon'),
          content:
              const Text('Fitur ini akan tersedia dalam pembaruan mendatang.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
