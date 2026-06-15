import '../../core/constants/app_constants.dart';

/// Formats seconds as `m:ss` (e.g. 0:42).
String formatVideoDuration(int totalSeconds) {
  final clamped = totalSeconds.clamp(0, 5999);
  final minutes = clamped ~/ 60;
  final seconds = clamped % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class VideoValidationResult {
  const VideoValidationResult({
    required this.isValid,
    this.durationSeconds,
    this.errorMessage,
  });

  final bool isValid;
  final int? durationSeconds;
  final String? errorMessage;
}

VideoValidationResult validateVideoConstraints({
  required int durationSeconds,
  required int fileSizeBytes,
}) {
  if (fileSizeBytes > AppConstants.maxListingVideoBytes) {
    return const VideoValidationResult(
      isValid: false,
      errorMessage: 'حجم الفيديو كبير جداً، الحد الأقصى 200 ميغابايت',
    );
  }
  if (durationSeconds > AppConstants.maxListingVideoDurationSeconds) {
    return VideoValidationResult(
      isValid: false,
      durationSeconds: durationSeconds,
      errorMessage: 'الفيديو يجب أن لا يتجاوز 60 ثانية',
    );
  }
  if (durationSeconds < 1) {
    return const VideoValidationResult(
      isValid: false,
      errorMessage: 'الفيديو قصير جداً',
    );
  }
  return VideoValidationResult(
    isValid: true,
    durationSeconds: durationSeconds,
  );
}
