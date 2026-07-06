import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_reader.dart';

/// Supabase credentials from `.env` (dev) or `--dart-define` (CI/release).
class SupabaseConfig {
  SupabaseConfig._();

  static String get url => EnvReader.optional(
        'SUPABASE_URL',
        fromDefine: const String.fromEnvironment('SUPABASE_URL'),
      );

  static String get anonKey => EnvReader.optional(
        'SUPABASE_ANON_KEY',
        fromDefine: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

Future<void> initializeSupabase() async {
  if (!SupabaseConfig.isConfigured) return;

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      // Handled explicitly in [AuthSessionHandler] via app_links.
      detectSessionInUri: false,
    ),
  );
}

/// Global Supabase client (available after [initializeSupabase]).
SupabaseClient get supabase => Supabase.instance.client;

/// Currently signed-in user, if any.
User? get currentUser => supabase.auth.currentUser;

final supabaseClientProvider = Provider<SupabaseClient>((ref) => supabase);

final authStateProvider = StreamProvider<AuthState>((ref) {
  final stream = ref.watch(supabaseClientProvider).auth.onAuthStateChange;
  return stream.handleError((Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('authStateProvider stream error (ignored): $error');
    }
  });
});

final currentSessionProvider = Provider<Session?>((ref) {
  final auth = ref.watch(authStateProvider);
  // Never fail dependents when Realtime/auth stream hiccups — use local snapshot.
  return auth.when(
    data: (_) => ref.watch(supabaseClientProvider).auth.currentSession,
    loading: () => ref.watch(supabaseClientProvider).auth.currentSession,
    error: (_, _) => ref.watch(supabaseClientProvider).auth.currentSession,
  );
});

final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  final client = ref.watch(supabaseClientProvider);
  return auth.when(
    data: (_) => client.auth.currentSession?.user.id ?? client.auth.currentUser?.id,
    loading: () =>
        client.auth.currentSession?.user.id ?? client.auth.currentUser?.id,
    error: (_, _) =>
        client.auth.currentSession?.user.id ?? client.auth.currentUser?.id,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserIdProvider) != null;
});
