import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../core/glass_container.dart';
import '../../../../data/services/security_service.dart';

enum PinScreenMode {
  unlock,
  create,
  confirm,
  changeOld,
}

class PinScreen extends StatefulWidget {
  final PinScreenMode mode;
  final String? firstPin; // For confirm mode
  final Function(String pin)? onPinVerifiedOrCreated;
  final VoidCallback? onCancel;

  const PinScreen({
    super.key,
    this.mode = PinScreenMode.unlock,
    this.firstPin,
    this.onPinVerifiedOrCreated,
    this.onCancel,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final SecurityService _securityService = SecurityService();
  String _enteredPin = '';
  String? _errorMessage;
  bool _isVerifying = false;
  static const int _pinLength = 4;

  void _onKeyPressed(String key) {
    if (_isVerifying) return;
    if (_enteredPin.length < _pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        _errorMessage = null;
        _enteredPin += key;
      });

      if (_enteredPin.length == _pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _onBackspace() {
    if (_isVerifying) return;
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _errorMessage = null;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _onClearAll() {
    if (_isVerifying) return;
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _errorMessage = null;
        _enteredPin = '';
      });
    }
  }

  Future<void> _handlePinComplete() async {
    final pin = _enteredPin;
    _isVerifying = true;

    if (widget.mode == PinScreenMode.unlock) {
      final isValid = await _securityService.verifyPin(pin);
      if (isValid) {
        HapticFeedback.mediumImpact();
        widget.onPinVerifiedOrCreated?.call(pin);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _enteredPin = '';
          _isVerifying = false;
          _errorMessage = 'รหัส PIN ไม่ถูกต้อง กรุณาลองใหม่';
        });
      }
    } else if (widget.mode == PinScreenMode.create) {
      // Navigate to confirm PIN
      if (mounted) {
        final confirmed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PinScreen(
              mode: PinScreenMode.confirm,
              firstPin: pin,
              onPinVerifiedOrCreated: (confirmedPin) async {
                await _securityService.setPin(confirmedPin);
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ),
        );
        if (confirmed == true && mounted) {
          widget.onPinVerifiedOrCreated?.call(pin);
        } else {
          setState(() {
            _enteredPin = '';
            _isVerifying = false;
          });
        }
      }
    } else if (widget.mode == PinScreenMode.confirm) {
      if (pin == widget.firstPin) {
        HapticFeedback.mediumImpact();
        widget.onPinVerifiedOrCreated?.call(pin);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _enteredPin = '';
          _isVerifying = false;
          _errorMessage = 'รหัส PIN ไม่ตรงกัน กรุณาลองใหม่';
        });
      }
    } else if (widget.mode == PinScreenMode.changeOld) {
      final isValid = await _securityService.verifyPin(pin);
      if (isValid && mounted) {
        // Move to create new pin
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PinScreen(
              mode: PinScreenMode.create,
              onPinVerifiedOrCreated: widget.onPinVerifiedOrCreated,
            ),
          ),
        );
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _enteredPin = '';
          _isVerifying = false;
          _errorMessage = 'รหัส PIN เดิมไม่ถูกต้อง';
        });
      }
    }
  }

  String get _title {
    switch (widget.mode) {
      case PinScreenMode.unlock:
        return 'ใส่รหัส PIN เพื่อปลดล็อก';
      case PinScreenMode.create:
        return 'ตั้งรหัส PIN ใหม่ (4 หลัก)';
      case PinScreenMode.confirm:
        return 'ยืนยันรหัส PIN อีกครั้ง';
      case PinScreenMode.changeOld:
        return 'ใส่รหัส PIN เดิม';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.mode != PinScreenMode.unlock
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: overlayStyle,
                    leading: widget.onCancel != null
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: widget.onCancel,
                          )
                        : null,
                  )
                : null,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  // Liquid Glass Lock Icon
                  GlassContainer(
                    width: 90,
                    height: 90,
                    borderRadius: 45,
                    blur: 24,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    customBorder: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    customShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    child: const Icon(Icons.lock_outline_rounded, size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle / Error
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600),
                    )
                  else
                    Text(
                      'แอปพลิเคชัน จดตัง รักษาข้อมูลส่วนตัวของคุณ',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // PIN Dots Indicator (Liquid Glow)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (index) {
                      final isFilled = index < _enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isFilled ? AppColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFilled
                                ? AppColors.primary
                                : (isDark ? Colors.white38 : Colors.grey.shade400),
                            width: 2,
                          ),
                          boxShadow: isFilled
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Keypad
                  _buildKeypad(),
                  const SizedBox(height: 32),
                ],
            ),
          ),
        ),
      );
  }

  Widget _buildKeypad() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _keypadButton('1'),
                  _keypadButton('2'),
                  _keypadButton('3'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _keypadButton('4'),
                  _keypadButton('5'),
                  _keypadButton('6'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _keypadButton('7'),
                  _keypadButton('8'),
                  _keypadButton('9'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Empty space to balance layout with 0 centered
                  const SizedBox(width: 74, height: 74),

                  _keypadButton('0'),

                  // Backspace (Tap to delete one, Long-press to clear all)
                  _KeypadCell(
                    onTap: _onBackspace,
                    onLongPress: _onClearAll,
                    child: const Icon(
                      Icons.backspace_outlined,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keypadButton(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _KeypadCell(
      onTap: () => _onKeyPressed(digit),
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}

/// An ultra-responsive tactile keypad cell with instant touch feedback
class _KeypadCell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _KeypadCell({
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<_KeypadCell> createState() => _KeypadCellState();
}

class _KeypadCellState extends State<_KeypadCell> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 74,
          height: 74,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPressed
                  ? [
                      AppColors.primary.withValues(alpha: isDark ? 0.40 : 0.28),
                      AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                    ]
                  : [
                      isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.88)
                          : Colors.white.withValues(alpha: 0.95),
                      isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.72)
                          : Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.80)),
              width: _isPressed ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.30)
                        : const Color(0xFF0F172A).withValues(alpha: 0.08)),
                blurRadius: _isPressed ? 14 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
