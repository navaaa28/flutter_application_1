import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAdmin/audit_sistem_page.dart.dart';
import 'package:flutter_application_1/HalamanAdmin/backup_data_page.dart';
import 'package:flutter_application_1/HalamanAdmin/manajemen_departemen.dart';
import 'package:flutter_application_1/HalamanAdmin/manajemen_user.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AdminProfileTab extends StatefulWidget {
  final VoidCallback informasi;

  const AdminProfileTab({
    Key? key,
    required this.informasi,
  }) : super(key: key);

  @override
  _AdminProfileTabState createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  File? _image;
  String? _profileUrl;
  String _displayName = 'Admin';
  String _role = 'admin';
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
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('users')
        .select('profile_url, display_name, role')
        .eq('id', user.id)
        .single();

    if (response != null) {
      setState(() {
        _profileUrl = response['profile_url'];
        _displayName = response['display_name'] ?? 'Admin';
        _role = response['role'] ?? 'admin';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Pilih Foto dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan Admin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: widget.informasi,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(gradient: _primaryGradient),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImageSourceSelector,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : (_profileUrl != null
                                  ? NetworkImage(_profileUrl!)
                                  : const AssetImage('images/logo.png') as ImageProvider),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: _primaryColor, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _displayName,
                    style: GoogleFonts.alexandria(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _role.toUpperCase(),
                    style: GoogleFonts.alexandria(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
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
              child: Column(
                children: [
                  _buildSectionTitle('Admin Tools'),
                  _buildProfileMenuItem(
                    icon: Icons.people_alt,
                    title: 'Manajemen Pengguna',
                    onTap: () => _navigateTo(const ManajemenUserPage()),
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.business,
                    title: 'Manajemen Departemen',
                    onTap: () => _navigateTo(const ManajemenDepartemenPage()),
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.analytics,
                    title: 'Analytics Sistem',
                    onTap: () {},
                  ),
                  _buildSectionTitle('Sistem'),
                  _buildProfileMenuItem(
                    icon: Icons.backup,
                    title: 'Backup Data',
                    onTap: () => _navigateTo(HadirPage()),
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.security,
                    title: 'Audit Sistem',
                    onTap: () => _navigateTo(AuditSistemPage()),
                  ),
                  _buildSectionTitle('Umum'),
                  _buildProfileMenuItem(
                    icon: Icons.change_circle_rounded,
                    title: 'Change Password',
                    onTap: () => _showChangePasswordDialog(),
                    isDestructive: true,
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    onTap: () => _showLogoutDialog(context),
                    isDestructive: true,
                  ),                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileMenuItem({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : _primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

 void _showLogoutDialog(BuildContext context) {
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
}
