import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';

  // Primary colors for text styles
  static const Color primaryTextColor = Colors.black;
  static const Color secondaryTextColor = Colors.white54;
  static const Color accentTextColor = Color(0xFF9ACD32); // Lime green accent

  // Heading styles
  static TextStyle heading1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 55,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -2.5,
    height: 1.0,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle heading2BoldClose = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: -3.0,
    height: 1.3,
  );

  static TextStyle heading3 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500, // SemiBold
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle heading4 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500, // SemiBold
    letterSpacing: -0.3,
    height: 1.3,
  );

  // Body text styles
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: -0.2,
    height: 1.5,
  );

  static TextStyle bodyLargeBold = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Regular
    letterSpacing: -0.2,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: -0.1,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodySmallOrangeAccent = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.secondaryOrange,
  );

  static TextStyle bodyMediumGreenAccent = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0,
      height: 1.5,
      color: AppColors.secondaryGreen);

  static TextStyle bodyMediumYellowAccent = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0,
      height: 1.5,
      color: AppColors.secondaryYellow);

  static TextStyle bodyMediumOrangeAccent = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0,
      height: 1.5,
      color: AppColors.secondaryOrange);

  static TextStyle bodyMediumRedAccent = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0,
      height: 1.5,
      color: AppColors.secondaryRed);

  // Button text styles
  static TextStyle buttonTextBlack = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -2.0,
    height: 1.1,
    color: AppColors.primaryBlack,
  );

  static TextStyle buttonSubTextBlack = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -2.0,
    height: 1.1,
    color: AppColors.primaryBlack,
  );

  static TextStyle buttonTextWhite = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -2.0,
    height: 1.1,
    color: AppColors.primaryWhite,
  );

  // Caption and label styles
  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: -0.5,
    height: 1.4,
  );

  static TextStyle overline = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
    height: 1.4,
    textBaseline: TextBaseline.alphabetic,
  );

  // Special styles for onboarding
  static TextStyle onboardingTitle = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w200, // Thin
    letterSpacing: -2.5,
    height: 1.1,
    color: Colors.white,
  );

  static TextStyle onboardingAccent = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: -2.0,
    height: 1.1,
    color: Color(0xFF9ACD32),
  );

  static TextStyle greenAccentText = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600, // Regular
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.secondaryGreen,
  );

  static TextStyle orangeAccentText = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600, // Regular
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.secondaryOrange,
  );

  static TextStyle redAccentText = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600, // Regular
    letterSpacing: -1.0,
    height: 1.1,
    color: AppColors.secondaryRed,
  );
  // Helper methods for common modifications
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
