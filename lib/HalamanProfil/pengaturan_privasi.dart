import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanProfil/PengaturanPrivasi/kelola_izin_aplikasi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      CupertinoPageRoute(
        builder: (context) => const KelolaIzinAplikasi(),
      ),
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
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog konfirmasi
              await _hapusAkun(context); // Panggil fungsi hapus akun
            },
          ),
        ],
      ),
    );
  }

  Future<void> _hapusAkun(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Dapatkan ID pengguna yang sedang login
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Pengguna tidak ditemukan');
      }

      // 2. Hapus akun dari sistem autentikasi Supabase
      await supabase.auth.admin.deleteUser(userId);

      // 3. Hapus data pengguna dari tabel `users`
      await supabase.from('users').delete().eq('id', userId);

      // 4. Tampilkan pesan sukses
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Akun Dihapus'),
          content: const Text('Akun Anda telah berhasil dihapus.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
            ),
          ],
        ),
      );
    } catch (e) {
      // 5. Tampilkan pesan error jika terjadi kesalahan
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Gagal Menghapus Akun'),
          content: Text('Terjadi kesalahan: ${e.toString()}'),
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