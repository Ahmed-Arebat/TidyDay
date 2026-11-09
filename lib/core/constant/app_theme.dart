import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const ink = Color(0xFF171B32);
  static const muted = Color(0xFF565C76);
  static const canvas = Color(0xFFF8F9FD);
  static const line = Color(0xFFE5E7F3);
  static const soft = Color(0xFFEEEDFF);
}

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surface: Colors.white,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    outlineVariant: AppColors.line,
  ),
  scaffoldBackgroundColor: AppColors.canvas,
  dividerColor: AppColors.line,
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.canvas,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.line),
    ),
  ),
);
