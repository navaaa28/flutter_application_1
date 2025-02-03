import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/status_bar.dart';
import 'components/back_button.dart';
import 'components/forgot_password_form.dart';
import 'components/reset_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: const [
              StatusBar(),
              CustomBackButton(),
              ForgotPasswordForm(),
              Spacer(),
              ResetButton(),
              SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}