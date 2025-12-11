import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color - Shelly orange
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F66);
  static const Color primaryDark = Color(0xFFE55A2B);

  // Secondary - Complementary blue
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Device type colors
  static const Color powerDevice = Color(0xFFFF9800);
  static const Color weatherStation = Color(0xFF00BCD4);
  static const Color gateway = Color(0xFF9C27B0);
  static const Color heating = Color(0xFFE53935); // Red/orange for heating devices

  // On/Off states
  static const Color deviceOn = Color(0xFF4CAF50);
  static const Color deviceOff = Color(0xFF9E9E9E);

  // Backgrounds
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
}
