import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaporanMasalahPage extends StatefulWidget {
  const LaporanMasalahPage({super.key});

  @override
  _LaporanMasalahPageState createState() => _LaporanMasalahPageState();
}

class _LaporanMasalahPageState extends State<LaporanMasalahPage> {
  final TextEditingController _masalahController = TextEditingController();

  void _kirimLaporan() async {
    final String laporanText = _masalahController.text;
    
    if (laporanText.isNotEmpty) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'danny.vatur@gmail.com', // Ganti dengan email tujuan
        queryParameters: {
          'subject': 'Laporan Masalah Aplikasi',
          'body': laporanText,
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Gagal Mengirim Email'),
            content: const Text('Pastikan Anda memiliki aplikasi email yang terpasang.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
      
      _masalahController.clear();
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Laporan Kosong'),
          content: const Text('Silakan tulis laporan sebelum mengirim.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Laporan Masalah'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsikan masalah yang Anda alami:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _masalahController,
                placeholder: 'Tuliskan laporan masalah di sini...',
                maxLines: 5,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _kirimLaporan,
                  child: const Text('Kirim Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
