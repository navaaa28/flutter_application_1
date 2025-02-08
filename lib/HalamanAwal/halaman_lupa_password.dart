import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_reset_password.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanLupaPassword extends StatefulWidget {
  const HalamanLupaPassword({super.key});

  @override
  State<HalamanLupaPassword> createState() => _HalamanLupaPasswordState();
}

class _HalamanLupaPasswordState extends State<HalamanLupaPassword>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final Color primaryColor = const Color(0xFF1A237E); // Diubah
  final Color accentColor = const Color(0xFF00BCD4); // Diubah
  final LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00BCD4)], // Diubah
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog('Silakan masukkan email Anda');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kirim email reset password tanpa redirect URL
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      // Navigasi ke halaman input token
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => HalamanResetPassword(email: email),
        ),
      );
    } catch (e) {
      _showErrorDialog('Gagal mengirim reset password: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 100, // Sesuaikan ukuran
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'images/logo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit
                                .cover, // Pastikan gambar menutupi lingkaran
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'ACTIVO',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Konten Form
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Text(
                      'Reset Password',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: primaryColor, // Warna teks disesuaikan
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildEmailInput(),
                    const SizedBox(height: 30),
                    _buildResetButton(),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      child: Text(
                        'Kembali ke Login',
                        style: GoogleFonts.poppins(
                          color: primaryColor, // Warna teks disesuaikan
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: _emailController,
        placeholder: 'Email Terdaftar',
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(CupertinoIcons.mail, color: Color(0xFF2A2D7C)),
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Latar belakang text field lebih cerah
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.grey.withOpacity(0.3)), // Border untuk kontras
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(12),
        onPressed: _isLoading ? null : _resetPassword,
        child: _isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                'Kirim Instruksi Reset',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
