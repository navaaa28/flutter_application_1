import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanResetPassword extends StatefulWidget {
  final String email;

  const HalamanResetPassword({super.key, required this.email});

  @override
  State<HalamanResetPassword> createState() => _HalamanResetPasswordState();
}

class _HalamanResetPasswordState extends State<HalamanResetPassword>
    with SingleTickerProviderStateMixin {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Color primaryColor = const Color(0xFF1A237E); // Diubah
  final Color accentColor = const Color(0xFF00BCD4); // Diubah
  final LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00BCD4)], // Diubah
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  bool _isLoading = false;
  bool _obscurePassword = true;

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

  Future<void> _verifyAndReset() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Password tidak sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verifikasi token dan update password
      await Supabase.instance.client.auth
          .verifyOTP(
            token: _tokenController.text.trim(),
            type: OtpType.recovery,
            email: widget.email,
          )
          .then((_) => Supabase.instance.client.auth.updateUser(
                UserAttributes(password: _passwordController.text.trim()),
              ));

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Gagal reset password: ${e.toString()}');
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

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Berhasil'),
        content: Text('Password berhasil direset!'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
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
                      'Token telah dikirim ke ${widget.email}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _buildTokenInput(),
                    const SizedBox(height: 20),
                    _buildPasswordInput(),
                    const SizedBox(height: 20),
                    _buildConfirmPasswordInput(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInput() {
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
        controller: _tokenController,
        placeholder: 'Masukkan Token',
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(CupertinoIcons.number, color: Color(0xFF2A2D7C)),
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

  Widget _buildPasswordInput() {
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
        controller: _passwordController,
        placeholder: 'Password Baru',
        obscureText: _obscurePassword,
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(CupertinoIcons.lock, color: Color(0xFF2A2D7C)),
        ),
        suffix: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: primaryColor,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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

  Widget _buildConfirmPasswordInput() {
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
        controller: _confirmPasswordController,
        placeholder: 'Konfirmasi Password',
        obscureText: _obscurePassword,
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(CupertinoIcons.lock, color: Color(0xFF2A2D7C)),
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

  Widget _buildSubmitButton() {
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
        onPressed: _isLoading ? null : _verifyAndReset,
        child: _isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                'Reset Password',
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
