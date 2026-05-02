import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_page.dart';
import '../home/home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {

  double opacity = 0;

  @override
  void initState() {
    super.initState();

    // 🔮 animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        opacity = 1;
      });
    });

    // ⏳ wait 4 seconds then navigate
    Timer(const Duration(seconds: 4), () {
      _goNext();
    });
  }

  void _goNext() {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),

      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Color(0xFF6A1B9A),
              ),

              SizedBox(height: 20),

              Text(
                "Audio Quran App",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}