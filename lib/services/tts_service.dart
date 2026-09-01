import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة النطق الصوتي الموحدة لتطبيق صدى
class TtsService {
  static final TtsService _instance = TtsService._internal();

  factory TtsService() => _instance;

  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool isSpeaking = false;

  double speechRate = 0.42;
  double speechPitch = 1.0;
  double volume = 1.0;

  VoidCallback? onStart;
  VoidCallback? onComplete;
  VoidCallback? onError;

  String? _arabicLanguage;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // الصوت
      await _flutterTts.setVolume(volume);

      // نبرة طبيعية
      await _flutterTts.setPitch(speechPitch);

      // سرعة أبطأ قليلًا للعربية
      await _flutterTts.setSpeechRate(speechRate);

      // مهم في Android
      await _flutterTts.awaitSpeakCompletion(true);

      // --------------------------------------------------
      // البحث عن أفضل لغة عربية متوفرة
      // --------------------------------------------------

      try {
        final languages = await _flutterTts.getLanguages;

        debugPrint('🌍 TTS Languages: $languages');

        if (languages is List) {
          final arabicLanguages = languages
              .map((e) => e.toString())
              .where(
                (language) => language.toLowerCase().startsWith('ar'),
              )
              .toList();

          debugPrint(
            '🇸🇦 Arabic languages found: $arabicLanguages',
          );

          if (arabicLanguages.isNotEmpty) {
            // نحاول اختيار ar-SA أولًا
            final saudi = arabicLanguages.where(
              (language) =>
                  language.toLowerCase() == 'ar-sa' ||
                  language.toLowerCase() == 'ar_sa',
            );

            if (saudi.isNotEmpty) {
              _arabicLanguage = saudi.first;
            } else {
              _arabicLanguage = arabicLanguages.first;
            }

            await _flutterTts.setLanguage(
              _arabicLanguage!,
            );

            debugPrint(
              '✅ TTS Arabic language: $_arabicLanguage',
            );
          }
        }
      } catch (e) {
        debugPrint(
          '⚠️ Arabic language detection error: $e',
        );
      }

      // --------------------------------------------------
      // Handlers
      // --------------------------------------------------

      _flutterTts.setStartHandler(() {
        isSpeaking = true;

        debugPrint('🔊 TTS بدأ النطق');

        onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking = false;

        debugPrint('✅ TTS اكتمل النطق');

        onComplete?.call();
      });

      _flutterTts.setCancelHandler(() {
        isSpeaking = false;

        debugPrint('⏹️ TTS تم إيقافه');

        onComplete?.call();
      });

      _flutterTts.setErrorHandler((message) {
        isSpeaking = false;

        debugPrint(
          '❌ TTS Error: $message',
        );

        onError?.call();
      });

      _isInitialized = true;

      debugPrint('✅ TTS Service initialized');
    } catch (e) {
      debugPrint(
        '❌ TTS initialization failed: $e',
      );
    }
  }

  // ============================================================
  // SPEAK
  // ============================================================

  Future<void> speak(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    try {
      await init();

      // إيقاف أي كلام سابق
      await _flutterTts.stop();

      // إعدادات الصوت
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(speechPitch);
      await _flutterTts.setSpeechRate(speechRate);

      // استخدام اللغة العربية التي وجدناها
      if (_arabicLanguage != null) {
        await _flutterTts.setLanguage(
          _arabicLanguage!,
        );
      }

      debugPrint(
        '🗣️ TTS ينطق بالعربية: "$cleanText"',
      );

      final result = await _flutterTts.speak(
        cleanText,
      );

      debugPrint(
        '🔊 TTS speak result: $result',
      );
    } catch (e) {
      isSpeaking = false;

      debugPrint(
        '❌ TTS speak error: $e',
      );

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

      debugPrint('⏹️ TTS stopped');
    } catch (e) {
      debugPrint(
        '⚠️ TTS stop error: $e',
      );
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
      debugPrint(
        '⚠️ TTS rate error: $e',
      );
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
      debugPrint(
        '⚠️ TTS pitch error: $e',
      );
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
      debugPrint(
        '⚠️ TTS volume error: $e',
      );
    }
  }
}
