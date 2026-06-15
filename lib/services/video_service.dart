import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../core/constants/app_constants.dart';
import '../core/supabase/supabase_client.dart';
import '../core/utils/video_utils.dart';

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService(ref.watch(supabaseClientProvider));
});

class VideoUploadResult {
  const VideoUploadResult({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
  });

  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
}

class VideoService {
  VideoService(this._client);

  final SupabaseClient _client;

  static const _videoPath = 'video.mp4';
  static const _thumbPath = 'thumb.jpg';

  /// Validates duration (≤60s) and size (≤200MB).
  Future<VideoValidationResult> validateVideo(File file) async {
    final size = await file.length();
    final duration = await _probeDurationSeconds(file.path);
    if (duration == null) {
      return const VideoValidationResult(
        isValid: false,
        errorMessage: 'تعذّر قراءة مدة الفيديو',
      );
    }
    return validateVideoConstraints(
      durationSeconds: duration,
      fileSizeBytes: size,
    );
  }

  /// Extracts a JPEG frame at ~1s using AVFoundation / MediaMetadataRetriever.
  Future<File> generateThumbnail(File videoFile) async {
    final tempDir = await getTemporaryDirectory();
    final thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 720,
      quality: 85,
      timeMs: 1000,
    );

    if (thumbPath == null) {
      throw StateError('Failed to generate video thumbnail');
    }

    final output = File(thumbPath);
    if (!await output.exists()) {
      throw StateError('Failed to generate video thumbnail');
    }
    return output;
  }

  /// Validates, generates thumbnail, uploads both files, returns public URLs.
  Future<VideoUploadResult> uploadVideo({
    required File videoFile,
    required String listingId,
    required void Function(double progress) onProgress,
  }) async {
    onProgress(0.05);
    final validation = await validateVideo(videoFile);
    if (!validation.isValid) {
      throw VideoUploadException(validation.errorMessage ?? 'فيديو غير صالح');
    }

    onProgress(0.15);
    final thumbnail = await generateThumbnail(videoFile);
    final duration = validation.durationSeconds!;

    onProgress(0.25);
    final videoStoragePath = '$listingId/$_videoPath';
    final thumbStoragePath = '$listingId/$_thumbPath';

    await _client.storage.from(AppConstants.listingVideosBucket).upload(
          videoStoragePath,
          videoFile,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'video/mp4',
          ),
        );
    onProgress(0.75);

    await _client.storage.from(AppConstants.listingVideosBucket).upload(
          thumbStoragePath,
          thumbnail,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    onProgress(0.95);

    final videoUrl = _client.storage
        .from(AppConstants.listingVideosBucket)
        .getPublicUrl(videoStoragePath);
    final thumbnailUrl = _client.storage
        .from(AppConstants.listingVideosBucket)
        .getPublicUrl(thumbStoragePath);

    onProgress(1.0);

    return VideoUploadResult(
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: duration,
    );
  }

  Future<void> deleteListingVideo(String listingId) async {
    try {
      await _client.storage.from(AppConstants.listingVideosBucket).remove([
        '$listingId/$_videoPath',
        '$listingId/$_thumbPath',
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('deleteListingVideo: $e');
    }
  }

  Future<int?> _probeDurationSeconds(String path) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      final durationMs = controller.value.duration.inMilliseconds;
      if (durationMs <= 0) return null;
      return (durationMs / 1000).ceil();
    } catch (e) {
      if (kDebugMode) debugPrint('Video duration probe failed: $e');
      return null;
    } finally {
      await controller?.dispose();
    }
  }
}

class VideoUploadException implements Exception {
  VideoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
