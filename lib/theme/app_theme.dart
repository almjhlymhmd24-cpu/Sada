import 'package:flutter/material.dart';

/// هوية صدى البصرية الموحدة (Sada AI Visual Identity)
class AppColors {
  // ألوان الهوية الرئيسية
  static const Color primaryPurple = Color(0xFF6C3CEB);
  static const Color deepPurple = Color(0xFF4520A8);
  static const Color aiPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF55C9F4);
  static const Color cyanLight = Color(0xFF78DDF8);
  static const Color softPurple = Color(0xFFF3EEFF);
  static const Color purpleSoft = Color(0xFFF3EEFF);

  // ألوان الخلفيات والنصوص
  static const Color bg = Color(0xFFF9F8FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF17151D);
  static const Color textMuted = Color(0xFF666270);
  static const Color line = Color(0xFFE9E5F2);
  static const Color border = Color(0xFFE9E5F2);

  // ألوان الحالة
  static const Color success = Color(0xFF1FB87A);
  static const Color danger = Color(0xFFE0538A);
  static const Color warning = Color(0xFFEE9C3D);

  // تدرجات لونية مميزة
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, accentCyan],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF7B4AF0), deepPurple],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [aiPurple, primaryPurple],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryPurple, Color(0xFF7A3EC8)],
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Baloo_Bhaijaan_2',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentCyan,
        surface: AppColors.card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textDark,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
          fontSize: 28,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          fontSize: 22,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          fontSize: 15,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          color: AppColors.textDark,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          color: AppColors.textMuted,
          fontSize: 13,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
