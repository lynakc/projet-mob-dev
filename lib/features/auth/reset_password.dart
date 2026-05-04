import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  void _resetPassword() async {
    final email = _emailController.text.trim();

    if (!_authService.isValidEmail(email)) {
      showMsg("Enter a valid email");
      return;
    }

    try {
      await _authService.resetPassword(email);

      if (!mounted) return;

      showMsg("Reset email sent successfully!");

      Navigator.pop(context);
    } catch (e) {
      showMsg(e.toString());
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                // TITLE
                Text(
                  "Reset Password",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PTSerif",
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Enter your email to receive a reset link",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 40),

                // EMAIL FIELD
                AppTextField(
                  controller: _emailController,
                  hint: "Email",
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // BUTTON
                AppButton(text: "Send Reset Link", onPressed: _resetPassword),

                const SizedBox(height: 15),

                // BACK BUTTON
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontFamily: "PTSerif",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

