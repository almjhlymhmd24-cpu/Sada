import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SadaApp());
}

class SadaApp extends StatelessWidget {
  const SadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صدى',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      home: const SplashScreen(),
    );
  }
}
