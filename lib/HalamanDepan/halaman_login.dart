import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanDepan/halaman_register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key, required String username});

  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
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
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DashboardPage(
              username: email,
              password: password,
            ),
          ),
        );
      } else {
        _showErrorDialog('Login gagal. Periksa email dan password Anda.');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
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
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 200),
            painter: CurvedPainter(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Let\'s Get Started',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    placeholder: 'Email or Mobile',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    placeholder: 'Password',
                    obscureText: _obscurePassword,
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: _login,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const HalamanRegister(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = focusNode.hasFocus;
          return CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            obscureText: obscureText,
            padding: const EdgeInsets.all(16),
            suffix: suffix,
            decoration: BoxDecoration(
              color: CupertinoColors.lightBackgroundGray,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasFocus ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height + 100, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
