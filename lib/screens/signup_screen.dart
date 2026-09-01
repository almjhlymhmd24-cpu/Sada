import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:sada/screens/onboarding_screen1.dart';
import 'package:sada/services/api_service.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // نفس ألوان هوية صدى المستخدمة بشاشة الدخول
  static const Color primaryPurple = Color(0xFF6C3CEB);
  static const Color accentCyan = Color(0xFF55C9F4);
  static const Color lightBackground = Color(0xFFF9F8FC);
  static const Color textDark = Color(0xFF17151D);
  static const Color textMuted = Color(0xFF666270);

  static const int _minAge = 13;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // ==========================================================
  // اختيار تاريخ الميلاد عبر منتقي تاريخ أصلي (DatePicker)
  // ==========================================================
  Future<void> _pickBirthDate() async {
    try {
      final now = DateTime.now();
      final initialDate = DateTime(now.year - _minAge, now.month, now.day);

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(now.year - 70),
        lastDate: DateTime(now.year - _minAge, now.month, now.day),
        helpText: 'اختاري تاريخ الميلاد',
        cancelText: 'إلغاء',
        confirmText: 'تأكيد',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryPurple,
                onPrimary: Colors.white,
                onSurface: textDark,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && mounted) {
        setState(() {
          _selectedBirthDate = picked;
          _birthDateController.text =
              '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
        });
        _formKey.currentState?.validate();
      }
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء اختيار تاريخ الميلاد: $e');
    }
  }

  // ==========================================================
  // Validation تاريخ الميلاد:
  // 1. لازم يكون محدد (مو فاضي)
  // 2. مايصير بالمستقبل
  // 3. العمر لازم يكون 13 سنة فأكثر
  // ==========================================================
  String? _validateBirthDate(String? value) {
    if (_selectedBirthDate == null || value == null || value.isEmpty) {
      return 'الرجاء اختيار تاريخ الميلاد';
    }

    final now = DateTime.now();

    if (_selectedBirthDate!.isAfter(now)) {
      return 'تاريخ الميلاد غير صالح';
    }

    int age = now.year - _selectedBirthDate!.year;
    final hasHadBirthdayThisYear = (now.month > _selectedBirthDate!.month) ||
        (now.month == _selectedBirthDate!.month &&
            now.day >= _selectedBirthDate!.day);
    if (!hasHadBirthdayThisYear) age--;

    if (age < _minAge) {
      return 'يجب أن يكون عمرك $_minAge سنة على الأقل';
    }

    if (age > 70) {
      return 'الرجاء التأكد من تاريخ الميلاد المدخل';
    }

    return null;
  }

  // ==========================================================
  // Validation رقم الجوال (صيغة عامة، تقبل أرقام سعودية وغيرها)
  // ==========================================================
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الجوال';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    final phoneRegex = RegExp(r'^(\+?\d{8,14})$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'رقم الجوال غير صحيح';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    if (value.trim().length < 3) {
      return 'الاسم قصير جداً';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  // ==========================================================
  // دالة إنشاء الحساب - متصلة بالـ API
  // ==========================================================
  Future<void> _onRegisterPressed() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = await ApiService.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        _showSuccessAndGoBack();
      } else {
        setState(() => _isLoading = false);
        _showError('تعذر إنشاء الحساب، يرجى التأكد من البيانات أو أن البريد غير مستخدم مسبقاً');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessAndGoBack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إنشاء الحساب بنجاح 🎉',
            textAlign: TextAlign.right),
        backgroundColor: primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
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
    return Scaffold(
      backgroundColor: lightBackground,
      body: Stack(
        children: [
          // خلفية بنمط موجات صوتية هادئة (بدل الدوائر المضيئة)
          Positioned.fill(
            child: CustomPaint(
              painter: _SoundWaveBackgroundPainter(
                color1: primaryPurple.withValues(alpha:  0.05),
                color2: accentCyan.withValues(alpha:  0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // زر رجوع + عنوان مصغر أعلى الشاشة
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 18, color: textDark),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'صدى',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 16,
                            child: SvgPicture.asset(
                              'assets/logo.svg',
                              width: 16,
                              height: 16,
                              placeholderBuilder: (context) => const Icon(
                                Icons.record_voice_over_rounded,
                                size: 16,
                                color: primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // بطاقة إنشاء الحساب الزجاجية
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                  24, 28, 24, 24),
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
                                  color: Colors.white.withValues( alpha: .6),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        primaryPurple.withValues(alpha:  0.18),
                                    blurRadius: 30,
                                    offset: const Offset(0, 16),
                                  ),
                                  BoxShadow(
                                    color: accentCyan.withValues( alpha: .10),
                                    blurRadius: 20,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'إنشاء حساب جديد',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Baloo_Bhaijaan_2',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'انضم إلى صدى وابدأ رحلتك',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // الاسم الكامل
                                    _LightTextField(
                                      controller: _fullNameController,
                                      hintText: 'الاسم الكامل',
                                      icon: Icons.person_outline_rounded,
                                      keyboardType: TextInputType.name,
                                      validator: _validateFullName,
                                    ),
                                    const SizedBox(height: 14),

                                    // البريد الإلكتروني
                                    _LightTextField(
                                      controller: _emailController,
                                      hintText: 'البريد الإلكتروني',
                                      icon: Icons.mail_outline_rounded,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 14),

                                    // رقم الجوال
                                    _LightTextField(
                                      controller: _phoneController,
                                      hintText: 'رقم الجوال',
                                      icon: Icons.phone_iphone_rounded,
                                      keyboardType: TextInputType.phone,
                                      validator: _validatePhone,
                                    ),
                                    const SizedBox(height: 14),

                                    // تاريخ الميلاد (قراءة فقط + منتقي تاريخ)
                                    _LightTextField(
                                      controller: _birthDateController,
                                      hintText: 'تاريخ الميلاد',
                                      icon: Icons.cake_outlined,
                                      readOnly: true,
                                      onTap: _pickBirthDate,
                                      validator: _validateBirthDate,
                                    ),
                                    const SizedBox(height: 14),

                                    // كلمة المرور
                                    _LightTextField(
                                      controller: _passwordController,
                                      hintText: 'كلمة المرور',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: !_isPasswordVisible,
                                      validator: _validatePassword,
                                      trailingIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 19,
                                          color: textMuted,
                                        ),
                                        onPressed: () => setState(() =>
                                            _isPasswordVisible =
                                                !_isPasswordVisible),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // تأكيد كلمة المرور
                                    _LightTextField(
                                      controller: _confirmPasswordController,
                                      hintText: 'تأكيد كلمة المرور',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: !_isConfirmPasswordVisible,
                                      validator: _validateConfirmPassword,
                                      trailingIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 19,
                                          color: textMuted,
                                        ),
                                        onPressed: () => setState(() =>
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // زر إنشاء الحساب
                                    _GlowButton(
                                      isLoading: _isLoading,
                                      label: 'إنشاء الحساب',
                                      gradient: const LinearGradient(
                                        colors: [primaryPurple, accentCyan],
                                      ),
                                      glowColor: primaryPurple,
                                      textColor: Colors.white,
                                      onPressed: _onRegisterPressed,
                                    ),

                                    const SizedBox(height: 20),

                                    // فاصل "أو عبر"
                                    const Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                              color: Colors.black12),
                                        ),
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
                                              color: Colors.black12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // أزرار Facebook وGoogle
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

                                    const SizedBox(height: 18),

                                    // رابط تسجيل الدخول
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'لديك حساب بالفعل؟ ',
                                          style: TextStyle(
                                              color: textMuted, fontSize: 13),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text(
                                            'تسجيل الدخول',
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
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// خلفية بنمط موجات صوتية هادئة (بديل احترافي عن الدوائر)
// أعمدة رفيعة شفافة بارتفاعات متفاوتة، توحي بموجة صوت،
// موزعة بزاويتين متقابلتين بالشاشة بشكل غير متطفل
// ============================================================
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
      // نمط ارتفاع شبه جيبي يحاكي موجة صوت طبيعية
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

// ============================================================
// زر دائري لأيقونات التواصل الاجتماعي (مطابق لشاشة الدخول)
// ============================================================
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
        child :Center(
          child: svgAssetPath != null
              ? SvgPicture.asset(
                  svgAssetPath!,
                  width: 24,
                  height: 24,
                ): Icon(iconData, color: iconColor, size: 28),
        ),
      ),
    );
  }
}

// ============================================================
// حقل نصي فاتح (مشترك بنفس أسلوب شاشة الدخول)
// ============================================================
class _LightTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final Widget? trailingIcon;
  final String? Function(String?)? validator;

  const _LightTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.trailingIcon,
    this.validator,
  });

  static const Color primaryPurple = Color(0xFF6C3CEB);
  static const Color textDark = Color(0xFF17151D);
  static const Color textMuted = Color(0xFF666270);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      textAlign: TextAlign.right,
      style: const TextStyle(color: textDark, fontSize: 14),
      cursorColor: primaryPurple,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        prefixIcon: trailingIcon,
        suffixIcon: Icon(icon, color: textMuted, size: 19),
        filled: true,
        fillColor: Colors.white.withValues(alpha:  0.55),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
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

// ============================================================
// زر رئيسي بتوهج ملون (مطابق لشاشة الدخول)
// ============================================================
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
