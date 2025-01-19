import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard.dart';

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
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

 void _register() async {
  String email = _emailController.text;
  String password = _passwordController.text;
  String name = _nameController.text;
  String phone = _phoneController.text;

  try {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final userId = response.user?.id;

      // Insert additional user details (name, phone) into the 'users' table
      final insertResponse = await Supabase.instance.client
          .from('users')
          .upsert([
        {
          'id': userId, // Store the Supabase auth user ID
          'email': email,
          'name': name,
          'phone': phone,
        }
      ]);

      if (insertResponse != null && insertResponse.error != null) {
        _showErrorDialog('Failed to save user details: ${insertResponse.error!.message}');
      } else {
        
        _showSuccessDialog();
      }
    } else {
      _showErrorDialog('Registration failed. Please check your details.');
    }
  } catch (e) {
    _showErrorDialog('An error occurred: ${e.toString()}');
  }
}

void _showSuccessDialog() {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Success'),
      content: const Text('Registration Berhasil\n"Silahkan Cek Email untuk Konfirmasi Emailnya!'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context); // Close the dialog
            Navigator.pop(context); // Navigate back to login page
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
            child: SingleChildScrollView(
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
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    placeholder: 'Full Name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    placeholder: 'Email',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    focusNode: FocusNode(),
                    placeholder: 'Phone Number',
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
                    onPressed: _register,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      CupertinoButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
    path.quadraticBezierTo(
        size.width / 2, size.height + 100, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
