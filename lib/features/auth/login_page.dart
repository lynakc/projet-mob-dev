import 'package:flutter/material.dart';
import 'signup_page.dart';
import '../../core/services/auth_service.dart';
import 'lock_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginEmail = TextEditingController();
  final loginPwd = TextEditingController();
  final service = AuthService();

  void login() async {
    try {
      if (!service.isValidEmail(loginEmail.text)) {
        showMsg("Email invalid");
        return;
      }

      if (loginPwd.text.isEmpty) {
        showMsg("Insert Password");
        return;
      }

      await service.login(
        loginEmail.text,
        loginPwd.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LockScreen()),
      );

    }
    catch (e) {
      print("LOGIN ERROR: $e");
      showMsg(e.toString());
    }
  }
  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: loginEmail,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: loginPwd,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reset-password');
              },
              child: const Text("Forgot password ?"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't you have an account ?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text("Signup"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}