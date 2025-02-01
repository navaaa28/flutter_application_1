import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Pusat Bantuan'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pusat Bantuan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Di bawah ini adalah beberapa panduan yang mungkin membantu Anda.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.question_circle),
              title: const Text('Bagaimana cara mengubah profil saya?'),
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Panduan'),
                    content: const Text(
                        'Untuk mengubah profil Anda, masuk ke pengaturan akun dan pilih "Edit Profil".'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.lock),
              title: const Text('Bagaimana cara mengubah kata sandi saya?'),
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Panduan'),
                    content: const Text(
                        'Untuk mengubah kata sandi, masuk ke pengaturan akun dan pilih "Ganti Kata Sandi".'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.exclamationmark_triangle),
              title: const Text('Apa yang harus saya lakukan jika ada masalah?'),
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Panduan'),
                    content: const Text(
                        'Jika Anda menghadapi masalah, Anda bisa menghubungi kami melalui halaman "Hubungi Kami".'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.arrow_3_trianglepath),
              title: const Text('Bagaimana cara menghubungi dukungan?'),
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Panduan'),
                    content: const Text(
                        'Untuk menghubungi dukungan, silakan kunjungi halaman "Hubungi Kami" dan pilih metode yang sesuai.'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.info_circle),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Tentang Aplikasi'),
                    content: const Text(
                        'Aplikasi ini dikembangkan untuk membantu Anda mengelola akun dan pengaturan dengan mudah.'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
