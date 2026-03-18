import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';

/// Handles image uploads to Cloudinary for Platform.
/// Uses unsigned upload presets — no API secret needed on device.
class StorageService {
  final String _cloudName =
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  String get _uploadUrl =>
      '${AppConstants.cloudinaryUploadBaseUrl}/$_cloudName/image/upload';

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Uploads a single item image to Cloudinary.
  /// Compresses before upload. Returns the secure Cloudinary URL.
  Future<String> uploadItemImage(File file) async {
    return _upload(
      file: file,
      preset: AppConstants.cloudinaryPresetItems,
    );
  }

  /// Uploads a profile avatar image to Cloudinary.
  /// Returns the secure Cloudinary URL.
  Future<String> uploadAvatarImage(File file) async {
    return _upload(
      file: file,
      preset: AppConstants.cloudinaryPresetAvatars,
    );
  }

  /// Uploads multiple item images concurrently.
  /// Returns list of secure Cloudinary URLs in order.
  Future<List<String>> uploadItemImages(List<File> files) async {
    if (files.isEmpty) return [];
    try {
      final futures = files.map((f) => uploadItemImage(f));
      return await Future.wait(futures);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to upload images: $e');
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Deletes an image from Cloudinary by its public ID.
  /// Note: Deleting via unsigned requests is not supported by Cloudinary.
  /// Images are cleaned up via Cloudinary's auto-delete rules or admin API.
  /// This is a no-op on the client — included for API completeness.
  Future<void> deleteImage(String imageUrl) async {
    // Deletion requires signed requests (server-side).
    // For now, orphaned images are managed via Cloudinary dashboard rules.
    // TODO: Implement server-side cleanup via Firebase Cloud Functions if needed.
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<String> _upload({
    required File file,
    required String preset,
  }) async {
    // Validate cloud name is loaded
    if (_cloudName.isEmpty) {
      throw const StorageException(
        'Cloudinary cloud name not found. Check your .env file has CLOUDINARY_CLOUD_NAME set.',
      );
    }

    try {
      // Validate file size before compression
      final sizeInBytes = await file.length();
      if (sizeInBytes > AppConstants.maxImageSizeBytes * 3) {
        // Allow up to 3x limit before compression — compress will bring it down
        throw const ImageSizeException();
      }

      // Compress image
      final compressed = await _compress(file);

      // Validate compressed size
      final compressedSize = await compressed.length();
      if (compressedSize > AppConstants.maxImageSizeBytes) {
        throw const ImageSizeException();
      }

      // Build multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = preset;
      request.fields['public_id'] =
          '${path.basenameWithoutExtension(file.path)}_${const Uuid().v4()}';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        compressed.path,
      ));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw StorageException('Upload failed (${response.statusCode}): $body');
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final secureUrl = json['secure_url'] as String?;

      if (secureUrl == null) {
        throw const StorageException('Upload succeeded but no URL returned.');
      }

      return secureUrl;
    } on ImageSizeException {
      rethrow;
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException('Image upload failed: $e');
    }
  }

  /// Compresses an image file to reduce upload size.
  /// Target quality: 80. Max dimension: 1200px.
  Future<XFile> _compress(File file) async {
    final targetPath = '${file.parent.path}/compressed_${path.basename(file.path)}';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
      keepExif: false,
    );
    if (result == null) {
      // If compression fails, return original
      return XFile(file.path);
    }
    return result;
  }
}
