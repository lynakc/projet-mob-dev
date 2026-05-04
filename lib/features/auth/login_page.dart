import 'package:flutter/material.dart';
import 'signup_page.dart';
import '../../core/services/auth_service.dart';
import '/features/welcome/welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginEmail = TextEditingController();
  final loginPwd = TextEditingController();
  final service = AuthService();

  bool _obscure = true;
  bool _signupTapped = false;

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
          loginPwd.text
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    } catch (e) {
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
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 40),

                // LOGO
                Center(
                  child: Image.asset(
                    "assets/images/small_logo.png",
                    height: 90,
                  ),
                ),

                const SizedBox(height: 20),

                // TITLE
                Center(
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontFamily: "PTSerif",
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // EMAIL
                TextField(
                  controller: loginEmail,
                  style: const TextStyle(fontFamily: "PTSerif"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF4EBE0),
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextField(
                  controller: loginPwd,
                  obscureText: _obscure,
                  style: const TextStyle(fontFamily: "PTSerif"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF4EBE0),
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // LOGIN BUTTON
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontFamily: "PTSerif"),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // FORGOT PASSWORD
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reset-password');
                  },
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontFamily: "PTSerif",
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // SIGNUP
                GestureDetector(
                  onTapDown: (_) {
                    setState(() => _signupTapped = true);
                  },
                  onTapUp: (_) {
                    setState(() => _signupTapped = false);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        "Don't have an account? Signup",
                        style: TextStyle(
                          fontFamily: "PTSerif",
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: _signupTapped ? 120 : 0,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}