import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanProfil/PengaturanPrivasi/kelola_izin_aplikasi.dart';

class PengaturanPrivasiPage extends StatelessWidget {
  const PengaturanPrivasiPage({super.key});

  void _tampilkanKebijakanPrivasi(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const Text(
          'Kami menghormati privasi Anda dan menjaga data Anda dengan aman.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

void _kelolaIzinAplikasi(BuildContext context) {
  // Mengarahkan ke halaman KelolaIzinAplikasi
  Navigator.push(
    context,
    CupertinoPageRoute(builder: (context) => const KelolaIzinAplikasi()), // Ganti dengan halaman yang diinginkan
  );
}


  void _konfirmasiHapusAkun(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Hapus'),
            onPressed: () {
              Navigator.pop(context);
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Akun Dihapus'),
                  content: const Text('Akun Anda telah berhasil dihapus.'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pengaturan Privasi'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Privasi & Keamanan'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.doc_text, color: Colors.blue),
                  title: const Text('Kebijakan Privasi'),
                  onTap: () => _tampilkanKebijakanPrivasi(context),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.lock_shield, color: Colors.orange),
                  title: const Text('Kelola Izin Aplikasi'),
                  onTap: () => _kelolaIzinAplikasi(context),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.delete, color: Colors.red),
                  title: const Text('Hapus Akun'),
                  onTap: () => _konfirmasiHapusAkun(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
