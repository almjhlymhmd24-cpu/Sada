import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:sada/screens/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ألوان الهوية البصرية لتطبيق صدى (بنفسجي -> سماوي)
  static const Color colorPurple = Color(0xFF6C3CEB);
  static const Color colorCyan = Color(0xFF78DDF8);

  // متحكم حركة النبض للوقو (SVG ثابت + Scale animation)
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    try {
      // مدة عرض السبلاش.
      await Future.delayed(const Duration(seconds: 5));

      if (!mounted) return;

      // الانتقال إلى تسجيل الدخول.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء الانتقال من شاشة البداية: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // خلفية Gradient خفيف من فوق لتحت (90 درجة)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // أبيض في الأعلى
              Color(0xFFF3F0FA), // بنفسجي فاتح جداً في الأسفل
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
           // أنيميشن خلفية Sparkles (Lottie) - يغطي الشاشة كاملة
            Positioned.fill(
              child: Lottie.asset(
                'assets/Sparkles_animation.json',
                fit: BoxFit.cover,
                repeat: true,
                // لو الملف ما طلع، بيطبع رسالة خطأ بالـ Console
                // بدل ما يفشل بصمت - يساعدنا نعرف السبب بالضبط
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('⚠️ فشل تحميل خلفية Lottie: $error');
                  return const SizedBox.shrink();
                },
              ),
            ),

            // المحتوى الرئيسي في المنتصف
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اللوقو: ملف SVG الأصلي + حركة نبض (Scale)
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => const SizedBox(
                        width: 220,
                        height: 220,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // شعار "صدى"
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [colorPurple, colorCyan],
                    ).createShader(bounds),
                    child: const Text(
                      'صدى',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontWeight: FontWeight.w700,
                        fontSize: 48,
                        color: Colors.white, // يتم استبداله بالـ ShaderMask
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // الوصف الفرعي
                  const Text(
                    'بوابتك للتواصل الصوتي',
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontWeight: FontWeight.w400,
                      fontSize: 25,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// شاشة Onboarding مؤقتة (استبدليها بشاشتك الفعلية)
// ============================================================
// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text('شاشة Onboarding'),
//       ),
//     );
//   }
// }
