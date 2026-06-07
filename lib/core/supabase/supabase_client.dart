import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase credentials from `.env` (dev) or `--dart-define` (CI/release).
class SupabaseConfig {
  SupabaseConfig._();

  static String get url {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['SUPABASE_URL']?.trim() ?? '';
  }

  static String get anonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
  }

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
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentSessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(supabaseClientProvider).auth.currentSession;
});

final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentSession?.user.id ?? client.auth.currentUser?.id;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserIdProvider) != null;
});
