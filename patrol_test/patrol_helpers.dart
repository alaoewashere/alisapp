import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrol/patrol.dart';
import 'package:Sello/app.dart';
import 'package:Sello/app_bootstrap.dart';
import 'package:Sello/core/supabase/supabase_client.dart';
import 'package:Sello/test_support/integration_test_prefs.dart';

bool get isPatrolSupabaseConfigured => SupabaseConfig.isConfigured;

Future<void> pumpSelloApp(PatrolIntegrationTester $) async {
  await bootstrapSelloApp();
  await markOnboardingTutorialsSeenForTests();

  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase is not configured. Run Patrol with '
      '--dart-define-from-file=env.json (and a valid env.json).',
    );
  }

  await $.pumpWidget(const ProviderScope(child: SouqIqApp()));
  // Shimmer loaders animate indefinitely — strict pumpAndSettle would time out.
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 45));
}

Future<void> openSearchTab(PatrolIntegrationTester $) async {
  await $(#bottom_nav_search).tap();
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 15));
  await $(#search_query_field).waitUntilVisible();
}

Future<void> submitNoMatchSearch(
  PatrolIntegrationTester $, {
  required String query,
}) async {
  await $(#search_query_field).enterText(query);
  // Debounced query (400ms) + suggestions provider delay (400ms).
  await $.pump(const Duration(milliseconds: 900));
  await $.pumpAndTrySettle(timeout: const Duration(seconds: 15));

  final submitButton = $(#search_suggestions_submit);
  if (submitButton.exists) {
    await submitButton.waitUntilVisible(timeout: const Duration(seconds: 20));
    await submitButton.tap();
  } else {
    await $.tester.testTextInput.receiveAction(TextInputAction.search);
    await $.pump(const Duration(milliseconds: 500));
  }

  await $.pumpAndTrySettle(timeout: const Duration(seconds: 45));
}
