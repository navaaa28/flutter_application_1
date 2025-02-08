import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_lupa_password.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../HalamanTengah/dashboard_page.dart';
import '../HalamanAdmin/admin_dashboard.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key, required this.username});

  final String username;

  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final Color primaryColor = Color(0xFF1A237E);
  final Color accentColor = Color(0xFF00BCD4);
  final LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user?.id;

        final userResponse = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', userId!)
            .single();

        String? displayName = userResponse['display_name'];
        String? role = userResponse['role'];

        if (displayName != null) {
          if (role == 'admin') {
            Navigator.push(
              context,
              _createRoute(const AdminDashboard()),
            );
          } else {
            Navigator.push(
              context,
              _createRoute(DashboardPage(
                username: displayName,
                password: '',
              )),
            );
          }
        } else {
          _showErrorDialog('Display name tidak ditemukan.');
        }
      } else {
        _showErrorDialog('Login gagal. Periksa email dan password Anda.');
      }
    } catch (e) {
      _showErrorDialog('Email Atau Password Salah');
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
            onPressed: () {
              Navigator.pop(context);
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
                      'Welcome to ACTIVO',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryColor, // Warna teks disesuaikan
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildInputField(
                      controller: _emailController,
                      placeholder: 'Email Address',
                      icon: Icons.mail,
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
                        onPressed: _login,
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(const HalamanLupaPassword()),
                        );
                      },
                      child: Text(
                        'Lupa Password?',
                        style: GoogleFonts.poppins(
                          color: primaryColor, // Warna teks disesuaikan
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(const HalamanRegister()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: Colors.grey, // Warna teks disesuaikan
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Register here',
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
