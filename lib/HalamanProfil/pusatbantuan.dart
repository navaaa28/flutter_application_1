import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:
            const Text('Pusat Bantuan', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pusat Bantuan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Di bawah ini adalah beberapa panduan yang mungkin membantu Anda.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              _buildHelpItem(
                context: context, // Teruskan context ke sini
                icon: CupertinoIcons.question_circle,
                title: 'Bagaimana cara mengubah profil saya?',
                content:
                    'Untuk mengubah profil Anda, masuk ke pengaturan akun dan pilih "Edit Profil".',
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                context: context, // Teruskan context ke sini
                icon: CupertinoIcons.lock,
                title: 'Bagaimana cara mengubah kata sandi saya?',
                content:
                    'Untuk mengubah kata sandi, masuk ke pengaturan akun dan pilih "Ganti Kata Sandi".',
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                context: context, // Teruskan context ke sini
                icon: CupertinoIcons.exclamationmark_triangle,
                title: 'Apa yang harus saya lakukan jika ada masalah?',
                content:
                    'Jika Anda menghadapi masalah, Anda bisa menghubungi kami melalui halaman "Hubungi Kami".',
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                context: context, // Teruskan context ke sini
                icon: CupertinoIcons.arrow_3_trianglepath,
                title: 'Bagaimana cara menghubungi dukungan?',
                content:
                    'Untuk menghubungi dukungan, silakan kunjungi halaman "Hubungi Kami" dan pilih metode yang sesuai.',
              ),
              const SizedBox(height: 10),
              _buildHelpItem(
                context: context, // Teruskan context ke sini
                icon: CupertinoIcons.info_circle,
                title: 'Tentang Aplikasi',
                content:
                    'Aplikasi ini dikembangkan untuk membantu Anda mengelola akun dan pengaturan dengan mudah.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required BuildContext context, // Tambahkan parameter context
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          showCupertinoDialog(
            context: context, // Gunakan context yang diteruskan
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Panduan'),
              content: Text(content),
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
    );
  }
}
