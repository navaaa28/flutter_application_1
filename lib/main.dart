import 'package:flutter/cupertino.dart';
import 'dashboard.dart';

void main() => runApp(const MainLoginApp());

class MainLoginApp extends StatelessWidget {
  const MainLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: HalamanLogin(),
    );
  }
}

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
  String email = _emailController.text;
  String password = _passwordController.text;

  if (email == 'dany2811' && password == '123456') {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DashboardPage(username: email, password: password), // Pass password here
      ),
    );
  } else {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Login Gagal'),
        content: const Text('Username atau password salah.'),
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
}


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: SafeArea(
        child: SingleChildScrollView( // Wrap the content with SingleChildScrollView
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill the available width
            children: <Widget>[
              const SizedBox(height: 60), // Add extra top padding for visual spacing

              // Add a logo at the top
              Image.asset(
                'images/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 30),

              // Welcome text
              const Text(
                'Welcome to Hadirrr',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              const SizedBox(height: 10),

              // Login message
              const Text(
                'Please sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.inactiveGray,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              const SizedBox(height: 30),

              // Email field
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Masukan Username',
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Masukan Password',
                obscureText: true,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 30),

              // Login button with custom style
              Container(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _login,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: CupertinoColors.activeGreen,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
