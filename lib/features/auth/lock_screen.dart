import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/biometric_service.dart';
import '../auth/login_page.dart';
import '../welcome/welcome_page.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final biometric = BiometricService();
  bool bioPassed = false;

  @override
  void initState() {
    super.initState();
    _runBiometric();
  }

  Future<void> _runBiometric() async {
    bool ok = await biometric.authenticate();

    if (!mounted) return;

    if (ok) {
      setState(() => bioPassed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 STEP 1: biometric gate
    if (!bioPassed) {
      return const Scaffold(
        body: Center(child: Text("Fingerprint required")),
      );
    }

    // 🔥 STEP 2: firebase check
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginPage();
        }

        return const WelcomePage();
      },
    );
  }
}