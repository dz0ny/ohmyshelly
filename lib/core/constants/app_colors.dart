import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color - Shelly blue
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryLight = Color(0xFF7AB3E8);
  static const Color primaryDark = Color(0xFF2E6EAD);

  // Secondary - Complementary teal
  static const Color secondary = Color(0xFF00BCD4);
  static const Color secondaryLight = Color(0xFF4DD0E1);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Device type colors
  static const Color powerDevice = Color(0xFFFF9800);
  static const Color weatherStation = Color(0xFF00BCD4);
  static const Color gateway = Color(0xFF9C27B0);
  static const Color scene = Color(0xFF7E57C2); // Purple for scenes

  // Appliance type colors (relay_usage)
  static const Color heating = Color(0xFFE53935); // Red for heating
  static const Color lighting = Color(0xFFFFC107); // Amber for lighting
  static const Color entertainment = Color(0xFF673AB7); // Deep purple for entertainment
  static const Color refrigeration = Color(0xFF03A9F4); // Light blue for refrigeration
  static const Color laundry = Color(0xFF00BCD4); // Cyan for laundry
  static const Color cooking = Color(0xFFFF5722); // Deep orange for cooking
  static const Color poolAndGarden = Color(0xFF4CAF50); // Green for pool/garden
  static const Color electricVehicle = Color(0xFF8BC34A); // Light green for EV
  static const Color ventilation = Color(0xFF607D8B); // Blue grey for ventilation
  static const Color waterHeater = Color(0xFFFF7043); // Deep orange for water heater
  static const Color roller = Color(0xFF795548); // Brown for roller
  static const Color garageDoor = Color(0xFF546E7A); // Blue grey for garage

  // On/Off states
  static const Color deviceOn = Color(0xFF4CAF50);
  static const Color deviceOff = Color(0xFF9E9E9E);

  // ============ LIGHT THEME COLORS ============
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  // Text - Light theme
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Borders - Light theme
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ============ DARK THEME COLORS ============
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  // Container colors for dark mode (nested elements)
  static const Color surfaceContainerDark = Color(0xFF1F1F1F);
  static const Color surfaceContainerHighDark = Color(0xFF282828);
  static const Color surfaceContainerHighestDark = Color(0xFF353535);

  // Text - Dark theme (high contrast)
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF808080);

  // Borders - Dark theme
  static const Color borderDark = Color(0xFF404040);
  static const Color dividerDark = Color(0xFF2D2D2D);

  // Card colors for dark mode
  static const Color cardDark = Color(0xFF1E1E1E);
}
