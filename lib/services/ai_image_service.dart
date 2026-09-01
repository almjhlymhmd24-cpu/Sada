import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'api_service.dart';

/// خدمة تحليل الصور بالذكاء الاصطناعي عبر Sada API.
class AiImageService {
  static String get baseUrl => ApiService.baseUrl;

  static Future<String> analyzeImage(File imageFile) async {
    try {
      // التأكد من وجود الملف
      if (!await imageFile.exists()) {
        throw const FileSystemException(
          'ملف الصورة غير موجود',
        );
      }

      // اسم الملف
      final fileName = path.basename(imageFile.path);

      // امتداد الملف
      final extension = path.extension(imageFile.path).toLowerCase();

      // تحديد نوع الصورة
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

      debugPrint('================================');
      debugPrint('🖼️ Image file: $fileName');
      debugPrint('🖼️ Extension: $extension');
      debugPrint('🖼️ Content-Type: image/$subtype');
      debugPrint('================================');

      // رابط الـ API
      final uri = Uri.parse(
        '$baseUrl/ai/analyze-image',
      );

      // إنشاء Multipart Request
      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      // إضافة الصورة
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: fileName,
        contentType: contentType,
      );

      request.files.add(
        multipartFile,
      );

      debugPrint(
        '📤 إرسال الصورة إلى: $uri',
      );

      debugPrint(
        '📤 Field: image',
      );

      debugPrint(
        '📤 Filename: $fileName',
      );

      debugPrint(
        '📤 Content-Type: image/$subtype',
      );

      // إرسال الطلب
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
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

      // فشل HTTP
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'AI API returned '
          '${response.statusCode}: '
          '${response.body}',
          uri: uri,
        );
      }

      // قراءة JSON
      final decoded = jsonDecode(
        utf8.decode(
          response.bodyBytes,
        ),
      );

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'استجابة AI غير صالحة',
        );
      }

      // التحقق من نجاح العملية
      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'حدث خطأ أثناء تحليل الصورة',
        );
      }

      // استخراج النص
      final text = decoded['text']?.toString().trim();

      if (text == null || text.isEmpty) {
        throw const FormatException(
          'لم يتم الحصول على نتيجة من خدمة AI',
        );
      }

      return text;
    } on TimeoutException catch (e) {
      debugPrint(
        '⚠️ انتهت مهلة تحليل الصورة: $e',
      );
      rethrow;
    } catch (e) {
      debugPrint(
        '⚠️ خطأ في خدمة تحليل الصور: $e',
      );
      rethrow;
    }
  }
}
