// lib/core/services/image_upload_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../error/exceptions.dart';
import '../error/supabase_guard.dart';

class ImageUploadService {
  final SupabaseClient client;
  static const _bucket = 'products';
  static const _maxSizeKb = 500; // الحد الأقصى بعد الضغط

  ImageUploadService(this.client);

  /// يضغط الصورة ثم يرفعها لـ Storage، يعيد الـ public URL
  Future<String> uploadImage({
    required File file,
    required String folder, // 'products' أو 'categories'
    String? existingPath, // لو موجود يحذفه أولاً
  }) async {
    // ضغط الصورة
    final compressed = await _compress(file);

    // اسم فريد للملف
    final ext = _extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final path = '$folder/$fileName';

    return guardSupabaseCall(() async {
      // حذف القديمة إن وُجدت
      if (existingPath != null) {
        await _tryDelete(existingPath);
      }

      // رفع الجديدة
      await client.storage
          .from(_bucket)
          .uploadBinary(
            path,
            compressed,
            fileOptions: const FileOptions(upsert: false),
          );

      // إرجاع الـ public URL
      return client.storage.from(_bucket).getPublicUrl(path);
    });
  }

  /// حذف صورة بمسارها (بدون throw لو مش موجودة)
  Future<void> deleteImage(String imageUrl) async {
    try {
      final path = _pathFromUrl(imageUrl);
      if (path != null) await client.storage.from(_bucket).remove([path]);
    } catch (_) {}
  }

  Future<Uint8List> _compress(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 80,
    );
    if (result == null) throw ServerException('فشل ضغط الصورة');
    return Uint8List.fromList(result);
  }

  String _extension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    return '.jpg';
  }

  /// يستخرج المسار النسبي من الـ public URL — متاح للـ DataSources
  String? pathFromUrlPublic(String url) => _pathFromUrl(url);

  String? _pathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(_bucket);
      if (bucketIndex == -1) return null;
      return segments.sublist(bucketIndex + 1).join('/');
    } catch (_) {
      return null;
    }
  }

  Future<void> _tryDelete(String path) async {
    try {
      await client.storage.from(_bucket).remove([path]);
    } catch (_) {}
  }
}
