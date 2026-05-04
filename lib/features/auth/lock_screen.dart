import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'biometric_Controller.dart';
import '../auth/login_page.dart';
import '../welcome/welcome_page.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

enum BioState { checking, scanning, noFingerprint, success }

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final controller = BiometricController();
  BioState state = BioState.checking;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // wait for first frame before starting biometric
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), _startBio);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //  AUTO RETRY WHEN RETURNING FROM SETTINGS
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isAuthenticated) {
      Future.delayed(const Duration(milliseconds: 500), _startBio);
    }
  }

  void _startBio() {
    if (_isAuthenticated) return; //  STOP LOOP

    setState(() {
      state = BioState.scanning;
    });

    controller.authenticate(
      onSuccess: () {
        if (!mounted) return;

        controller.stopAuthentication(); //stop contr

        setState(() {
          state = BioState.success;
          _isAuthenticated = true;
        });
      },
      onFail: () async {
        if (!mounted) return;

        setState(() {
          state = BioState.noFingerprint;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (state) {
      // 🔵 SCANNING
      case BioState.scanning:
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 90,
                  color: theme.colorScheme.secondary,
                ),

                const SizedBox(height: 20),

                Text(
                  "Touch sensor",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Authenticate using fingerprint",
                  style: TextStyle(
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );

      //  NO FINGERPRINT
      case BioState.noFingerprint:
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: theme.colorScheme.secondary,
                ),

                const SizedBox(height: 20),

                Text(
                  "Fingerprint Required",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Enable it in settings",
                  style: TextStyle(
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () async {
                    await controller.openSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Go to Settings"),
                ),
              ],
            ),
          ),
        );

      // SUCCESS
      case BioState.success:
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
      case BioState.checking:
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
