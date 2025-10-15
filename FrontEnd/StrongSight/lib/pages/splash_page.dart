import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // The curl animation: 0° → -45° → 0° (like lifting and lowering a weight)
    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -math.pi / 4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -math.pi / 4, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // Navigate to home after animation
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF094941),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              origin: const Offset(0, 40), // pivot point for curl
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/strongsight_logo.png',
            width: 160,
          ),
        ),
      ),
    );
  }
}
