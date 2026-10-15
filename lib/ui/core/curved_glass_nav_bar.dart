import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Path generator for the Curved Liquid Glass Navigation Bar.
/// Creates a smooth organic wave crest in the center that cradles the elevated add button.
Path getCurvedNavBarPath(
  Size size, {
  double bulge = 16.0,
  double spread = 46.0,
  double cornerRadius = 28.0,
}) {
  final path = Path();
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final r = cornerRadius;
  final topY = bulge;

  final crestStartX = cx - spread;
  final crestEndX = cx + spread;

  // 1. Start after top-left corner
  path.moveTo(r, topY);

  // 2. Line to start of crest
  path.lineTo(crestStartX, topY);

  // 3. Smooth upward cubic bezier curve to peak (cx, 0)
  path.cubicTo(
    cx - spread * 0.55,
    topY,
    cx - spread * 0.45,
    0,
    cx,
    0,
  );

  // 4. Smooth downward cubic bezier curve from peak (cx, 0) back to baseline
  path.cubicTo(
    cx + spread * 0.45,
    0,
    cx + spread * 0.55,
    topY,
    crestEndX,
    topY,
  );

  // 5. Line to top-right corner
  path.lineTo(w - r, topY);

  // 6. Top-right corner
  path.arcToPoint(
    Offset(w, topY + r),
    radius: Radius.circular(r),
    clockwise: true,
  );

  // 7. Right edge
  path.lineTo(w, h - r);

  // 8. Bottom-right corner
  path.arcToPoint(
    Offset(w - r, h),
    radius: Radius.circular(r),
    clockwise: true,
  );

  // 9. Bottom edge
  path.lineTo(r, h);

  // 10. Bottom-left corner
  path.arcToPoint(
    Offset(0, h - r),
    radius: Radius.circular(r),
    clockwise: true,
  );

  // 11. Left edge
  path.lineTo(0, topY + r);

  // 12. Top-left corner
  path.arcToPoint(
    Offset(r, topY),
    radius: Radius.circular(r),
    clockwise: true,
  );

  path.close();
  return path;
}

/// Custom clipper that clips the backdrop blur filter along the curved navbar path.
class CurvedNavBarClipper extends CustomClipper<Path> {
  final double bulge;
  final double spread;
  final double cornerRadius;

  const CurvedNavBarClipper({
    this.bulge = 16.0,
    this.spread = 46.0,
    this.cornerRadius = 28.0,
  });

  @override
  Path getClip(Size size) {
    return getCurvedNavBarPath(
      size,
      bulge: bulge,
      spread: spread,
      cornerRadius: cornerRadius,
    );
  }

  @override
  bool shouldReclip(covariant CurvedNavBarClipper oldClipper) =>
      oldClipper.bulge != bulge ||
      oldClipper.spread != spread ||
      oldClipper.cornerRadius != cornerRadius;
}

/// Custom painter for the frosted glass gradient and specular border.
class CurvedNavBarPainter extends CustomPainter {
  final bool isDark;
  final double bulge;
  final double spread;
  final double cornerRadius;

  CurvedNavBarPainter({
    required this.isDark,
    this.bulge = 16.0,
    this.spread = 46.0,
    this.cornerRadius = 28.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = getCurvedNavBarPath(
      size,
      bulge: bulge,
      spread: spread,
      cornerRadius: cornerRadius,
    );

    // 1. Translucent Liquid Glass Fill Gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF1E293B).withValues(alpha: 0.72),
                const Color(0xFF0F172A).withValues(alpha: 0.52),
              ]
            : [
                Colors.white.withValues(alpha: 0.82),
                Colors.white.withValues(alpha: 0.52),
              ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fillPaint);

    // 2. Specular Highlight Stroke Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.30),
                Colors.white.withValues(alpha: 0.10),
              ]
            : [
                Colors.white.withValues(alpha: 0.90),
                Colors.white.withValues(alpha: 0.40),
              ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CurvedNavBarPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Custom painter for the ambient drop shadow under the curved navbar.
class CurvedNavBarShadowPainter extends CustomPainter {
  final bool isDark;
  final double bulge;
  final double spread;
  final double cornerRadius;

  CurvedNavBarShadowPainter({
    required this.isDark,
    this.bulge = 16.0,
    this.spread = 46.0,
    this.cornerRadius = 28.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = getCurvedNavBarPath(
      size,
      bulge: bulge,
      spread: spread,
      cornerRadius: cornerRadius,
    );

    final shadowPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.45)
          : const Color(0xFF0F172A).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.save();
    canvas.translate(0, 6);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CurvedNavBarShadowPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// A premium Liquid Glass Navigation Bar with an organic center crest
/// that gracefully enlarges to cradle the center plus button.
class CurvedGlassNavBar extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;
  final double bulge;
  final double spread;
  final double totalHeight;
  final double cornerRadius;

  const CurvedGlassNavBar({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
    this.bulge = 16.0,
    this.spread = 46.0,
    this.totalHeight = 78.0,
    this.cornerRadius = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Ambient Drop Shadow along curved path
            Positioned.fill(
              child: CustomPaint(
                painter: CurvedNavBarShadowPainter(
                  isDark: isDark,
                  bulge: bulge,
                  spread: spread,
                  cornerRadius: cornerRadius,
                ),
              ),
            ),

            // 2. Frosted Backdrop Blur & Liquid Glass Fill
            Positioned.fill(
              child: ClipPath(
                clipper: CurvedNavBarClipper(
                  bulge: bulge,
                  spread: spread,
                  cornerRadius: cornerRadius,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: CustomPaint(
                    painter: CurvedNavBarPainter(
                      isDark: isDark,
                      bulge: bulge,
                      spread: spread,
                      cornerRadius: cornerRadius,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Navigation Items & Center Plus Button
          Positioned.fill(
            child: Row(
              children: [
                // Left wing: หน้าหลัก, รายการ
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: bulge),
                    child: Row(
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                          label: 'หน้าหลัก',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.receipt_long_outlined,
                          selectedIcon: Icons.receipt_long_rounded,
                          label: 'รายการ',
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Plus Button: perfectly centered within the elevated crest
                _buildCenterAddButton(),

                // Right wing: สถิติ, ตั้งค่า
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: bulge),
                    child: Row(
                      children: [
                        _buildNavItem(
                          index: 2,
                          icon: Icons.pie_chart_outline_rounded,
                          selectedIcon: Icons.pie_chart_rounded,
                          label: 'สถิติ',
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.settings_outlined,
                          selectedIcon: Icons.settings_rounded,
                          label: 'ตั้งค่า',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCenterAddButton() {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF34D399),
            Color(0xFF059669),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.6,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onAddTap,
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    size: 24,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
