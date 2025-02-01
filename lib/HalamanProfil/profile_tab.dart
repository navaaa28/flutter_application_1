import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_login.dart';
import 'package:flutter_application_1/HalamanProfil/hubungikami.dart';
import 'package:flutter_application_1/HalamanProfil/laporanmasalah.dart';
import 'package:flutter_application_1/HalamanProfil/pengaturan_privasi.dart';
import 'package:flutter_application_1/HalamanProfil/pusatbantuan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'gaji.dart';  // Import halaman gaji

class ProfileTab extends StatelessWidget {
  final String username;
  final String password;
  final VoidCallback informasi;

  const ProfileTab({
    super.key,
    required this.username,
    required this.password,
    required this.informasi,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Halaman Profil'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('images/logo.png'),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Pengaturan Akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.person_crop_circle),
                    title: const Text('Edit Profil'),
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          final TextEditingController nameController = TextEditingController(text: username);
                          final TextEditingController emailController = TextEditingController(text: password);
                          return CupertinoAlertDialog(
                            title: const Text('Edit Profil'),
                            content: Column(
                              children: [
                                const SizedBox(height: 10),
                                CupertinoTextField(
                                  controller: nameController,
                                  placeholder: 'Nama Baru',
                                ),
                                const SizedBox(height: 10),
                                CupertinoTextField(
                                  controller: emailController,
                                  placeholder: 'Email Baru',
                                ),
                                const SizedBox(height: 10),
                                CupertinoButton(
                                  child: const Text('Ganti Foto Profil'),
                                  onPressed: () {
                                    // Aksi untuk mengganti foto profil
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                child: const Text('Simpan'),
                                onPressed: () {
                                  // Simpan perubahan nama dan email

                                  // Validasi input jika perlu, lalu simpan
                                  Navigator.pop(context);
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Profil Diperbarui'),
                                      content: const Text('Perubahan profil Anda telah disimpan.'),
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
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.lock),
                    title: const Text('Ganti Kata Sandi'),
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          final TextEditingController passwordController = TextEditingController();
                          return CupertinoAlertDialog(
                            title: const Text('Ganti Kata Sandi'),
                            content: Column(
                              children: [
                                const SizedBox(height: 10),
                                CupertinoTextField(
                                  obscureText: true,
                                  placeholder: 'Kata Sandi Lama',
                                ),
                                CupertinoTextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  placeholder: 'Kata Sandi Baru',
                                ),
                              ],
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                child: const Text('Simpan'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Kata Sandi Diperbarui'),
                                      content: const Text('Kata sandi Anda telah berhasil diperbarui.'),
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
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.money_dollar),
                    title: const Text('Gaji'),
                    onTap: () {
                        // Navigasi ke halaman GajiPage
                        Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => GajiPage(
                            selectedSalary: 'Rp 5.000.000',
                            salaryDate: DateTime(2025, 12, 28), // Tanggal gaji diterima
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.eye),
                    title: const Text('Pengaturan Privasi'),
                    onTap: () {
                    Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const PengaturanPrivasiPage()),
                  );
                      // Aksi untuk mengatur privasi
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.bell),
                    title: const Text('Kelola Notifikasi'),
                    onTap: () {
                      // Aksi untuk mengelola notifikasi
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aktivitas Pengguna',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.clock),
                    title: const Text('Riwayat Aktivitas'),
                    onTap: () {
                      // Aksi untuk melihat riwayat aktivitas
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dukungan dan Bantuan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.question_circle),
                    title: const Text('Pusat Bantuan'),
                    onTap: () {
                      // Navigasi ke halaman PusatBantuanPage
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const PusatBantuanPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.phone),
                    title: const Text('Hubungi Kami'),
                    onTap: () {
                    Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const HubungiKamiPage()),
                  );// Aksi untuk menghubungi layanan pelanggan
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.exclamationmark_triangle),
                    title: const Text('Laporan Masalah/Bug'),
                    onTap: () {

                      Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const LaporanMasalahPage()),
                  );
                      // Aksi untuk melaporkan masalah atau bug
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lainnya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.paintbrush),
                    title: const Text('Tema/Tampilan'),
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          title: const Text('Pilih Tema'),
                          message: const Text('Silakan pilih tema yang diinginkan.'),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () {
                                // Aksi untuk mengatur tema gelap
                                Navigator.pop(context);
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Tema Gelap'),
                                    content: const Text('Tema gelap telah diaktifkan.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.moon_fill, color: Colors.black),
                                  const SizedBox(width: 8),
                                  const Text('Tema Gelap'),
                                ],
                              ),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                // Aksi untuk mengatur tema terang
                                Navigator.pop(context);
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Tema Terang'),
                                    content: const Text('Tema terang telah diaktifkan.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.sun_max_fill, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  const Text('Tema Terang'),
                                ],
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                                  'Batal',
                                  style: TextStyle(color: Colors.red),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.globe),
                    title: const Text('Bahasa'),
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          title: const Text('Pilih Bahasa'),
                          message: const Text('Silakan pilih bahasa aplikasi.'),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () {
                                // Aksi untuk mengatur bahasa ke Inggris
                                Navigator.pop(context);
                                // Set bahasa ke Inggris dan update UI
                                // Anda bisa menambahkan metode setState atau state management
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Bahasa Diubah'),
                                    content: const Text('Bahasa telah diatur ke Inggris.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                // Tambahkan logika untuk mengganti bahasa aplikasi ke Inggris
                              },
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.flag, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text('English'),
                                ],
                              ),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                // Aksi untuk mengatur bahasa ke Indonesia
                                Navigator.pop(context);
                                // Set bahasa ke Indonesia dan update UI
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Bahasa Diubah'),
                                    content: const Text('Bahasa telah diatur ke Indonesia.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                // Tambahkan logika untuk mengganti bahasa aplikasi ke Indonesia
                              },
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.flag_fill, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text('Bahasa Indonesia'),
                                ],
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                                  'Batal',
                                  style: TextStyle(color: Colors.red),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.delete),
                    title: const Text('Hapus Akun'),
                    onTap: () {
                      // Aksi untuk menghapus akun
                    },
                  ),
                  CupertinoListTile(
                      leading: const Icon(CupertinoIcons.square_arrow_right),
                      title: const Text('Keluar'),
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Keluar'),
                            content: const Text('Apakah Anda yakin ingin keluar?'),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.pop(context); // Tutup dialog tanpa melakukan apa-apa
                                },
                                child: const Text('Batal'),
                              ),
                              CupertinoDialogAction(
                                onPressed: () async {
                                  // Tutup dialog konfirmasi sebelum melakukan signOut
                                  Navigator.pop(context);

                                  try {
                                    // Tunggu hingga signOut selesai
                                    await Supabase.instance.client.auth.signOut();

                                    // Setelah keluar berhasil, navigasi ke halaman login
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => const HalamanLogin(username: ''),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      // Tangani error jika terjadi
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) => CupertinoAlertDialog(
                                          title: const Text('Error'),
                                          content: Text('Terjadi kesalahan: ${e.toString()}'),
                                          actions: [
                                            CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.pop(context); // Tutup dialog error
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Keluar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
