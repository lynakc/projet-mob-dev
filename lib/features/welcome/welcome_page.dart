import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  double _opacity = 0;
  double _scale = 0.8;
  int _phase = 0;

  late AnimationController _fillCtrl;
  late AnimationController _collapseCtrl;

  static const int _barCount = 18;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _opacity = 1;
        _scale = 1;
      });
    });

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _collapseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _fillCtrl.forward();
    });

    _fillCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _phase = 1);
        _collapseCtrl.forward();
      }
    });

    _collapseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _phase = 2);
        Future.delayed(const Duration(milliseconds: 200), _goNext);
      }
    });
  }

  void _goNext() {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            user == null ? const LoginPage() : const HomePage(), /////////
        transitionsBuilder: (_, anim, _, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut));
          final fadeOut = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0, 0),
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut));
          return Stack(
            children: [
              SlideTransition(
                position: fadeOut,
                child: const SizedBox.expand(),
              ),
              SlideTransition(position: slide, child: child),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    _collapseCtrl.dispose();
    super.dispose();
  }

  double _barHeight(int index, double fillProgress, double collapseProgress) {
    if (_phase == 2) return 1.5;
    final barFill = ((fillProgress * _barCount) - index).clamp(0.0, 1.0);
    final centerBias = math.sin(math.pi * index / (_barCount - 1));
    final maxH = 8 + centerBias * 18.0; //  shorter max height wa6
    final filledH = 2 + barFill * maxH;
    if (_phase == 0) return filledH;
    final t = Curves.easeOut.transform(collapseProgress);
    return math.max(1.5, filledH * (1 - t) + 1.5 * t);
  }

  double _barOpacity(int index, double fillProgress) {
    final barFill = ((fillProgress * _barCount) - index).clamp(0.0, 1.0);
    return 0.3 + barFill * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        children: [
          // ── logo — upper area
          Positioned(
            top: size.height * 0.22, // sits in upper third
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(seconds: 2),
                scale: _scale,
                child: Center(
                  child: Image.asset('assets/images/logo.png', width: 240),
                ),
              ),
            ),
          ),

          // ── bars — pushed to bottom
          Positioned(
            bottom: 200, // ✅ sits near bottom,,,,,,,,,,,,,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _opacity,
              child: AnimatedBuilder(
                animation: Listenable.merge([_fillCtrl, _collapseCtrl]),
                builder: (_, _) {
                  return SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(_barCount, (i) {
                        final h = _barHeight(
                          i,
                          _fillCtrl.value,
                          _collapseCtrl.value,
                        );
                        final o = _phase >= 1
                            ? 0.8
                            : _barOpacity(i, _fillCtrl.value);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1.5,
                          ), // tighter spacing
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            width: 1.5, // thinner bars
                            height: h,
                            decoration: BoxDecoration(
                              color: Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
