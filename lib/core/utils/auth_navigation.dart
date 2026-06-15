import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/username_prefs.dart';
import '../router/app_router.dart';
import '../supabase/supabase_client.dart';
import '../../features/profile/data/profile_repository.dart';

/// Resolves the first screen after a successful sign-in / sign-up.
Future<String> resolvePostAuthRoute(WidgetRef ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return AppRoutes.login;

  final prefs = await SharedPreferences.getInstance();
  final skipped = prefs.getBool(usernameSetupSkippedKey) ?? false;
  final profile = await ref.read(profileRepositoryProvider).getProfile(userId);

  if (profile == null) {
    return skipped ? AppRoutes.profileSetup : AppRoutes.usernameSetup;
  }

  if (!profile.hasUsername && !skipped) {
    return AppRoutes.usernameSetup;
  }

  if (!profile.isComplete) {
    return AppRoutes.profileSetup;
  }

  return AppRoutes.home;
}
