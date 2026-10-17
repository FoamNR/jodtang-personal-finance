import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../core/glass_container.dart';

/// A premium animated Splash and Loading screen for Jod Tang (จดตัง).
///
/// Features:
/// - Staggered elastic entrance for brand logo and typography
/// - Concentric ambient pulsating ripples with fluid glow
/// - Shimmering liquid capsule progress bar with real-time percentage
/// - Dynamic Thai contextual loading status messages
/// - Haptic feedback and smooth outro fade/scale transition
class SplashScreen extends StatefulWidget {
  final Future<void>? initialTasks;
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    this.initialTasks,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _progressController;
  late final AnimationController _shimmerController;
  late final AnimationController _outroController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _progressOpacity;
  late final Animation<double> _outroOpacity;
  late final Animation<double> _outroScale;

  String _loadingMessage = 'กำลังเริ่มต้นระบบ...';

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller (Staggered entrance of logo & text)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    // 2. Pulse / Ripple Controller (Continuous breathing aura)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 3. Shimmer Controller (Light reflection sweep over progress bar)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 4. Progress Controller (0.0 to 1.0 loading simulation)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    _progressController.addListener(() {
      final value = _progressController.value;
      String newMsg;
      if (value < 0.28) {
        newMsg = 'กำลังเริ่มต้นระบบ...';
      } else if (value < 0.65) {
        newMsg = 'กำลังเตรียมข้อมูลกระเป๋าเงิน...';
      } else if (value < 0.92) {
        newMsg = 'ตรวจสอบความปลอดภัย...';
      } else {
        newMsg = 'พร้อมใช้งานแล้ว!';
      }

      if (newMsg != _loadingMessage) {
        setState(() {
          _loadingMessage = newMsg;
        });
      }
    });

    // 5. Outro Controller (Fade & Scale transition when done)
    _outroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _outroOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _outroController, curve: Curves.easeInOut),
    );

    _outroScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _outroController, curve: Curves.easeInQuad),
    );

    _startAppLoadingSequence();
  }

  Future<void> _startAppLoadingSequence() async {
    _entranceController.forward();

    // Start progress animation
    _progressController.forward();

    // Wait for initial async tasks if provided, along with the progress animation
    final tasks = widget.initialTasks;
    if (tasks != null) {
      await Future.wait([
        tasks,
        _progressController.forward(),
      ]);
    } else {
      await _progressController.forward();
    }

    // Gentle tactile feedback upon completion
    HapticFeedback.lightImpact();

    // Brief pause to display 100% / ready state
    await Future.delayed(const Duration(milliseconds: 260));

    if (mounted) {
      await _outroController.forward();
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    _outroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _outroController,
      builder: (context, child) {
        return Opacity(
          opacity: _outroOpacity.value,
          child: Transform.scale(
            scale: _outroScale.value,
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Center Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Animated App Logo with glowing aura and concentric ripples
                    _buildAnimatedLogo(isDark),

                    const SizedBox(height: 36),

                    // Staggered Title & Subtitle
                    _buildAnimatedTypography(isDark),

                    const Spacer(flex: 2),

                    // Animated Liquid Progress Bar & Status Text
                    _buildAnimatedProgressSection(isDark),

                    const SizedBox(height: 40),

                    // Footer security badge
                    _buildFooter(isDark),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the animated multi-layered glowing logo
  Widget _buildAnimatedLogo(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pulseController]),
      builder: (context, _) {
        final pulse = _pulseController.value;
        final scale = _logoScale.value;
        final opacity = _logoOpacity.value;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple 1
                  Transform.scale(
                    scale: 1.0 + (pulse * 0.45),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(
                          alpha: (1.0 - pulse) * 0.22,
                        ),
                      ),
                    ),
                  ),

                  // Outer ripple 2 (delayed)
                  Transform.scale(
                    scale: 1.0 + (((pulse + 0.5) % 1.0) * 0.45),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF06B6D4).withValues(
                          alpha: (1.0 - ((pulse + 0.5) % 1.0)) * 0.16,
                        ),
                      ),
                    ),
                  ),

                  // Glowing ambient shadow behind the card
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: isDark ? 0.45 : 0.35,
                          ),
                          blurRadius: 36,
                          spreadRadius: 8,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withValues(
                            alpha: isDark ? 0.35 : 0.25,
                          ),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(-4, -6),
                        ),
                      ],
                    ),
                  ),

                  // Liquid Glass Emblem Container
                  GlassContainer(
                    width: 108,
                    height: 108,
                    borderRadius: 30,
                    blur: 16,
                    padding: EdgeInsets.zero,
                    customGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF10B981).withValues(alpha: 0.35),
                              const Color(0xFF0F172A).withValues(alpha: 0.85),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.95),
                              const Color(0xFFE6FFFA).withValues(alpha: 0.75),
                            ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.4),
                          radius: 1.1,
                          colors: [
                            Colors.white.withValues(alpha: isDark ? 0.15 : 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Center Wallet Icon with gradient fill
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF10B981),
                                Color(0xFF06B6D4),
                              ],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),

                          // Sparkle Accent
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Transform.rotate(
                              angle: pulse * math.pi * 0.5,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 18,
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.9),
                              ),
                            ),
                          ),

                          // Coin Accent
                          Positioned(
                            bottom: 22,
                            left: 20,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF10B981),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the app title and animated subtitle
  Widget _buildAnimatedTypography(bool isDark) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Opacity(
          opacity: _titleOpacity.value,
          child: SlideTransition(
            position: _titleSlide,
            child: Column(
              children: [
                // Thai Brand Name with Gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white,
                            const Color(0xFFE2E8F0),
                            const Color(0xFF6EE7B7),
                          ]
                        : [
                            const Color(0xFF0F172A),
                            const Color(0xFF065F46),
                            const Color(0xFF10B981),
                          ],
                  ).createShader(bounds),
                  child: const Text(
                    'จดตัง',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // English Brand Subtitle
                Text(
                  'J O D  T A N G',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 5.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline in Glass Pill
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  borderRadius: 100,
                  blur: 10,
                  child: Text(
                    'จัดการเงินง่ายๆ สไตล์คุณ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the liquid progress bar and dynamic status
  Widget _buildAnimatedProgressSection(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceController,
        _progressController,
        _shimmerController,
      ]),
      builder: (context, _) {
        final progress = _progressController.value;
        final percentText = '${(progress * 100).toInt()}%';

        return Opacity(
          opacity: _progressOpacity.value,
          child: Column(
            children: [
              // Loading status label + Percentage
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dynamic message with animated switcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: Text(
                        _loadingMessage,
                        key: ValueKey<String>(_loadingMessage),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),

                    // Percentage
                    Text(
                      percentText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Progress Bar Track
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated gradient fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.02, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF10B981),
                              Color(0xFF06B6D4),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shimmer wave across progress bar
                    if (progress > 0.05 && progress < 1.0)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, _) {
                                final shimmerPos = _shimmerController.value;
                                return Transform.translate(
                                  offset: Offset(
                                    (shimmerPos * 250) - 50,
                                    0,
                                  ),
                                  child: Container(
                                    width: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.0),
                                          Colors.white.withValues(alpha: 0.7),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a subtle security & offline status badge at bottom
  Widget _buildFooter(bool isDark) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Opacity(
          opacity: _progressOpacity.value * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 5),
              Text(
                '100% ปลอดภัย บันทึกข้อมูลในเครื่องของคุณ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
