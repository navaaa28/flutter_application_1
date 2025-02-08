import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'daftar_laporan_page.dart'; // Import halaman DaftarLaporanPage

class LaporanMasalahPage extends StatefulWidget {
  const LaporanMasalahPage({super.key});

  @override
  _LaporanMasalahPageState createState() => _LaporanMasalahPageState();
}

class _LaporanMasalahPageState extends State<LaporanMasalahPage> {
  final TextEditingController _masalahController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  void _kirimLaporan() async {
    final String laporanText = _masalahController.text;

    if (laporanText.isNotEmpty) {
      try {
        // Ambil data pengguna yang sedang login
        final user = _supabase.auth.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda belum login!')),
          );
          return;
        }

        // Ambil display_name dari tabel profiles (atau auth.users jika sudah ada)
        final response = await _supabase
            .from('users')
            .select('display_name')
            .eq('id', user.id)
            .single();

        final displayName = response['display_name'] ?? 'Anonymous';

        // Simpan laporan ke Supabase
        await _supabase.from('laporan_masalah').insert([
          {
            'user_id': user.id,
            'display_name': displayName, // Simpan display_name
            'deskripsi': laporanText,
            'created_at': DateTime.now().toIso8601String(),
          }
        ]);

        // Kirim email (opsional)
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: 'danny.vatur@gmail.com',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dikirim dan disimpan!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan laporan: $e')),
        );
      }
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Laporan Masalah', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DaftarLaporanPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsikan masalah yang Anda alami:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CupertinoTextField(
                    controller: _masalahController,
                    placeholder: 'Tuliskan laporan masalah di sini...',
                    maxLines: 5,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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