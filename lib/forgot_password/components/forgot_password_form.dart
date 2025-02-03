import 'package:flutter/material.dart';

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/lock_icon.png', width: 40, height: 40),
            const SizedBox(height: 10),
            Text(
              'Forgot your password?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C29),
                fontFamily: 'SF Pro',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the email associated with your account.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF797979),
                fontFamily: 'SF Pro',
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email address',
                labelStyle: TextStyle(
                  color: Color(0xFF797979),
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                ),
                filled: true,
                fillColor: Color(0xFFF3F3F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'SF Pro',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Remember your password? ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF797979),
                    fontFamily: 'SF Pro',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle sign in navigation
                  },
                  child: Text(
                    'Sign in.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF007AFF),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}