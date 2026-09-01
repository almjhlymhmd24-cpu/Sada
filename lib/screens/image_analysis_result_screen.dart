import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class ImageAnalysisResultScreen extends StatefulWidget {
  final File imageFile;
  final String result;

  const ImageAnalysisResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  State<ImageAnalysisResultScreen> createState() =>
      _ImageAnalysisResultScreenState();
}

class _ImageAnalysisResultScreenState
    extends State<ImageAnalysisResultScreen> {
  final TtsService _tts = TtsService();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _tts.onStart = () {
      if (mounted) setState(() => _isSpeaking = true);
    };
    _tts.onComplete = () {
      if (mounted) setState(() => _isSpeaking = false);
    };
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleSpeech() async {
    try {
      if (_isSpeaking) {
        await _tts.stop();
        if (mounted) setState(() => _isSpeaking = false);
      } else {
        await _tts.speak(widget.result);
      }
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء نطق نتيجة التحليل: $e');
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: widget.result));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ النص إلى الحافظة',
          textAlign: TextAlign.right,
        ),
        backgroundColor: AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text(
            'تحليل الصورة بالذكاء الاصطناعي',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: AppColors.primaryPurple),
              tooltip: 'نسخ النتيجة',
              onPressed: _copyResult,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معاينة الصورة
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    widget.imageFile,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // عنوان النتيجة
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'نتيجة التحليل الذكي',
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // بطاقة النتيجة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Text(
                  widget.result,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 16,
                    height: 1.7,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // زر النطق الصوتي
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _toggleSpeech,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSpeaking
                        ? AppColors.danger
                        : AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    _isSpeaking
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isSpeaking ? 'إيقاف النطق' : 'استماع للنتيجة صوتياً',
                    style: const TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}