import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';

/// الشاشة الأساسية لتحويل النص إلى كلام (TTS) في تطبيق صدى
/// تم تحسينها بتصميم واسع ومريح للنظر مع الحفاظ على الهوية الأصيلة لصدى
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

  final List<Map<String, String>> _quickPhrases = [
    {'text': 'السلام عليكم ورحمة الله', 'icon': '👋'},
    {'text': 'صباح الخير، كيف حالك؟', 'icon': '☀️'},
    {'text': 'شكراً جزيلاً لك على المساعدة', 'icon': '🙏'},
    {'text': 'أحتاج إلى مساعدة من فضلك', 'icon': '🚨'},
    {'text': 'أنا سعيد برؤيتك اليوم', 'icon': '😊'},
    {'text': 'مع السلامة وفي أمان الله', 'icon': '✨'},
    {'text': 'كم سعر هذا المنتج؟', 'icon': '🛍️'},
    {'text': 'أريد أن أطلب وجبة طعام', 'icon': '🍽️'},
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

  @override
  void dispose() {
    _ttsService.stop();
    _textCtrl.dispose();
    _waveController.dispose();
    super.dispose();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      debugPrint('TTS Error: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _ttsService.stop();
    } catch (e) {
      debugPrint('Stop TTS Error: $e');
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
        setState(() => _textCtrl.text = data.text!);
        _speak();
      }
    } catch (e) {
      debugPrint('Clipboard error: $e');
    }
  }

  void _showSignImageDialog() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final t = text.toLowerCase();
    String imageUrl = 'assets/images/robot.png';

    if (t.contains('سلام') || t.contains('مرحب') || t.contains('صباح')) {
      imageUrl = 'assets/images/hello.png';
    } else if (t.contains('شكر')) {
      imageUrl = 'assets/images/thanks.png';
    } else if (t.contains('نعم') || t.contains('أحتاج') || t.contains('ماء')) {
      imageUrl = 'assets/images/yes.png';
    } else if (t.contains('لا') || t.contains('استريح')) {
      imageUrl = 'assets/images/no.png';
    } else if (t.contains('عذر') || t.contains('ألم') || t.contains('طبيب')) {
      imageUrl = 'assets/images/sorry.png';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'حركة لغة الإشارة المعتمدة للعبارة',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.back_hand_rounded, size: 64, color: AppColors.primaryPurple),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'تم وفهمت الإشارة',
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        endDrawer: const SadaDrawer(activeIndex: 2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
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
                // 1. بطاقة الموجة الصوتية والأنيميشن التفاعلي
                _buildWaveCard(),

                const SizedBox(height: 22),

                // 2. بطاقة كتابة النص الواسعة والمريحة
                _buildTextInputCard(),

                const SizedBox(height: 22),

                // 3. عبارات سريعة الاستخدام بمساحات مريحة
                _buildQuickPhrases(),

                const SizedBox(height: 22),

                // 4. إعدادات الصوت وسرعة النطق
                _buildVoiceSettingsCard(),

                const SizedBox(height: 26),

                // 5. أزرار التحكم بالنطق
                _buildActionButtons(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const SadaBottomNav(currentIndex: 2),
      ),
    );
  }

  // ============================================================
  // 1. WAVE CARD
  // ============================================================
  Widget _buildWaveCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // خلفية أنيميشن متدفقة (gradient-background.json)
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Lottie.asset(
                'assets/gradient-background.json',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/Audio&Voice-A-002.json',
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                      animate: _isSpeaking,
                      errorBuilder: (_, __, ___) => _isSpeaking
                          ? Lottie.asset(
                              'assets/Pronounce Animation.json',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.graphic_eq_rounded,
                                color: AppColors.cyanLight,
                                size: 34,
                              ),
                            )
                          : const Icon(
                              Icons.record_voice_over_rounded,
                              color: AppColors.cyanLight,
                              size: 36,
                            ),
                    ),
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
                            ? 'جاري نطق عبارتك بصوت عربي واضح ومفهوم'
                            : 'اكتب عبارتك وسيقوم صدى بنطقها فوراً ودعمها بالإشارة',
                        style: const TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. TEXT INPUT CARD
  // ============================================================
  Widget _buildTextInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
                      'نص العبارة المطلوب نطقها',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_textCtrl.text.isNotEmpty)
                      IconButton(
                        onPressed: () => setState(() => _textCtrl.clear()),
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                        tooltip: 'مسح',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(
                        Icons.content_paste_rounded,
                        size: 15,
                        color: AppColors.primaryPurple,
                      ),
                      label: const Text(
                        'لصق',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        backgroundColor: AppColors.softPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // حقل الإدخال النصي الواسع
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: TextField(
              controller: _textCtrl,
              maxLines: 5,
              minLines: 4,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 16.5,
                color: AppColors.textDark,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'اكتب هنا ما تود قوله، وسيقوم صدى بنطقه بكل وضوح وسلاسة...',
                hintStyle: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.textMuted,
                  fontSize: 14.5,
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // شريط إجراءات سفلي داخل البطاقة (عرض الإشارة)
          if (_textCtrl.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: _showSignImageDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.back_hand_rounded, color: AppColors.primaryPurple, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'معاينة حركة الإشارة 🤟',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 3. QUICK PHRASES
  // ============================================================
  Widget _buildQuickPhrases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عبارات شائعة وسريعة الاستخدام',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quickPhrases.map((item) {
            final phrase = item['text']!;
            final icon = item['icon']!;
            final isSelected = _textCtrl.text == phrase;

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() => _textCtrl.text = phrase);
                _speak();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPurple : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryPurple : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      phrase,
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // 4. VOICE SETTINGS CARD
  // ============================================================
  Widget _buildVoiceSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(Icons.tune_rounded, color: AppColors.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'إعدادات الصوت والنبرة',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              const Text(
                'سرعة النطق',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 13.5,
                  color: AppColors.textDark,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryPurple,
                    thumbColor: AppColors.primaryPurple,
                    inactiveTrackColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                    trackHeight: 3.5,
                  ),
                  child: Slider(
                    value: _speechRate,
                    min: 0.2,
                    max: 1.0,
                    divisions: 8,
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
                  fontSize: 13,
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

  // ============================================================
  // 5. ACTION BUTTONS
  // ============================================================
  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر نطق العبارة الأساسي
        Expanded(
          flex: 4,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: AppColors.brandGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 18,
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
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 24,
              ),
              label: const Text(
                'نطق العبارة الآن',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // زر الإيقاف
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}
