import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuTab extends StatelessWidget {
  final Function(String) addAttendanceLog;
  final VoidCallback informasi;
  final String username;

  const MenuTab({
    super.key,
    required this.addAttendanceLog,
    required this.informasi,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': CupertinoIcons.check_mark_circled, 'label': 'Absen Masuk'},
      {'icon': CupertinoIcons.clear_circled, 'label': 'Absen Keluar'},
      {'icon': CupertinoIcons.doc_text, 'label': 'Lembur'},
      {'icon': CupertinoIcons.calendar_badge_minus, 'label': 'Izin / Cuti'}, // Menu baru
      {'icon': CupertinoIcons.exclamationmark_triangle, 'label': 'Coming Soon'}, // Item Coming Soon
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
            // Header Section
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
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Grid Menu Section
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
                      if (index < 4) { // Menu yang berfungsi
                        if (index < 3) {
                          // Log untuk Absen Masuk, Keluar, atau Lembur
                          final now = DateTime.now();
                          final formattedDate =
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
                          final log =
                              '${items[index]['label']} pada $formattedDate';
                          addAttendanceLog(log);
                        } else {
                          // Buka dialog untuk Izin / Cuti
                          _showIzinCutiDialog(context);
                        }
                      } else {
                        // Untuk Coming Soon, tidak ada aksi
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
    String reason = '';
    DateTime? selectedDate;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return CupertinoAlertDialog(
              title: const Text('Formulir Izin / Cuti'),
              content: Column(
                children: [
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'Alasan Izin / Cuti',
                    onChanged: (value) {
                      reason = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 250,
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.all(16),
                                  child: CupertinoButton(
                                    child: const Text('Selesai'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 180,
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    initialDateTime: DateTime.now(),
                                    onDateTimeChanged: (DateTime date) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                    if (reason.isNotEmpty && selectedDate != null) {
                      final formattedDate =
                          DateFormat('yyyy-MM-dd').format(selectedDate!);
                      final log =
                          'Izin / Cuti diajukan: $reason untuk tanggal $formattedDate';
                      addAttendanceLog(log);
                    }
                  },
                  child: const Text('Kirim'),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('Fitur ini akan tersedia dalam pembaruan mendatang by Dani FaturRochman.'),
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
