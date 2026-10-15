import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium Liquid Glass (Glassmorphism) container with frosted backdrop blur,
/// translucent iridescent gradients, and subtle specular highlight borders.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final double? width;
  final double? height;
  final BoxBorder? customBorder;
  final List<BoxShadow>? customShadow;
  final AlignmentGeometry? alignment;
  final Gradient? customGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 22,
    this.blur = 18,
    this.tintColor,
    this.width,
    this.height,
    this.customBorder,
    this.customShadow,
    this.alignment,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Specular highlight border: creates realistic glass thickness and light reflection
    final defaultBorder = customBorder ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.65),
          width: 1.2,
        );

    // Liquid glass gradient reflection (richer alpha when blur <= 0 for zero-cost frosted glass)
    final glassGradient = customGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: blur <= 0
              ? (isDark
                  ? [
                      (tintColor ?? const Color(0xFF1E293B)).withValues(alpha: 0.82),
                      (tintColor ?? const Color(0xFF0F172A)).withValues(alpha: 0.65),
                    ]
                  : [
                      (tintColor ?? Colors.white).withValues(alpha: 0.88),
                      (tintColor ?? Colors.white).withValues(alpha: 0.68),
                    ])
              : (isDark
                  ? [
                      (tintColor ?? const Color(0xFF1E293B)).withValues(alpha: 0.65),
                      (tintColor ?? const Color(0xFF0F172A)).withValues(alpha: 0.45),
                    ]
                  : [
                      (tintColor ?? Colors.white).withValues(alpha: 0.72),
                      (tintColor ?? Colors.white).withValues(alpha: 0.42),
                    ]),
        );

    final defaultShadow = customShadow ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: glassGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: defaultBorder,
        boxShadow: defaultShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
          highlightColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
          child: Container(
            width: width,
            height: height,
            alignment: alignment,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    // Performance shortcut: Avoid costly BackdropFilter when blur is disabled
    if (blur <= 0) {
      if (margin != null) {
        return Container(
          margin: margin,
          child: content,
        );
      }
      return content;
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );
  }
}
