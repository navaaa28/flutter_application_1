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

  bool _pushNotifications = true;

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
}