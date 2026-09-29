import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة النطق الصوتي الموحدة والمحدثة لتطبيق صدى
/// تدعم كافة أجهزة الأندرويد والمحاكيات باحترافية عالية
class TtsService {
  static final TtsService _instance = TtsService._internal();

  factory TtsService() => _instance;

  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool isSpeaking = false;

  double speechRate = 0.45;
  double speechPitch = 1.0;
  double volume = 1.0;

  VoidCallback? onStart;
  VoidCallback? onComplete;
  VoidCallback? onError;

  String _arabicLanguage = 'ar-SA';

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // إعدادات الصوت الأساسية
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(speechPitch);
      await _flutterTts.setSpeechRate(speechRate);

      // في أندرويد: لا ننتظر الإكمال بشكل متزامن حتى لا يعلق الصوت إذا تأخر المحاكي
      if (!kIsWeb) {
        try {
          await _flutterTts.awaitSpeakCompletion(false);
        } catch (_) {}
      }

      // البحث عن اللغات المتوفرة في النظام واختيار أفضل لغة عربية
      try {
        final dynamic languages = await _flutterTts.getLanguages;
        if (languages is List && languages.isNotEmpty) {
          final arabicLanguages = languages
              .map((e) => e.toString())
              .where((lang) => lang.toLowerCase().startsWith('ar'))
              .toList();

          if (arabicLanguages.isNotEmpty) {
            final saudi = arabicLanguages.firstWhere(
              (lang) =>
                  lang.toLowerCase() == 'ar-sa' ||
                  lang.toLowerCase() == 'ar_sa',
              orElse: () => arabicLanguages.first,
            );
            _arabicLanguage = saudi;
          } else {
            _arabicLanguage = 'ar';
          }
        }
      } catch (e) {
        debugPrint('⚠️ TTS Language detection warning: $e');
        _arabicLanguage = 'ar-SA';
      }

      // تعيين اللغة
      try {
        await _flutterTts.setLanguage(_arabicLanguage);
      } catch (_) {
        try {
          await _flutterTts.setLanguage('ar');
        } catch (_) {}
      }

      // Handlers
      _flutterTts.setStartHandler(() {
        isSpeaking = true;
        debugPrint('🔊 [Sada TTS] Started speaking');
        onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking = false;
        debugPrint('✅ [Sada TTS] Finished speaking');
        onComplete?.call();
      });

      _flutterTts.setCancelHandler(() {
        isSpeaking = false;
        debugPrint('⏹️ [Sada TTS] Cancelled speaking');
        onComplete?.call();
      });

      _flutterTts.setErrorHandler((dynamic message) {
        isSpeaking = false;
        debugPrint('❌ [Sada TTS] Error: $message');
        onError?.call();
      });

      _isInitialized = true;
      debugPrint('✅ [Sada TTS] Service Initialized with language: $_arabicLanguage');
    } catch (e) {
      debugPrint('❌ [Sada TTS] Initialization failed: $e');
    }
  }

  // ============================================================
  // SPEAK
  // ============================================================

  Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      if (!_isInitialized) {
        await init();
      }

      // إيقاف أي نطق سابق أولاً
      try {
        await _flutterTts.stop();
      } catch (_) {}

      // تأكيد المعايير
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(speechPitch);
      await _flutterTts.setSpeechRate(speechRate);

      try {
        await _flutterTts.setLanguage(_arabicLanguage);
      } catch (_) {
        try {
          await _flutterTts.setLanguage('ar');
        } catch (_) {}
      }

      debugPrint('🗣️ [Sada TTS] Speaking: "$cleanText"');
      final dynamic result = await _flutterTts.speak(cleanText);
      debugPrint('🔊 [Sada TTS] Speak result: $result');

      // في حال كان المحاكي لا يدعم StartHandler مباشرة، نضع حالة النطق نشطة
      isSpeaking = true;
      onStart?.call();
    } catch (e) {
      isSpeaking = false;
      debugPrint('❌ [Sada TTS] Speak error: $e');
      onError?.call();
    }
  }

  // ============================================================
  // STOP
  // ============================================================

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      isSpeaking = false;
      onComplete?.call();
      debugPrint('⏹️ [Sada TTS] Stopped');
    } catch (e) {
      debugPrint('⚠️ [Sada TTS] Stop error: $e');
    }
  }

  // ============================================================
  // RATE
  // ============================================================

  Future<void> setRate(double rate) async {
    speechRate = rate;
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('⚠️ [Sada TTS] Rate error: $e');
    }
  }

  // ============================================================
  // PITCH
  // ============================================================

  Future<void> setPitch(double pitch) async {
    speechPitch = pitch;
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      debugPrint('⚠️ [Sada TTS] Pitch error: $e');
    }
  }

  // ============================================================
  // VOLUME
  // ============================================================

  Future<void> setVolume(double value) async {
    volume = value;
    try {
      await _flutterTts.setVolume(value);
    } catch (e) {
      debugPrint('⚠️ [Sada TTS] Volume error: $e');
    }
  }
}
