import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_image_service.dart';
import '../theme/app_theme.dart';
import 'image_analysis_result_screen.dart';
import '../widgets/sada_states.dart';

/// شاشة مساعد الذكاء الاصطناعي الشامل لصدى
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  bool _loading = false;
  String _loadingMessage = 'جاري تحليل الصورة بالذكاء الاصطناعي...';

  final List<String> _quickCapabilities = [
    '📷 تحليل محتوى الصور والتعرف على المشاهد',
    '🔤 استخراج النصوص المكتوبة وترجمتها',
    '🤟 اقتراح إشارات التعبير المناسبة للموقف',
    '💬 صياغة ردود سريعة ومساعدة في التواصل',
  ];

  Future<void> _pickAndAnalyze(ImageSource source, [String? prompt]) async {
    if (_loading) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;

      final file = File(picked.path);
      setState(() {
        _loading = true;
        _loadingMessage = prompt != null
            ? 'جاري تنفيذ طلبك: $prompt...'
            : 'جاري تحليل الصورة بالذكاء الاصطناعي...';
      });

      final result = await AiImageService.analyzeImage(file);

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ImageAnalysisResultScreen(imageFile: file, result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تعذر تحليل الصورة، تأكد من الاتصال بالخادم وحاول مجدداً',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'مساعد الذكاء الاصطناعي',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: SafeArea(
          child: _loading
              ? SadaLoadingView(message: _loadingMessage)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // بطاقة رأس المساعد الذكي
                      _buildAssistantHeader(),

                      const SizedBox(height: 24),

                      // بطاقات الإجراءات الرئيسية
                      const Text(
                        'اختر طريقة الإدخال',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildActionCard(
                        icon: Icons.camera_alt_rounded,
                        title: 'التقاط صورة بالكاميرا',
                        subtitle: 'التقط صورة فورية لأي شيء وسيقوم صدى بتحليله',
                        gradient: AppColors.brandGradient,
                        onTap: () => _pickAndAnalyze(ImageSource.camera),
                      ),

                      const SizedBox(height: 14),

                      _buildActionCard(
                        icon: Icons.photo_library_rounded,
                        title: 'اختيار صورة من المعرض',
                        subtitle: 'اختر صورة محفوظة من هاتفك للتعرف عليها',
                        gradient: AppColors.purpleGradient,
                        onTap: () => _pickAndAnalyze(ImageSource.gallery),
                      ),

                      const SizedBox(height: 26),

                      // مميزات المساعد الذكي
                      _buildCapabilitiesCard(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAssistantHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'مساعد صدى الذكي ✨',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'استخدم كاميرا هاتفك أو شارك صورة وسيقوم صدى بتحليلها فورياً ومساعدتك في التعبير عنها بصوت واضح ومفهوم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilitiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'ما الذي يستطيع صدى تقديمه؟',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._quickCapabilities.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                c,
                style: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
