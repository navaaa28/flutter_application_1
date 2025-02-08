// File: lib/HalamanProfil/notifikasi_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final Color _primaryColor = const Color(0xFF2A2D7C);
  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _promoNotifications = false;
  bool _scheduleReminders = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _primaryColor,
        middle: Text(
          'Pengaturan Notifikasi',
          style: GoogleFonts.poppins(
            color: Color.fromARGB(255, 0, 8, 255),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Color.fromARGB(255, 0, 8, 255)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Material(
      color: Colors.transparent, // Pastikan background transparan
      child: SafeArea(
        child: Column(
          children: [
              Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      leading: Icon(Icons.notifications, color: _primaryColor),
                      title: Text(
                        'Notifikasi Push',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Terima notifikasi langsung di perangkat',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Switch(
                        value: _pushNotifications,
                        onChanged: (val) => setState(() => _pushNotifications = val),
                        activeColor: _primaryColor,
                      ),
                    ),
                  ]
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Icon(CupertinoIcons.bell_fill, size: 60, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            'Kelola preferensi notifikasi Anda',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            )
          : null,
      value: value,
      activeColor: _primaryColor,
      onChanged: onChanged,
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      children: [
        Divider(color: Colors.grey[300], height: 1),
        ListTile(
          title: Text(
            'Pengaturan Lanjutan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          trailing: Icon(CupertinoIcons.chevron_forward, color: _primaryColor),
          onTap: () {
            // Tambahkan navigasi ke halaman pengaturan lanjutan
          },
        ),
        ListTile(
          title: Text(
            'Jadwalkan Mode Diam',
            style: GoogleFonts.poppins(),
          ),
          subtitle: Text(
            'Atur waktu tertentu untuk menonaktifkan notifikasi',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          trailing: Icon(CupertinoIcons.clock, color: _primaryColor),
          onTap: () {
            // Tambahkan logika jadwal mode diam
          },
        ),
      ],
    );
  }
}