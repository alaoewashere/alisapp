import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Native Sign in with Apple → Supabase session (no PKCE / deep link).
Future<AuthResponse> signInWithAppleNative(GoTrueClient auth) async {
  final rawNonce = auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null || idToken.isEmpty) {
    throw const AuthException('Missing Apple identity token');
  }

  final response = await auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );

  // Apple returns the user's name ONLY on the first authorization, and only in
  // the credential (not the idToken). Persist it so profile setup can prefill.
  final fullName =
      '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
  if (fullName.isNotEmpty && response.user != null) {
    try {
      await auth.updateUser(
        UserAttributes(data: {'full_name': fullName, 'display_name': fullName}),
      );
    } catch (_) {
      // Non-fatal — the user can still type their name in profile setup.
    }
  }

  return response;
}
