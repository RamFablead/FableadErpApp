import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'app_colors.dart';

class AppStyles {
  static const String fontFamily = 'CustomFont';

  static TextStyle titleLarge(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 26.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.sp,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.sp,
      fontWeight: FontWeight.normal,
      color: AppColors.textLight,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 1.0,
    );
  }
}
