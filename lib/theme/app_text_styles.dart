import 'package:flutter/material.dart';

/// App Text Styles & Font Sizes
/// Centralized configuration for all text styles and font sizes
/// This allows easy modification of font sizes across the entire app
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // ==================== FONT SIZES ====================

  // Display & Heading Sizes
  static const double displayLarge = 32.0;
  static const double displayMedium = 28.0;
  static const double displaySmall = 24.0;
  static const double headlineMedium = 20.0;

  // Title Sizes
  static const double titleLarge = 18.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 15.0;

  // Body Text Sizes
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 13.0;
  static const double bodyExtraSmall = 12.0;

  // Special Sizes
  static const double caption = 12.0;
  static const double badge = 10.0;
  static const double hint = 14.0;

  // Avatar Text
  static const double avatarLarge = 48.0;
  static const double avatarMedium = 16.0;

  // Button Text
  static const double button = 16.0;
  static const double buttonSmall = 13.0;

  // ==================== TEXT STYLES ====================

  // Display Styles
  static const TextStyle displayLargeStyle = TextStyle(
    fontSize: displayLarge,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displayMediumStyle = TextStyle(
    fontSize: displayMedium,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displaySmallStyle = TextStyle(
    fontSize: displaySmall,
    fontWeight: FontWeight.w600,
  );

  // Heading Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: headlineMedium,
    fontWeight: FontWeight.w600,
  );

  // Title Styles
  static const TextStyle titleLargeStyle = TextStyle(
    fontSize: titleLarge,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMediumStyle = TextStyle(
    fontSize: titleMedium,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleSmallStyle = TextStyle(
    fontSize: titleSmall,
    fontWeight: FontWeight.w600,
  );

  // Body Styles
  static const TextStyle bodyLargeStyle = TextStyle(fontSize: bodyLarge);

  static const TextStyle bodyMediumStyle = TextStyle(fontSize: bodyMedium);

  static const TextStyle bodySmallStyle = TextStyle(fontSize: bodySmall);

  static const TextStyle bodyExtraSmallStyle = TextStyle(
    fontSize: bodyExtraSmall,
  );

  // Special Styles
  static const TextStyle captionStyle = TextStyle(fontSize: caption);

  static const TextStyle badgeStyle = TextStyle(
    fontSize: badge,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle hintStyle = TextStyle(fontSize: hint);

  // Avatar Styles
  static const TextStyle avatarLargeStyle = TextStyle(
    fontSize: avatarLarge,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle avatarMediumStyle = TextStyle(
    fontSize: avatarMedium,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Button Styles
  static const TextStyle buttonStyle = TextStyle(
    fontSize: button,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmallStyle = TextStyle(
    fontSize: buttonSmall,
    fontWeight: FontWeight.w400,
  );

  // ==================== HELPER METHODS ====================

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
