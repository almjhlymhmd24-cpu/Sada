import 'package:flutter/material.dart';

/// هوية صدى البصرية الموحدة
/// مستوحاة من الشعار: أزرق + سماوي + أبيض
class AppColors {
  // ============================================================
  // ألوان الهوية الرئيسية
  // حافظنا على أسماء المتغيرات القديمة حتى لا تنكسر الصفحات
  // ============================================================

  // كان بنفسجي - أصبح أزرق رئيسي
  static const Color primaryPurple = Color(0xFF2348D8);

  // أزرق داكن
  static const Color deepPurple = Color(0xFF1737A6);

  // أزرق متوسط مائل للسماوي
  static const Color aiPurple = Color(0xFF2874DD);

  // السماوي الموجود في الشعار
  static const Color accentCyan = Color(0xFF27C8CE);

  // سماوي فاتح
  static const Color cyanLight = Color(0xFF62DFE1);

  // خلفيات خفيفة
  static const Color softPurple = Color(0xFFEFF5FF);
  static const Color purpleSoft = Color(0xFFEFF5FF);

  // ألوان إضافية لهوية الشعار
  static const Color primaryBlue = Color(0xFF2348D8);
  static const Color royalBlue = Color(0xFF2864DB);
  static const Color skyBlue = Color(0xFF2FA8E2);

  static const Color softBlue = Color(0xFFEFF5FF);
  static const Color softCyan = Color(0xFFEAFBFB);

  // ============================================================
  // الخلفيات والنصوص
  // ============================================================

  static const Color bg = Color(0xFFF7FAFD);
  static const Color card = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF183153);
  static const Color textMuted = Color(0xFF6D7B93);

  static const Color line = Color(0xFFDDE7F3);
  static const Color border = Color(0xFFDDE7F3);

  // ============================================================
  // ألوان الحالة
  // ============================================================

  static const Color success = Color(0xFF22B573);
  static const Color danger = Color(0xFFE6535F);
  static const Color warning = Color(0xFFF3A738);

  // ============================================================
  // التدرجات
  // ============================================================

  // التدرج الأساسي المستوحى من الشعار
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      accentCyan,
      skyBlue,
      primaryBlue,
    ],
  );

  // بطاقة صدى الرئيسية
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF2ED1CC),
      Color(0xFF2B9FDF),
      Color(0xFF2348D8),
    ],
    stops: [
      0.0,
      0.52,
      1.0,
    ],
  );

  // عناصر الذكاء الاصطناعي
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF27C8CE),
      Color(0xFF2874DD),
      Color(0xFF2348D8),
    ],
  );

  // حافظنا على الاسم القديم
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF2FA8E2),
      Color(0xFF2348D8),
    ],
  );

  // مناسب للـ Bottom Navigation
  static const LinearGradient navActiveGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2FD2CD),
      Color(0xFF2454D8),
    ],
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Baloo_Bhaijaan_2',

      scaffoldBackgroundColor: AppColors.bg,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.card,
      ),

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.textDark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textDark,
        ),
      ),

      // ========================================================
      // TEXT
      // ========================================================

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

      // ========================================================
      // BUTTONS
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          color: AppColors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.accentCyan,
            width: 1.5,
          ),
        ),
      ),

      // ========================================================
      // PROGRESS
      // ========================================================

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentCyan,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: const TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
      ),
    );
  }
}
