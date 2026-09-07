import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/models.dart';

/// خدمة الاتصال بـ Sada Web API
class ApiService {
  // للتشغيل على Windows / Web استخدمي localhost
  // للتشغيل على محاكي Android استخدمي 10.0.2.2
  // للتشغيل على جهاز جوال حقيقي استخدمي IP جهاز الكمبيوتر
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.213.34:54707/api';
    }

    return 'http://localhost:54707/api';
  }

  // إنشاء عميل HTTP
  static http.Client _createHttpClient() {
    if (kIsWeb) {
      return http.Client();
    }

    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    return IOClient(ioClient);
  }

  static AppUser? currentUser;

  // ==============================
  // الفئات الافتراضية
  // ==============================

  static List<Category> get defaultCategories => [
        Category(
          categoryId: 1,
          name: 'الروتين اليومي',
          description: 'عبارات وجمل للتواصل في الأنشطة والمهام اليومية',
          phrasesCount: 4,
        ),
        Category(
          categoryId: 2,
          name: 'العائلة والمنزل',
          description: 'عبارات تخص أفراد الأسرة والتواصل المنزلي',
          phrasesCount: 3,
        ),
        Category(
          categoryId: 3,
          name: 'التحيات والترحيب',
          description: 'عبارات الترحيب، السلام، والسؤال عن الحال',
          phrasesCount: 5,
        ),
        Category(
          categoryId: 4,
          name: 'الصحة والعلاج',
          description: 'وصف الأعراض، الحاجة لطبيب، أو التعبير عن الألم',
          phrasesCount: 4,
        ),
        Category(
          categoryId: 5,
          name: 'المجتمع والعمل',
          description: 'عبارات للتفاعل مع الأصدقاء وزملاء العمل',
          phrasesCount: 3,
        ),
        Category(
          categoryId: 6,
          name: 'المطعم والتسوق',
          description: 'طلب الطعام، السؤال عن الأسعار والمشتريات',
          phrasesCount: 4,
        ),
        Category(
          categoryId: 7,
          name: 'الطوارئ والمساعدة',
          description: 'عبارات سريعة لطلب المساعدة العاجلة',
          phrasesCount: 3,
        ),
      ];

  // ==============================
  // العبارات الافتراضية
  // ==============================

  static List<Phrase> get defaultPhrases => [
        Phrase(
          phraseId: 1,
          text: 'السلام عليكم ورحمة الله وبركاته',
          userId: 1,
          categoryId: 3,
          categoryName: 'التحيات والترحيب',
        ),
        Phrase(
          phraseId: 2,
          text: 'صباح الخير، أتمنى لك يوماً جميلاً',
          userId: 1,
          categoryId: 3,
          categoryName: 'التحيات والترحيب',
        ),
        Phrase(
          phraseId: 3,
          text: 'كيف حالك اليوم؟',
          userId: 1,
          categoryId: 3,
          categoryName: 'التحيات والترحيب',
        ),
        Phrase(
          phraseId: 4,
          text: 'شكراً جزيلاً لمساعدتك',
          userId: 1,
          categoryId: 3,
          categoryName: 'التحيات والترحيب',
        ),
        Phrase(
          phraseId: 5,
          text: 'أحتاج إلى شرب الماء من فضلك',
          userId: 1,
          categoryId: 1,
          categoryName: 'الروتين اليومي',
        ),
        Phrase(
          phraseId: 6,
          text: 'أريد أن أستريح قليلاً',
          userId: 1,
          categoryId: 1,
          categoryName: 'الروتين اليومي',
        ),
        Phrase(
          phraseId: 7,
          text: 'أشعر بألم هنا، هل يمكن استدعاء الطبيب؟',
          userId: 1,
          categoryId: 4,
          categoryName: 'الصحة والعلاج',
        ),
        Phrase(
          phraseId: 8,
          text: 'هل يمكنك تكرار ما قلت بطريقة أبطأ؟',
          userId: 1,
          categoryId: 5,
          categoryName: 'المجتمع والعمل',
        ),
        Phrase(
          phraseId: 9,
          text: 'أنا سعيد جداً بالتحدث معك اليوم',
          userId: 1,
          categoryId: 5,
          categoryName: 'المجتمع والعمل',
        ),
      ];

  // ==============================
  // Categories
  // ==============================

  static Future<List<Category>> getCategories() async {
    final client = _createHttpClient();

    try {
      final url = Uri.parse('$baseUrl/Categories');

      debugPrint('========== GET CATEGORIES ==========');
      debugPrint('GET: $url');

      final res = await client.get(url).timeout(
            const Duration(seconds: 10),
          );

      debugPrint('Categories Status: ${res.statusCode}');
      debugPrint(
        'Categories Response: ${utf8.decode(res.bodyBytes)}',
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(
          utf8.decode(res.bodyBytes),
        );

        if (decoded is List) {
          final list = decoded
              .map(
                (e) => Category.fromJson(e),
              )
              .toList();

          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } on TimeoutException catch (e) {
      debugPrint(
        'Categories timeout: $e',
      );
    } on SocketException catch (e) {
      debugPrint(
        'Categories network error: $e',
      );
    } catch (e) {
      debugPrint(
        'Categories API Error: $e',
      );
    } finally {
      client.close();
    }

    return defaultCategories;
  }

  // ==============================
  // Phrases
  // ==============================

  static Future<List<Phrase>> getPhrases() async {
    final client = _createHttpClient();

    try {
      final url = Uri.parse('$baseUrl/Phrases');

      debugPrint('========== GET PHRASES ==========');
      debugPrint('GET: $url');

      final res = await client.get(url).timeout(
            const Duration(seconds: 10),
          );

      debugPrint('Phrases Status: ${res.statusCode}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(
          utf8.decode(res.bodyBytes),
        );

        if (decoded is List) {
          final list = decoded
              .map(
                (e) => Phrase.fromJson(e),
              )
              .toList();

          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } on TimeoutException catch (e) {
      debugPrint(
        'Phrases timeout: $e',
      );
    } on SocketException catch (e) {
      debugPrint(
        'Phrases network error: $e',
      );
    } catch (e) {
      debugPrint(
        'تعذر جلب العبارات من API: $e',
      );
    } finally {
      client.close();
    }

    return defaultPhrases;
  }

  // ==============================
  // عبارات مستخدم معين
  // ==============================

  static Future<List<Phrase>> getPhrasesByUser(
    int userId,
  ) async {
    final client = _createHttpClient();

    try {
      final url = Uri.parse(
        '$baseUrl/Phrases/by-user/$userId',
      );

      debugPrint(
        '========== GET USER PHRASES ==========',
      );
      debugPrint('GET: $url');

      final res = await client.get(url).timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        'User Phrases Status: ${res.statusCode}',
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(
          utf8.decode(res.bodyBytes),
        );

        if (decoded is List) {
          return decoded
              .map(
                (e) => Phrase.fromJson(e),
              )
              .toList();
        }
      }

      return [];
    } on TimeoutException catch (e) {
      debugPrint(
        'User phrases timeout: $e',
      );

      return [];
    } on SocketException catch (e) {
      debugPrint(
        'User phrases network error: $e',
      );

      return [];
    } catch (e) {
      debugPrint(
        'خطأ في جلب عبارات المستخدم: $e',
      );

      return [];
    } finally {
      client.close();
    }
  }

  // ==============================
  // إنشاء عبارة جديدة
  // ==============================

  static Future<bool> createPhrase({
    required String text,
    required int userId,
    required int categoryId,
  }) async {
    final client = _createHttpClient();

    try {
      final url = Uri.parse(
        '$baseUrl/Phrases',
      );

      debugPrint(
        '========== CREATE PHRASE ==========',
      );
      debugPrint('POST: $url');

      final requestBody = {
        'text': text.trim(),
        'userId': userId,
        'categoryId': categoryId,
      };

      debugPrint(
        'REQUEST: ${jsonEncode(requestBody)}',
      );

      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(
              requestBody,
            ),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      final responseBody = utf8.decode(
        response.bodyBytes,
      );

      debugPrint(
        'STATUS: ${response.statusCode}',
      );

      debugPrint(
        'RESPONSE: $responseBody',
      );

      // أي Status من 200 إلى 299 يعتبر نجاح
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          '✅ Phrase created successfully',
        );

        return true;
      }

      debugPrint(
        '❌ Create phrase failed '
        'HTTP ${response.statusCode}',
      );

      return false;
    } on TimeoutException catch (e) {
      debugPrint(
        '⏰ Create phrase timeout: $e',
      );

      return false;
    } on SocketException catch (e) {
      debugPrint(
        '🌐 Create phrase network error: $e',
      );

      return false;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Create phrase error: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      return false;
    } finally {
      client.close();
    }
  }

  // ==============================
  // Register
  // ==============================

  static Future<AppUser?> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final client = _createHttpClient();

    try {
      final url = Uri.parse(
        '$baseUrl/Auth/register',
      );

      debugPrint(
        '========== REGISTER ==========',
      );

      debugPrint(
        'POST: $url',
      );

      final res = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'fullName': fullName.trim(),
              'email': email.trim(),
              'password': password,
              'phoneNumber': phoneNumber,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      debugPrint(
        'REGISTER STATUS: ${res.statusCode}',
      );

      debugPrint(
        'REGISTER RESPONSE: '
        '${utf8.decode(res.bodyBytes)}',
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(
          utf8.decode(res.bodyBytes),
        );

        if (decoded is Map<String, dynamic>) {
          currentUser = AppUser.fromJson(
            decoded,
          );

          return currentUser;
        }
      }

      debugPrint(
        'REGISTER FAILED: ${res.statusCode}',
      );

      return null;
    } on TimeoutException catch (e) {
      debugPrint(
        'REGISTER TIMEOUT: $e',
      );

      return null;
    } on SocketException catch (e) {
      debugPrint(
        'REGISTER NETWORK ERROR: $e',
      );

      return null;
    } catch (e) {
      debugPrint(
        'REGISTER ERROR: $e',
      );

      return null;
    } finally {
      client.close();
    }
  }

  // ==============================
  // Login
  // ==============================

  static Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final client = _createHttpClient();

    try {
      final url = Uri.parse(
        '$baseUrl/Auth/login',
      );

      debugPrint(
        '========== LOGIN ==========',
      );

      debugPrint(
        'Login URL: $url',
      );

      final res = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      debugPrint(
        'Login Status: ${res.statusCode}',
      );

      debugPrint(
        'Login Response: '
        '${utf8.decode(res.bodyBytes)}',
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(
          utf8.decode(res.bodyBytes),
        );

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'استجابة تسجيل الدخول غير صالحة',
          );
        }

        currentUser = AppUser.fromJson(
          decoded,
        );

        debugPrint(
          '✅ Login successful',
        );

        return currentUser;
      }

      debugPrint(
        '⚠️ Login rejected by API: '
        '${res.statusCode}',
      );

      return null;
    } on TimeoutException catch (e) {
      debugPrint(
        '⚠️ Login timed out: $e',
      );

      return null;
    } on SocketException catch (e) {
      debugPrint(
        '🌐 Login network error: $e',
      );

      return null;
    } on FormatException catch (e) {
      debugPrint(
        '⚠️ Invalid login response: $e',
      );

      return null;
    } catch (e) {
      debugPrint(
        '⚠️ Login API error: $e',
      );

      return null;
    } finally {
      client.close();
    }
  }

  // ==============================
  // AI Chat
  // ==============================

  static Future<String> sendChatMessage(
    String message,
  ) async {
    final client = _createHttpClient();

    try {
      final text = message.trim();

      if (text.isEmpty) {
        throw const FormatException(
          'الرسالة فارغة.',
        );
      }

      final url = Uri.parse(
        '$baseUrl/ai/chat',
      );

      debugPrint(
        '========== AI CHAT ==========',
      );

      debugPrint(
        'POST: $url',
      );

      debugPrint(
        'MESSAGE: $text',
      );

      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': text,
            }),
          )
          .timeout(
            const Duration(seconds: 90),
          );

      debugPrint(
        'CHAT STATUS: ${response.statusCode}',
      );

      debugPrint(
        'CHAT RESPONSE: '
        '${utf8.decode(response.bodyBytes)}',
      );

      final responseText = utf8.decode(
        response.bodyBytes,
      );

      dynamic decoded;

      if (responseText.isNotEmpty) {
        decoded = jsonDecode(
          responseText,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'استجابة المحادثة غير صالحة.',
          );
        }

        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'فشل الحصول على رد من الذكاء الاصطناعي.',
          );
        }

        final reply = decoded['message']?.toString().trim();

        if (reply == null || reply.isEmpty) {
          throw const FormatException(
            'الرد من الذكاء الاصطناعي فارغ.',
          );
        }

        debugPrint(
          '✅ AI CHAT SUCCESS',
        );

        return reply;
      }

      String errorMessage = 'حدث خطأ أثناء الاتصال بالذكاء الاصطناعي.';

      if (decoded is Map<String, dynamic>) {
        errorMessage = decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            errorMessage;
      }

      throw HttpException(
        '$errorMessage '
        '(HTTP ${response.statusCode})',
      );
    } on TimeoutException {
      debugPrint(
        '⏰ AI Chat timeout',
      );

      throw Exception(
        'استغرق الذكاء الاصطناعي وقتًا طويلًا للرد.',
      );
    } on FormatException catch (e) {
      debugPrint(
        '⚠️ AI Chat format error: $e',
      );

      rethrow;
    } on SocketException catch (e) {
      debugPrint(
        '🌐 AI Chat network error: $e',
      );

      throw Exception(
        'تعذر الاتصال بالخادم. '
        'تأكدي أن Sada API يعمل '
        'وأن الهاتف متصل بنفس الشبكة.',
      );
    } catch (e) {
      debugPrint(
        '❌ AI Chat error: $e',
      );

      rethrow;
    } finally {
      client.close();
    }
  }
}
