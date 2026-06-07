import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/data/profile_repository.dart';
import '../providers/auth_provider.dart';

/// Handles OAuth deep-link callbacks and keeps auth state in sync.
class AuthSessionHandler extends ConsumerStatefulWidget {
  const AuthSessionHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthSessionHandler> createState() => _AuthSessionHandlerState();
}

class _AuthSessionHandlerState extends ConsumerState<AuthSessionHandler> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleOAuthCallback(initial, fromColdStart: true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Initial deep link error: $e');
    }

    _appLinks.uriLinkStream.listen(
      (uri) => _handleOAuthCallback(uri, fromColdStart: false),
      onError: (Object e) {
        if (kDebugMode) debugPrint('Deep link stream error: $e');
      },
    );
  }

  Future<void> _handleOAuthCallback(
    Uri uri, {
    required bool fromColdStart,
  }) async {
    if (!_isAuthCallback(uri)) return;
    if (!_hasOAuthPayload(uri)) return;

    // Already signed in — ignore duplicate/stale callback (common after hot restart).
    if (supabase.auth.currentSession != null) {
      ref.read(authNotifierProvider.notifier).clearOAuthLoading();
      return;
    }

    try {
      await supabase.auth.getSessionFromUrl(uri);
      ref.read(authNotifierProvider.notifier).onOAuthSessionEstablished();
      ref.invalidate(currentProfileProvider);
    } on AuthException catch (e) {
      if (_isStaleOAuthCallback(e)) {
        if (kDebugMode) {
          debugPrint(
            'Ignoring stale OAuth callback'
            '${fromColdStart ? ' (cold start)' : ''}: ${e.message}',
          );
        }
        ref.read(authNotifierProvider.notifier).clearOAuthLoading();
        return;
      }
      if (kDebugMode) debugPrint('OAuth callback failed: $e');
      ref.read(authNotifierProvider.notifier).onOAuthFailed(
            'تعذّر تسجيل الدخول بـ Google. حاول مرة أخرى.',
          );
    } catch (e) {
      if (kDebugMode) debugPrint('OAuth callback error: $e');
      ref.read(authNotifierProvider.notifier).clearOAuthLoading();
    }
  }

  bool _isAuthCallback(Uri uri) {
    return uri.scheme == AppConstants.authRedirectScheme ||
        uri.toString().contains('login-callback');
  }

  bool _hasOAuthPayload(Uri uri) {
    return uri.queryParameters.containsKey('code') ||
        uri.fragment.contains('access_token') ||
        uri.queryParameters.containsKey('access_token');
  }

  bool _isStaleOAuthCallback(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('code verifier') ||
        msg.contains('flow state') ||
        msg.contains('invalid request');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
