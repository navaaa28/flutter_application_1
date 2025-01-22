import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 


class HomeTab extends StatelessWidget {
  final String username;
  final List<String> attendanceLogs;
  final VoidCallback informasi;

  const HomeTab({
    required this.username,
    required this.attendanceLogs,
    required this.informasi,
  });

  void _showAnnouncementPopup(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: const [
              Icon(CupertinoIcons.speaker_2, size: 28),
              SizedBox(width: 8),
              Text('Pengumuman Hari Ini'),
            ],
          ),
          content: const Text(
            'Rapat evaluasi akan diadakan besok pukul 10:00 di ruang meeting.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Halaman Utama'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: SafeArea(
        child: Container(
                    color: const Color.fromARGB(255, 76, 178, 229).withOpacity(0.4),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome, $username!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: const Color.fromARGB(255, 200, 230, 255),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text('Pengumuman Atasan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        leading: const Icon(CupertinoIcons.speaker_2),
                        onTap: () => _showAnnouncementPopup(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...attendanceLogs.map((log) => Card(
                          color: const Color.fromARGB(255, 76, 178, 229).withOpacity(0.4),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              log,
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ),
                        )),
                    Card(
                      color: const Color.fromARGB(255, 200, 230, 255),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text('Kalender Kerja',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        leading: const Icon(CupertinoIcons.calendar_today),
                        onTap: () {},
                      ),
                    ),
                    Card(
                      color: const Color.fromARGB(255, 200, 230, 255),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text('Jadwal Absen Hari Ini',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Jam: 08:00 - 17:00'),
                        leading: const Icon(CupertinoIcons.calendar),
                        onTap: () {},
                      ),
                    ),
                    Card(
                      color: const Color.fromARGB(255, 200, 230, 255),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text('Informasi Lembur',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                            'Nama: John Doe, Jam Lembur: 18:00 - 20:00\nNama: Jane Smith, Jam Lembur: 19:00 - 21:00'),
                        leading: const Icon(CupertinoIcons.time),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
