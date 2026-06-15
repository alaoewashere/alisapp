import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/verification_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/verification_request_model.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ref.watch(supabaseClientProvider));
});

class VerificationRepository {
  VerificationRepository(this._client);

  final SupabaseClient _client;
  static const _bucket = 'verification-docs';

  Future<String> uploadDocumentImage({
    required String userId,
    required File file,
    required String suffix,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final safeExt = {'jpg', 'jpeg', 'png', 'webp'}.contains(ext) ? ext : 'jpg';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/${timestamp}_$suffix.$safeExt';
    final bytes = await file.readAsBytes();

    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: safeExt == 'png'
                ? 'image/png'
                : safeExt == 'webp'
                    ? 'image/webp'
                    : 'image/jpeg',
            upsert: true,
          ),
        );

    if (kDebugMode) {
      debugPrint('VerificationRepository: uploaded $path');
    }

    return path;
  }

  Future<String> signedUrlForPath(String storagePath) async {
    final result = await _client.storage
        .from(_bucket)
        .createSignedUrl(storagePath, 3600);
    return result;
  }

  Future<void> submitVerificationRequest({
    required String userId,
    required String documentType,
    required String frontImagePath,
    String? backImagePath,
  }) async {
    final now = DateTime.now().toIso8601String();

    await _client.from('verification_requests').insert({
      'user_id': userId,
      'document_type': documentType,
      'front_image_url': frontImagePath,
      if (backImagePath != null) 'back_image_url': backImagePath,
      'status': VerificationStatus.pending,
      'submitted_at': now,
    });

    await _client.from('profiles').update({
      'verification_status': VerificationStatus.pending,
      'verification_submitted_at': now,
      'verification_reviewed_at': null,
      'rejection_reason': null,
    }).eq('id', userId);
  }

  Future<VerificationRequestModel?> latestRequestForUser(String userId) async {
    final data = await _client
        .from('verification_requests')
        .select()
        .eq('user_id', userId)
        .order('submitted_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return VerificationRequestModel.fromJson(data);
  }
}
