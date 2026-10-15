import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Liquid Glass styled Card with frosted blur and subtle reflections.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;
  final double blur;
  final BoxBorder? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius = 22,
    this.blur = 0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding,
      margin: margin,
      onTap: onTap,
      tintColor: color,
      borderRadius: borderRadius,
      blur: blur,
      customBorder: border,
      child: child,
    );
  }
}
