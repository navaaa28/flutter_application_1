import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_login.dart';
import 'package:flutter_application_1/HalamanHome/activity_page.dart';
import 'package:flutter_application_1/HalamanProfil/PengaturanPrivasi/kelola_notifikasi.dart';
import 'package:flutter_application_1/HalamanProfil/hubungikami.dart';
import 'package:flutter_application_1/HalamanProfil/laporanmasalah.dart';
import 'package:flutter_application_1/HalamanProfil/pengaturan_privasi.dart';
import 'package:flutter_application_1/HalamanProfil/pusatbantuan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'gaji.dart'; // Import halaman gaji

class ProfileTab extends StatefulWidget {
  final String username;
  final String password;
  final String departemen;
  final VoidCallback informasi;

  const ProfileTab({
    Key? key,
    required this.username,
    required this.password,
    required this.departemen,
    required this.informasi,
  }) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _image;
  File? _imageFile;
  String? _profileUrl;
  String _displayName = '';
  String _departemen = '';
  final ImagePicker _picker = ImagePicker();
  final Color _primaryColor = const Color(0xFF2A2D7C);
  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserName();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('users')
        .select('profile_url')
        .eq('id', user.id)
        .single();

    if (response != null && response['profile_url'] != null) {
      setState(() {
        _profileUrl = response['profile_url'];
      });
    }
  }

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('users')
        .select('display_name, departemen')
        .eq('id', user.id)
        .single();

    if (response != null && response['display_name'] != null) {
      setState(() {
        _displayName = response['display_name'];
        _departemen = response['departemen'];
      });
    }
  }

  void _showImageSourceSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Pilih Sumber Foto'),
        message: const Text(
            'Pilih apakah ingin mengambil foto dari kamera atau galeri.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Ambil Foto dari Kamera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Pilih Foto dari Galeri'),
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Halaman Profil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(gradient: _primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _showImageSourceSelector,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : _profileUrl != null
                            ? NetworkImage(_profileUrl!)
                            : const AssetImage('images/logo.png'),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: _primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _displayName,
                style: GoogleFonts.alexandria(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration:TextDecoration.none
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _departemen,
                style: GoogleFonts.alexandria(
                  fontSize: 18,                  
                  color: Colors.white,
                  decoration:TextDecoration.none
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
                      _buildSectionTitle('Pengaturan Akun'),
                      _buildProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profil',
                        onTap: _showEditProfileDialog,
                        
                      ),
                      _buildProfileMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Ganti Kata Sandi',
                        onTap: _showChangePasswordDialog,
                      ),
                      _buildProfileMenuItem(
                        icon: Icons.attach_money,
                        title: 'Gaji',
                        onTap: () {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            _navigateTo(GajiPage(userId: user.id));
                          }
                        },
                      ),
                      _buildSectionTitle('Aktivitas Pengguna'),
                      _buildProfileMenuItem(
                        icon: Icons.history,
                        title: 'Riwayat Aktivitas',
                        onTap: () => _navigateTo(ActivityPage()),
                      ),
                      _buildSectionTitle('Dukungan & Bantuan'),
                      _buildProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Pusat Bantuan',
                        onTap: () => _navigateTo(const PusatBantuanPage()),
                      ),
                      _buildProfileMenuItem(
                        icon: Icons.phone,
                        title: 'Hubungi Kami',
                        onTap: () => _navigateTo(const HubungiKamiPage()),
                      ),
                      _buildProfileMenuItem(
                        icon: Icons.bug_report,
                        title: 'Laporan Masalah',
                        onTap: () => _navigateTo(const LaporanMasalahPage()),
                      ),
                      _buildSectionTitle('Pengaturan'),
                      _buildProfileMenuItem(
                        icon: Icons.notifications_active,
                        title: 'Notifikasi',
                        onTap: () => _navigateTo(const NotifikasiPage()),
                      ),
                      _buildProfileMenuItem(
                        icon: Icons.security,
                        title: 'Privasi',
                        onTap: () => _navigateTo(const PengaturanPrivasiPage()),
                      ),
                      _buildProfileMenuItem(
                        icon: Icons.logout,
                        title: 'Keluar',
                        onTap: _showLogoutDialog,
                        isDestructive: true,
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required Function() onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : _primaryColor),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<String?> _uploadImage(String userId) async {
    if (_image == null) return null;
    try {
      final fileExt = _image!.path.split('.').last;
      final filePath = 'profile_pictures/$userId.$fileExt';

      // Upload gambar ke Supabase Storage
      await Supabase.instance.client.storage.from('profile_pictures').upload(
            filePath,
            _image!,
            fileOptions: const FileOptions(upsert: true),
          );

      // Ambil URL gambar yang baru diunggah
      final imageUrl = Supabase.instance.client.storage
          .from('profile_pictures')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      _showErrorDialog('Gagal mengunggah gambar: ${e.toString()}');
      return null;
    }
  }

  void _showEditProfileDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return CupertinoAlertDialog(
            title: const Text('Edit Profil'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _pickImage(ImageSource.gallery);
                      setState(() {}); // Perbarui tampilan jika gambar berubah
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_profileUrl != null
                              ? NetworkImage(_profileUrl!)
                              : const AssetImage('images/logo.png')
                                  as ImageProvider),
                      child: _image == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Nama Baru',
                    padding: const EdgeInsets.all(12),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'Email Baru',
                    padding: const EdgeInsets.all(12),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _phoneController,
                    placeholder: 'Nomor Telepon Baru',
                    padding: const EdgeInsets.all(12),
                  ),
                ],
              ),
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
                onPressed: () async {
                  Navigator.pop(context);
                  await _updateUserProfile();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showErrorDialog("User tidak ditemukan.");
      return;
    }

    try {
      String? imageUrl;

      // Jika ada gambar baru, upload ke Supabase Storage
      if (_image != null) {
        imageUrl = await _uploadImage(user.id);
      }

      // Update data user di database Supabase
      await Supabase.instance.client.from('users').update({
        'display_name': _nameController.text, // Simpan nama baru
        'email': _emailController.text,
        'phone': _phoneController.text,
        if (imageUrl != null) 'profile_url': imageUrl,
      }).eq('id', user.id);

      // Perbarui UI dengan data terbaru
      setState(() {
        _profileUrl = imageUrl ?? _profileUrl;
        _displayName = _nameController.text; // Perbarui nama yang ditampilkan
      });

      _showSuccessDialog('Profil berhasil diperbarui!');
    } catch (e) {
      _showErrorDialog('Gagal memperbarui profil: ${e.toString()}');
    }
  }

  void _showChangePasswordDialog() {
  String oldPassword = '';
  String newPassword = '';

  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Ganti Kata Sandi'),
      content: Column(
        children: [
          const SizedBox(height: 10),
          CupertinoTextField(
            obscureText: true,
            placeholder: 'Kata Sandi Lama',
            padding: const EdgeInsets.all(12),
            onChanged: (value) => oldPassword = value,
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            obscureText: true,
            placeholder: 'Kata Sandi Baru',
            padding: const EdgeInsets.all(12),
            onChanged: (value) => newPassword = value,
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
          onPressed: () async {
            Navigator.pop(context);
            await _changePassword(oldPassword, newPassword);
          },
        ),
      ],
    ),
  );
}

Future<void> _changePassword(String oldPassword, String newPassword) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    _showErrorDialog('Anda belum login.');
    return;
  }

  try {
    // Cek apakah password lama benar
    final response = await supabase.auth.signInWithPassword(
      email: user.email!,
      password: oldPassword,
    );

    if (response.user == null) {
      _showErrorDialog('Kata sandi lama salah.');
      return;
    }

    // Ubah password ke yang baru
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
    _showSuccessDialog('Kata sandi berhasil diubah!');
  } catch (e) {
    _showErrorDialog('Terjadi kesalahan: $e');
  }
}

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const HalamanLogin(username: ''),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  _showErrorDialog('Error: ${e.toString()}');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => page),
    );
  }
}
