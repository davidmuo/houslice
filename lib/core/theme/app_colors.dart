import 'package:flutter/material.dart';

/// Central colour palette extracted from the Houseslice Figma design.
abstract final class AppColors {
  static const primary = Color(0xFFF98A2C);
  static const primaryDark = Color(0xFFE07716);
  static const primarySoft = Color(0xFFFDDCBB);
  static const primaryFaint = Color(0xFFFFF3E7);

  static const dark = Color(0xFF222B45);
  static const grey = Color(0xFF9CA4AB);
  static const border = Color(0xFFE9EBEE);
  static const surface = Color(0xFFF7F8FA);

  static const success = Color(0xFF2AA871);
  static const successSoft = Color(0xFFD9F2E6);
  static const danger = Color(0xFFEE6A5F);
  static const dangerSoft = Color(0xFFFDE8E4);
  static const star = Color(0xFFF5B940);
  static const compatibilitySoft = Color(0xFFFDF3D7);

  // ---------- Dark mode ----------
  // Contrast ratios against [darkBackground] were chosen to clear WCAG AA
  // (4.5:1) for body text: darkText ~15.8:1, darkGrey ~7.4:1, primary ~6.9:1.
  static const darkBackground = Color(0xFF12151F);
  static const darkSurface = Color(0xFF1C2135);
  static const darkBorder = Color(0xFF2C3247);
  static const darkText = Color(0xFFF2F4F8);
  static const darkGrey = Color(0xFFA8B0BD);
}
