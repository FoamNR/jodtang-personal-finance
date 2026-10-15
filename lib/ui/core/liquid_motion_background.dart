import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-performance, GPU-accelerated motion graphic background
/// that renders organic fluid gradient orbs moving in smooth Lissajous curves.
class LiquidMotionBackground extends StatefulWidget {
  final Widget? child;

  const LiquidMotionBackground({super.key, this.child});

  @override
  State<LiquidMotionBackground> createState() => _LiquidMotionBackgroundState();
}

class _LiquidMotionBackgroundState extends State<LiquidMotionBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 14 seconds for a calm, breathing organic fluid motion
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save battery and GPU: pause animation when app is paused or hidden
    if (state == AppLifecycleState.resumed) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Mesh Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF090D16),
                        Color(0xFF0F172A),
                        Color(0xFF131D33),
                      ]
                    : const [
                        Color(0xFFF0FDF4), // Emerald tint
                        Color(0xFFF8FAFC), // Slate tint
                        Color(0xFFEEF2FF), // Indigo tint
                      ],
              ),
            ),
          ),

          // 2. Animated Fluid Orbs (Native multi-stop feathered gradient)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _LiquidOrbsPainter(
                  progress: _controller.value,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 3. Lightweight ambient contrast overlay (Zero GPU blur overhead)
          Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.10),
          ),

          // 4. Foreground Content (if provided)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _LiquidOrbsPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _LiquidOrbsPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final t = progress * 2 * math.pi;
    final w = size.width;
    final h = size.height;

    // Orb 1: Emerald Green (Primary Brand)
    final p1 = Offset(
      w * 0.35 + math.cos(t) * (w * 0.22),
      h * 0.25 + math.sin(t * 1.2) * (h * 0.18),
    );
    final r1 = w * 0.55;
    _drawOrb(
      canvas: canvas,
      center: p1,
      radius: r1,
      color: const Color(0xFF10B981),
      alpha: isDark ? 0.32 : 0.26,
    );

    // Orb 2: Deep Cyan / Turquoise
    final p2 = Offset(
      w * 0.75 + math.sin(t + 1.2) * (w * 0.20),
      h * 0.45 + math.cos(t * 0.8 + 0.5) * (h * 0.22),
    );
    final r2 = w * 0.50;
    _drawOrb(
      canvas: canvas,
      center: p2,
      radius: r2,
      color: const Color(0xFF06B6D4),
      alpha: isDark ? 0.30 : 0.22,
    );

    // Orb 3: Royal Indigo / Purple
    final p3 = Offset(
      w * 0.25 + math.sin(t * 0.9 + 2.5) * (w * 0.25),
      h * 0.70 + math.cos(t * 1.1 + 1.8) * (h * 0.20),
    );
    final r3 = w * 0.58;
    _drawOrb(
      canvas: canvas,
      center: p3,
      radius: r3,
      color: const Color(0xFF6366F1),
      alpha: isDark ? 0.28 : 0.18,
    );

    // Orb 4: Warm Amber / Sunset Glow
    final p4 = Offset(
      w * 0.70 + math.cos(t * 1.3 + 3.4) * (w * 0.22),
      h * 0.82 + math.sin(t * 0.7 + 2.8) * (h * 0.16),
    );
    final r4 = w * 0.45;
    _drawOrb(
      canvas: canvas,
      center: p4,
      radius: r4,
      color: const Color(0xFFF59E0B),
      alpha: isDark ? 0.22 : 0.16,
    );

    // Orb 5: Mint Highlight
    final p5 = Offset(
      w * 0.50 + math.cos(t * 0.6 + 4.2) * (w * 0.18),
      h * 0.15 + math.sin(t * 1.4 + 4.0) * (h * 0.14),
    );
    final r5 = w * 0.38;
    _drawOrb(
      canvas: canvas,
      center: p5,
      radius: r5,
      color: const Color(0xFF34D399),
      alpha: isDark ? 0.25 : 0.20,
    );
  }

  void _drawOrb({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: alpha * 0.55),
          color.withValues(alpha: alpha * 0.18),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidOrbsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
