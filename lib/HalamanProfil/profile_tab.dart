import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_login.dart';
import 'package:flutter_application_1/HalamanHome/activity_page.dart';
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.purple.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('images/logo.png'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
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
                      _buildListTile(
                        icon: CupertinoIcons.person_crop_circle,
                        title: 'Edit Profil',
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
                      _buildListTile(
                        icon: CupertinoIcons.lock,
                        title: 'Ganti Kata Sandi',
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
                      _buildListTile(
                        icon: CupertinoIcons.money_dollar,
                        title: 'Gaji',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => GajiPage(
                                selectedSalary: 'Rp 5.000.000',
                                salaryDate: DateTime(2025, 12, 28),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: CupertinoIcons.eye,
                        title: 'Pengaturan Privasi',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const PengaturanPrivasiPage()),
                          );
                        },
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: CupertinoIcons.bell,
                        title: 'Kelola Notifikasi',
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
                      _buildListTile(
                        icon: CupertinoIcons.clock,
                        title: 'Riwayat Aktivitas',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ActivityPage(),
                            ),
                          );
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
                      _buildListTile(
                        icon: CupertinoIcons.question_circle,
                        title: 'Pusat Bantuan',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const PusatBantuanPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: CupertinoIcons.phone,
                        title: 'Hubungi Kami',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const HubungiKamiPage()),
                          );
                        },
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        title: 'Laporan Masalah/Bug',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const LaporanMasalahPage()),
                          );
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
                      _buildListTile(
                        icon: CupertinoIcons.paintbrush,
                        title: 'Tema/Tampilan',
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                              title: const Text('Pilih Tema'),
                              message: const Text('Silakan pilih tema yang diinginkan.'),
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () {
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
                      _buildListTile(
                        icon: CupertinoIcons.globe,
                        title: 'Bahasa',
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                              title: const Text('Pilih Bahasa'),
                              message: const Text('Silakan pilih bahasa aplikasi.'),
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context);
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
                                    Navigator.pop(context);
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
                      _buildListTile(
                        icon: CupertinoIcons.square_arrow_right,
                        title: 'Keluar',
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Keluar'),
                              content: const Text('Apakah Anda yakin ingin keluar?'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Batal'),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await Supabase.instance.client.auth.signOut();
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
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) => CupertinoAlertDialog(
                                            title: const Text('Error'),
                                            content: Text('Terjadi kesalahan: ${e.toString()}'),
                                            actions: [
                                              CupertinoDialogAction(
                                                onPressed: () {
                                                  Navigator.pop(context);
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}