import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final service = AuthService();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final confirmEmail = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  DateTime? dob;

  bool _obscure1 = true;
  bool _obscure2 = true;

  void signup() async {
    try {
      if (firstName.text.isEmpty ||
          lastName.text.isEmpty ||
          email.text.isEmpty) {
        showMsg("Insert all fields");
        return;
      }

      if (password.text.length < 6) {
        showMsg("Weak Password");
        return;
      }

      if (dob == null) {
        showMsg("Select date of birth");
        return;
      }

      if (!service.isAtLeast13(dob!)) {
        showMsg("Must be 13+");
        return;
      }

      if (email.text != confirmEmail.text) {
        showMsg("Emails do not match");
        return;
      }

      if (password.text != confirmPassword.text) {
        showMsg("Passwords do not match");
        return;
      }

      final uid = await service.signup(
        firstName: firstName.text,
        lastName: lastName.text,
        dob: dob!,
        email: email.text,
        password: password.text,
      );

      await service.initListeningStats(uid);

      showMsg("Account created successfully");

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      showMsg(e.toString());
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );
    if (picked != null) setState(() => dob = picked);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 30),

                // LOGO
                Center(
                  child: Image.asset(
                    "assets/images/small_logo.png",
                    height: 90,
                  ),
                ),

                const SizedBox(height: 15),

                // TITLE
                Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontFamily: "PTSerif",
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // FIRST NAME
                _field(firstName, "First Name", Icons.person, theme),

                const SizedBox(height: 12),

                // LAST NAME
                _field(lastName, "Last Name", Icons.person_outline, theme),

                const SizedBox(height: 12),

                // DOB
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBE0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      dob == null
                          ? "Date of birth"
                          : dob.toString().split(" ")[0],
                      style: const TextStyle(fontFamily: "PTSerif"),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: pickDate,
                  ),
                ),

                const SizedBox(height: 12),

                // EMAIL
                _field(email, "Email", Icons.email, theme),

                const SizedBox(height: 12),

                // CONFIRM EMAIL
                _field(confirmEmail, "Confirm Email", Icons.email_outlined, theme),

                const SizedBox(height: 12),

                // PASSWORD
                _passwordField(password, "Password", theme, true),

                const SizedBox(height: 12),

                // CONFIRM PASSWORD
                _passwordField(confirmPassword, "Confirm Password", theme, false),

                const SizedBox(height: 25),

                // SIGNUP BUTTON
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontFamily: "PTSerif"),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // LOGIN LINK
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      fontFamily: "PTSerif",
                      color: theme.colorScheme.primary,
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

  Widget _field(TextEditingController c, String hint, IconData icon, ThemeData theme) {
    return TextField(
      controller: c,
      style: const TextStyle(fontFamily: "PTSerif"),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4EBE0),
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController c, String hint, ThemeData theme, bool first) {
    return TextField(
      controller: c,
      obscureText: first ? _obscure1 : _obscure2,
      style: const TextStyle(fontFamily: "PTSerif"),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4EBE0),
        hintText: hint,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            (first ? _obscure1 : _obscure2)
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (first) {
                _obscure1 = !_obscure1;
              } else {
                _obscure2 = !_obscure2;
              }
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}