import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';

/// الشاشة الأساسية لتحويل النص إلى كلام (TTS) في تطبيق صدى
class TtsScreen extends StatefulWidget {
  final String? initialText;
  final String? initialCategory;

  const TtsScreen({
    super.key,
    this.initialText,
    this.initialCategory,
  });

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen>
    with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late final TextEditingController _textCtrl;
  late final AnimationController _waveController;

  bool _isSpeaking = false;
  double _speechRate = 0.5;

  final List<String> _quickPhrases = [
    'السلام عليكم ورحمة الله',
    'صباح الخير، كيف حالك؟',
    'شكراً جزيلاً لك',
    'أحتاج إلى مساعدة من فضلك',
    'أنا سعيد برؤيتك اليوم',
    'مع السلامة وفي أمان الله',
    'هل يمكنك مساعدتي؟',
    'أريد أن أطلب طعاماً',
  ];

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.initialText ?? '');
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _ttsService.init();
    _ttsService.onStart = () {
      if (mounted) {
        setState(() => _isSpeaking = true);
        _waveController.repeat(reverse: true);
      }
    };
    _ttsService.onComplete = () {
      if (mounted) {
        setState(() => _isSpeaking = false);
        _waveController.stop();
        _waveController.reset();
      }
    };
  }

  Future<void> _speak() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'الرجاء كتابة أو اختيار نص للنطق أولاً',
            textAlign: TextAlign.right,
          ),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      await _ttsService.setRate(_speechRate);
      await _ttsService.speak(text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تشغيل النطق الصوتي، حاول مرة أخرى', textAlign: TextAlign.right),
        ),
      );
      debugPrint('⚠️ خطأ أثناء تحويل النص إلى كلام: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _ttsService.stop();
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء إيقاف النطق: $e');
    } finally {
      if (mounted) {
        setState(() => _isSpeaking = false);
        _waveController.stop();
        _waveController.reset();
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (!mounted) return;
      if (data != null && data.text != null && data.text!.isNotEmpty) {
        setState(() {
          _textCtrl.text = data.text!;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر لصق النص من الحافظة', textAlign: TextAlign.right),
        ),
      );
      debugPrint('⚠️ خطأ في الحافظة: $e');
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _textCtrl.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        drawer: const SadaDrawer(activeIndex: 2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'تحويل النص إلى كلام',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          actions: [
            if (_textCtrl.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_all_rounded, color: AppColors.textMuted),
                tooltip: 'مسح النص',
                onPressed: () => setState(() => _textCtrl.clear()),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة الأنيميشن والموجة الصوتية
                _buildWaveCard(),

                const SizedBox(height: 20),

                // بطاقة كتابة النص الزجاجية
                _buildTextInputCard(),

                const SizedBox(height: 18),

                // عبارات سريعة مقترحة
                _buildQuickPhrases(),

                const SizedBox(height: 18),

                // إعدادات الصوت (السرعة والنبرة)
                _buildVoiceSettingsCard(),

                const SizedBox(height: 24),

                // أزرار التحكم بالنطق
                _buildActionButtons(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const SadaBottomNav(currentIndex: 2),
      ),
    );
  }

  Widget _buildWaveCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: _isSpeaking
                ? Lottie.asset(
                    'assets/Pronounce Animation.json',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.cyanLight,
                      size: 44,
                    ),
                  )
                : const Icon(
                    Icons.record_voice_over_rounded,
                    color: AppColors.cyanLight,
                    size: 40,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSpeaking ? 'صدى ينطق الآن...' : 'صوتك مسموع دائماً',
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isSpeaking
                      ? 'جاري نطق العبارة بصوت عربي واضح ومفهوم'
                      : 'اكتب عبارتك وسيقوم صدى بنطقها فوراً وبدقة',
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.primaryPurple,
                          size: 24,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'نص العبارة',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(
                        Icons.content_paste_rounded,
                        size: 16,
                        color: AppColors.primaryPurple,
                      ),
                      label: const Text(
                        'لصق النص',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFF0F4FA), height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _textCtrl,
                  maxLines: 5,
                  minLines: 4,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 16,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'اكتب هنا ما تود قوله، وسيقوم صدى بنطقه بكل وضوح...',
                    hintStyle: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPhrases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عبارات سريعة الاستخدام',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickPhrases.map((phrase) {
            final isSelected = _textCtrl.text == phrase;
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() => _textCtrl.text = phrase);
                _speak();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPurple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  phrase,
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVoiceSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'إعدادات الصوت',
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
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'سرعة النطق',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryPurple,
                    thumbColor: AppColors.primaryPurple,
                    inactiveTrackColor:
                        AppColors.primaryPurple.withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _speechRate,
                    min: 0.2,
                    max: 1.0,
                    divisions: 8,
                    label: '${(_speechRate * 2).toStringAsFixed(1)}x',
                    onChanged: (val) {
                      setState(() => _speechRate = val);
                      _ttsService.setRate(val);
                    },
                  ),
                ),
              ),
              Text(
                '${(_speechRate * 2).toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر نطق العبارة الأساسي
        Expanded(
          flex: 3,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.brandGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _isSpeaking ? null : _speak,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 22,
              ),
              label: const Text(
                'نطق العبارة',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // زر الإيقاف
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _isSpeaking
                ? Colors.redAccent.withValues(alpha: 0.12)
                : AppColors.softPurple,
            border: Border.all(
              color: _isSpeaking ? Colors.redAccent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: _isSpeaking ? _stop : null,
            icon: Icon(
              Icons.stop_rounded,
              color: _isSpeaking ? Colors.redAccent : AppColors.textMuted,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
