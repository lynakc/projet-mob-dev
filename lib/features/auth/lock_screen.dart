import 'package:flutter/material.dart';
import 'package:projetmobdev/features/home/home_page.dart';
import '../../core/services/biometric_service.dart';
import '../home/main_page.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final biometric = BiometricService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auth();
    });
  }

  void _auth() async {
    bool ok = await biometric.authenticate();

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Verify fingerprint to continue"),
      ),
    );
  }
}