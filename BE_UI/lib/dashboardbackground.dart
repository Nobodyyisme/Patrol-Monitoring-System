import 'dart:ui';
import 'package:flutter/material.dart';

class DashboardBackground extends StatefulWidget {
  final Widget child;
  const DashboardBackground({super.key, required this.child});

  @override
  State<DashboardBackground> createState() => _DashboardBackgroundState();
}

class _DashboardBackgroundState extends State<DashboardBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _animation1 = Tween<double>(begin: -80, end: -40).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _animation2 = Tween<double>(begin: -100, end: -130).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));

    _animation3 = Tween<double>(begin: 120, end: 150).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),



          // ✨ Animated Glowing Circles
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: _animation1.value,
                    left: -60,
                    child: _blurCircle(180, Colors.blueAccent.withOpacity(0.35)),
                  ),
                  Positioned(
                    bottom: _animation2.value,
                    right: -50,
                    child: _blurCircle(220, Colors.purpleAccent.withOpacity(0.25)),
                  ),
                  Positioned(
                    top: _animation3.value,
                    right: 60,
                    child: _blurCircle(140, Colors.cyanAccent.withOpacity(0.2)),
                  ),
                ],
              );
            },
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.55), // Adds soft shadow tint
              ),
            ),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 30,
            offset: const Offset(0, 0),
          )
        ],
      ),
    );
  }
}
