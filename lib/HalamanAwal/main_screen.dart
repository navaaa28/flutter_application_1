import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_login.dart';
import 'package:flutter_application_1/auth/login_screen.dart';
import 'package:flutter_application_1/forgot_password/forgot_password_screen.dart';



class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigasi ke HalamanLogin setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HalamanLogin(username: '',)),
      );
    });

    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 79, vertical: 275),
          child: Image.network(
            'https://cdn.builder.io/api/v1/image/assets/TEMP/390be36b2fcf06319566dd6162e50d9999002cc693a6d7429b73fa2f9392082b?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
            width: 195,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}