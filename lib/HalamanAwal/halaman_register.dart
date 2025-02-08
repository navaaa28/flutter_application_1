import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../HalamanAwal/halaman_login.dart';

class HalamanRegister extends StatefulWidget {
  const HalamanRegister({super.key});

  @override
  _HalamanRegisterState createState() => _HalamanRegisterState();
}

class _HalamanRegisterState extends State<HalamanRegister> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _obscurePassword = true;
  final Color primaryColor = Color(0xFF1A237E);
  final Color accentColor = Color(0xFF00BCD4);
  final LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_image == null) return null;
    try {
      final fileExt = _image!.path.split('.').last;
      final filePath = 'profile_pictures/$userId.$fileExt';

      await Supabase.instance.client.storage
          .from('profile_pictures')
          .upload(filePath, _image!);

      final imageUrl = Supabase.instance.client.storage
          .from('profile_pictures')
          .getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      _showErrorDialog('Failed to upload image: ${e.toString()}');
      return null;
    }
  }

  void _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String phone = _phoneController.text;
    String joinDate = DateTime.now().toIso8601String();
    String role = "pegawai";

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name, 'phone': phone},
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final imageUrl = await _uploadImage(userId);

        await Supabase.instance.client.from('users').upsert([
          {
            'id': userId,
            'email': email,
            'display_name': name,
            'phone': phone,
            'profile_url': imageUrl,
            'role': role,
            'join_date': joinDate,
          }
        ]);

        _showSuccessDialog();
      } else {
        _showErrorDialog('Registration failed. Please check your details.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
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
        title: const Text('Success'),
        content: const Text('Registration successful!'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                _createRoute(const HalamanLogin(username: '')),
              );
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
        backgroundColor: Colors.white, // Latar belakang lebih cerah
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
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'Welcome to ACTIVO Registration',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryColor, // Warna teks disesuaikan
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: primaryColor, // Warna icon disesuaikan
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildInputField(
                      controller: _nameController,
                      placeholder: 'Full Name',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      controller: _emailController,
                      placeholder: 'Email Address',
                      icon: Icons.mail,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      controller: _phoneController,
                      placeholder: 'Phone Number',
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      controller: _passwordController,
                      placeholder: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _register,
                        child: Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'By registering to our platform, you agree to our',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey, // Warna teks disesuaikan
                      ),
                    ),
                    Text(
                      'Terms of Service and Privacy Policy',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor, // Warna teks disesuaikan
                      ),
                    ),
                    SizedBox(height: 25),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(const HalamanLogin(username: '')),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: GoogleFonts.poppins(
                            color: Colors.grey, // Warna teks disesuaikan
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login here',
                              style: GoogleFonts.poppins(
                                color: primaryColor, // Warna teks disesuaikan
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: isPassword ? _obscurePassword : false,
        padding: EdgeInsets.all(16),
        prefix: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(icon, color: primaryColor), // Warna icon disesuaikan
        ),
        suffix: isPassword
            ? CupertinoButton(
                padding: EdgeInsets.only(right: 16),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                child: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor, // Warna icon disesuaikan
                ),
              )
            : null,
        decoration: BoxDecoration(
          color: Colors.white, // Latar belakang text field lebih cerah
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.grey.withOpacity(0.3)), // Border untuk kontras
        ),
        style: GoogleFonts.poppins(
          color: Colors.black, // Warna teks disesuaikan
        ),
      ),
    );
  }

  // Animasi transisi
  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
