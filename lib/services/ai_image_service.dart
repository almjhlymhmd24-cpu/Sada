import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'api_service.dart';

/// خدمة تحليل الصور بالذكاء الاصطناعي عبر Sada API.
class AiImageService {
  static String get baseUrl => ApiService.baseUrl;

  static Future<String> analyzeImage(File imageFile) async {
    if (!await imageFile.exists()) {
      throw const FileSystemException(
        'ملف الصورة غير موجود',
      );
    }

    final fileName = path.basename(imageFile.path);
    final extension = path.extension(imageFile.path).toLowerCase();

    String subtype;

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        subtype = 'jpeg';
        break;

      case '.png':
        subtype = 'png';
        break;

      case '.webp':
        subtype = 'webp';
        break;

      default:
        throw FormatException(
          'صيغة الصورة غير مدعومة: $extension',
        );
    }

    final contentType = MediaType(
      'image',
      subtype,
    );

    final uri = Uri.parse(
      '$baseUrl/ai/analyze-image',
    );

    debugPrint('================================');
    debugPrint('🖼️ Image file: $fileName');
    debugPrint('🖼️ Extension: $extension');
    debugPrint('🖼️ Content-Type: image/$subtype');
    debugPrint('📤 API: $uri');
    debugPrint('================================');

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: fileName,
      contentType: contentType,
    );

    request.files.add(multipartFile);

    debugPrint('📤 إرسال الصورة إلى API...');

    try {
      // Backend ينتظر حتى 90 ثانية،
      // لذلك نعطي Flutter مهلة أكبر قليلًا.
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 110),
          );

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        '📥 Status Code: ${response.statusCode}',
      );

      debugPrint(
        '📥 Response: ${response.body}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'AI API returned '
          '${response.statusCode}: '
          '${response.body}',
          uri: uri,
        );
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'استجابة AI غير صالحة',
        );
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'حدث خطأ أثناء تحليل الصورة',
        );
      }

      final text = decoded['text']?.toString().trim();

      if (text == null || text.isEmpty) {
        throw const FormatException(
          'لم يتم الحصول على نتيجة من خدمة AI',
        );
      }

      debugPrint('✅ تم تحليل الصورة بنجاح');

      return text;
    } on TimeoutException catch (e) {
      debugPrint(
        '⏰ انتهت مهلة تحليل الصورة: $e',
      );

      throw Exception(
        'استغرق تحليل الصورة وقتًا أطول من المتوقع. '
        'يرجى المحاولة مرة أخرى.',
      );
    } on SocketException catch (e) {
      debugPrint(
        '🌐 خطأ في الاتصال أثناء تحليل الصورة: $e',
      );

      throw Exception(
        'تعذر الاتصال بخادم Sada API. '
        'تأكدي أن الخادم يعمل وأن الهاتف متصل بنفس الشبكة.',
      );
    } on HttpException catch (e) {
      debugPrint(
        '❌ خطأ HTTP أثناء تحليل الصورة: $e',
      );

      rethrow;
    } on FormatException catch (e) {
      debugPrint(
        '⚠️ استجابة تحليل الصورة غير صالحة: $e',
      );

      rethrow;
    } catch (e) {
      debugPrint(
        '❌ خطأ في خدمة تحليل الصور: $e',
      );

      rethrow;
    }
  }
}
