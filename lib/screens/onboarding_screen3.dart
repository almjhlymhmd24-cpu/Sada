import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:sada/screens/home_screen.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  static const Color primaryPurple = Color(0xFF6C3CEB);
  static const Color accentCyan = Color(0xFF55C9F4);
  static const Color darkText = Color(0xFF17151D);
  static const Color grayText = Color(0xFF666270);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Column(
            children: [
              // شريط علوي: شعار صدى
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 22,
                        child: SvgPicture.asset(
                          'assets/logo.svg',
                          width: 22,
                          height: 22,
                          placeholderBuilder: (context) => const Icon(
                            Icons.record_voice_over_rounded,
                            size: 22,
                            color: primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'صدى',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      '',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: grayText,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // الرسمة (SVG)
              Expanded(
                flex: 5,
                child: Center(
                  child: Lottie.asset(
                    'assets/mic.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // العنوان
              const Text(
                'صوتك يستحق أن يُسمع',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 12),

              // الوصف
              const Text(
                'دع صدى يحوّل كلماتك إلى تجربة تفاعلية ممتعة\nتحدث بطريقتك وعبر عن نفسك بكل حرية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 15,
                  height: 1.6,
                  color: grayText,
                ),
              ),

              const SizedBox(height: 28),

              // مؤشر الصفحات (dots) - الثالثة نشطة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: false),
                  const SizedBox(width: 6),
                  _buildDot(isActive: false),
                  const SizedBox(width: 6),
                  _buildDot(isActive: true),
                ],
              ),

              const SizedBox(height: 28),

              // زر ابدأ الآن
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [primaryPurple, accentCyan],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withValues(alpha:  0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'ابدأ الآن',
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? primaryPurple : const Color(0xFFD9DCE3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
