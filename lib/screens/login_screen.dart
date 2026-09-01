import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:sada/screens/signup_screen.dart';
import 'package:sada/screens/home_screen.dart';
import 'package:sada/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  static const Color primaryPurple = Color(0xFF6C3CEB);
  static const Color accentCyan = Color(0xFF55C9F4);
  static const Color lightBackground = Color(0xFFF9F8FC);
  static const Color textDark = Color(0xFF17151D);
  static const Color textMuted = Color(0xFF666270);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        _goToHome();
      } else {
        setState(() => _isLoading = false);
        _showError('تعذر تسجيل الدخول، تأكد من صحة البيانات وحاول مجدداً');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('تعذر الاتصال بالخادم، تأكدي من الإنترنت وحاولي مرة أخرى');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showInfoMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // فرض اتجاه التطبيق من اليمين لليسار
      child: Scaffold(
        backgroundColor: lightBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SoundWaveBackgroundPainter(
                  color1: primaryPurple.withValues(alpha:  0.05),
                  color2: accentCyan.withValues( alpha: .06),
                ),
              ),
             ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  children: [
                    // 1. شعار صدى في طرف الشاشة من الأعلى تماماً
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'صدى',
                              style: TextStyle(
                                fontFamily: 'Baloo_Bhaijaan_2',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              height: 20,
                              child: SvgPicture.asset(
                                'assets/logo.svg',
                                width: 20,
                                height: 20,
                                placeholderBuilder: (context) => const Icon(
                                  Icons.record_voice_over_rounded,
                                  size: 20,
                                  color: primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. بقية المحتوى (البطاقة وحقول تسجيل الدخول) تتوسط الشاشة
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(28),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withValues(alpha:  0.55),
                                                Colors.white.withValues(alpha:  0.28),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha:  0.6),
                                              width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryPurple.withValues(alpha:  0.20),
                                                blurRadius: 30,
                                                offset: const Offset(0, 16),
                                              ),
                                              BoxShadow(
                                                color: accentCyan.withValues(alpha:  0.12),
                                                blurRadius: 20,
                                                offset: const Offset(0, -4),
                                              ),
                                            ],
                                          ),
                                          child: Form(
                                            key: _formKey,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                const Text(
                                                  'تسجيل الدخول',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'Baloo_Bhaijaan_2',
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                _LightTextField(
                                                  controller: _emailController,
                                                  hintText: 'البريد الإلكتروني',
                                                  icon: Icons.email_outlined,
                                                  keyboardType: TextInputType.emailAddress,
                                                  accentColor: primaryPurple,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'يرجى إدخال البريد الإلكتروني';
                                                    }
                                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                        .hasMatch(value)) {
                                                      return 'بريد إلكتروني غير صالح';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                _LightTextField(
                                                  controller: _passwordController,
                                                  hintText: 'كلمة المرور',
                                                  icon: Icons.lock_outline_rounded,
                                                  obscureText: !_isPasswordVisible,
                                                  accentColor: primaryPurple,
                                                  suffixWidget: IconButton(
                                                    icon: Icon(
                                                      _isPasswordVisible
                                                          ? Icons.visibility_outlined
                                                          : Icons.visibility_off_outlined,
                                                      color: textMuted,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isPasswordVisible = !_isPasswordVisible;
                                                      });
                                                    },
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'يرجى إدخال كلمة المرور';
                                                    }
                                                    if (value.length < 6) {
                                                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: TextButton(
                                                    onPressed: () => _showInfoMessage('ميزة استعادة كلمة المرور ستتوفر قريباً'),
                                                    child: const Text(
                                                      'نسيت كلمة المرور؟',
                                                      style: TextStyle(
                                                        color: primaryPurple,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _GlowButton(
                                                  isLoading: _isLoading,
                                                  label: 'دخول',
                                                  gradient: const LinearGradient(
                                                    colors: [primaryPurple, accentCyan],
                                                  ),
                                                  glowColor: primaryPurple,
                                                  textColor: Colors.white,
                                                  onPressed: _onLoginPressed,
                                                ),
                                                const SizedBox(height: 20),
                                                const Row(
                                                  children: [
                                                    Expanded(
                                                        child: Divider(
                                                            color: Colors.black12)),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                      child: Text(
                                                        'أو عبر',
                                                        style: TextStyle(
                                                            color: textMuted,
                                                            fontSize: 11),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Divider(
                                                            color: Colors.black12)),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    _SocialButton(
                                                      iconData: Icons.facebook_rounded,
                                                      iconColor: const Color(0xFF1877F2),
                                                      onTap: () => _showInfoMessage('تسجيل الدخول عبر الحسابات الاجتماعية غير متاح حالياً'),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    _SocialButton(
                                                      svgAssetPath: 'assets/google_icon.svg',
                                                      onTap: () => _showInfoMessage('تسجيل الدخول عبر الحسابات الاجتماعية غير متاح حالياً'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -55,
                                    child: SvgPicture.asset(
                                      'assets/people_illustration.svg',
                                      height: 160,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) =>
                                          const SizedBox(height: 160),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'ليس لديك حساب؟ ',
                                    style: TextStyle(color: textMuted, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const SignUpScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'إنشاء حساب جديد',
                                      style: TextStyle(
                                        color: primaryPurple,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Color accentColor;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;

  const _LightTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    required this.accentColor,
    this.suffixWidget,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Color(0xFF17151D), fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF666270), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF666270), size: 20),
        suffixIcon: suffixWidget,
        filled: true,
        fillColor: const Color(0xFFF9F8FC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues( alpha: .2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha:  0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color glowColor;
  final Color textColor;
  final String label;

  const _GlowButton({
    required this.isLoading,
    required this.onPressed,
    required this.gradient,
    required this.glowColor,
    required this.textColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues( alpha: .25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: textColor,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? iconData;
  final Color? iconColor;
  final String? svgAssetPath;
  final VoidCallback onTap;

  const _SocialButton({
    this.iconData,
    this.iconColor,
    this.svgAssetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFFF9F8FC),
          border: Border.all(color: Colors.grey.withValues(alpha:  0.2)),
        ),
        child: Center(
          child: svgAssetPath != null
              ? SvgPicture.asset(
                  svgAssetPath!,
                  width: 24,
                  height: 24,
                )
              : Icon(iconData, color: iconColor, size: 28),
        ),
      ),
    );
  }
}

class _SoundWaveBackgroundPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  _SoundWaveBackgroundPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    _drawWaveCluster(
      canvas,
      origin: Offset(size.width * 0.08, size.height * 0.06),
      barCount: 7,
      color: color1,
      maxHeight: 46,
    );

    _drawWaveCluster(
      canvas,
      origin: Offset(size.width * 0.72, size.height * 0.88),
      barCount: 7,
      color: color2,
      maxHeight: 46,
    );
  }

  void _drawWaveCluster(
    Canvas canvas, {
    required Offset origin,
    required int barCount,
    required Color color,
    required double maxHeight,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const barWidth = 4.0;
    const gap = 6.0;

    for (int i = 0; i < barCount; i++) {
      final t = i / (barCount - 1);
      final heightFactor = math.sin(t * math.pi);
      final barHeight = 14 + (maxHeight - 14) * heightFactor;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          origin.dx + i * (barWidth + gap),
          origin.dy - barHeight / 2,
          barWidth,
          barHeight,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

