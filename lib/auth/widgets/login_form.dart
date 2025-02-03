import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xEEFAFAFA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/8947c9b6590085d9f1e59654cc56cfb880c9728cedd55a6a5eb8b71d79dd6790?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
              width: 30,
              height: 30,
              semanticLabel: 'Close button',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Login or sign up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C29),
              fontFamily: 'SF Pro',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please select your preferred method\nto continue setting up your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF797979),
              fontFamily: 'SF Pro',
              height: 1.33,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Continue with Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFD7D7D7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/99176a835d6d67db66f71c3f7bd4eeb41b4a9ac7d892850d94338a12dcacb11f?placeholderIfAbsent=true&apiKey=dead683945384c4d9613fecc215a7ace',
              width: 20,
              height: 20,
              semanticLabel: 'Social login icon',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF797979),
              fontFamily: 'SF Pro',
              height: 1.67,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}