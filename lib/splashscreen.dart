import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'halaman_login.dart'; // Import file HalamanLogin

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Navigasi ke halaman login setelah 3 detik
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const HalamanLogin()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/foto.png'), // Gambar splash
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo aplikasi
              Image(
                image: AssetImage('images/logo.png'),
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              // Nama aplikasi
              Text(
                'Hadirrr',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                'Solusi Absensi Anda',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
