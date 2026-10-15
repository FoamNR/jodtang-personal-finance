import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFFD1FAE5);

  // Income / Expense / Transfer
  static const Color income = Color(0xFF10B981); // Emerald
  static const Color expense = Color(0xFFEF4444); // Crimson / Coral
  static const Color transfer = Color(0xFF3B82F6); // Royal Blue

  // Neutrals (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutrals (Dark)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Liquid Glass Tokens
  static const Color glassLight = Color(0xB8FFFFFF);
  static const Color glassLightBorder = Color(0xA6FFFFFF);
  static const Color glassDark = Color(0x991E293B);
  static const Color glassDarkBorder = Color(0x26FFFFFF);

  // Accent Colors for Categories & Wallets
  static const List<Color> palette = [
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo
    Color(0xFF64748B), // Slate
  ];
}
