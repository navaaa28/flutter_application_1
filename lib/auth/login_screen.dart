import 'package:flutter/material.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/welcome_section.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Column(
            children: [
              Container(
                color: Colors.black.withOpacity(0.25),
                child: Column(
                  children: const [
                    LoginHeader(),
                    WelcomeSection(),
                    LoginForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}