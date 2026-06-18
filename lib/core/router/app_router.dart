import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/username_prefs.dart';
import '../../core/constants/verification_constants.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/supabase/supabase_client.dart';
import '../../shared/widgets/sello_app_bar.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../screens/auth/email_verify_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/phone_verify_screen.dart';
import '../../screens/auth/username_setup_screen.dart';
import '../../screens/auth/password_reset_email_sent_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/ratings_screen.dart';
import '../../screens/verification/verification_document_type_screen.dart';
import '../../screens/verification/verification_intro_screen.dart';
import '../../screens/verification/verification_success_screen.dart';
import '../../screens/verification/verification_upload_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/guest_bottom_sheet.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/conversations_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_feed_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/models/home_listings_feed_type.dart';
import '../../features/listings/presentation/category_browse_screen.dart';
import '../../features/listings/presentation/edit_listing_screen.dart';
import '../../features/listings/presentation/listing_detail_screen.dart';
import '../../features/listings/presentation/listings_screen.dart';
import '../../features/listings/presentation/post_listing_screen.dart';
import '../../features/listings/presentation/listing_heatmap_screen.dart';
import '../../features/listings/presentation/search_results_screen.dart';
import '../../features/listings/presentation/search_screen.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../screens/settings/edit_profile_screen.dart';
import '../../screens/settings/profile_phone_otp_screen.dart';
import '../../features/profile/presentation/my_listings_screen.dart';
import '../../features/profile/presentation/notifications_settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../screens/settings/language_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../features/profile/presentation/seller_profile_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../screens/smart_alerts/create_alert_screen.dart';
import '../../screens/smart_alerts/my_alerts_screen.dart';
import '../../models/smart_alert.dart';
import '../../shared/models/listing_model.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const homeNav = '/home';
  static const login = '/login';
  static const phone = '/phone';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const phoneVerify = '/phone-verify';
  static const profilePhoneVerify = '/profile-phone-verify';
  static const emailVerify = '/email-verify';
  static const passwordResetEmailSent = '/password-reset-email-sent';
  static const resetPassword = '/reset-password';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';
  static const usernameSetup = '/username-setup';
  static const search = '/search';
  static const searchResults = '/search/results';
  static const heatmap = '/heatmap';
  static const homeFeed = 'feed/:feedType';
  static const listing = '/listing/:id';
  static const editListing = '/listing/edit/:listingId';
  static const listings = '/listings/:categoryId';
  static const categoryBrowse = '/categories/:categoryId';
  static const createListing = '/listing/create';
  static const post = '/post';
  static const myListings = '/my-listings';
  static const favorites = '/favorites';
  static const conversations = '/conversations';
  static const chat = '/chat/:id';
  static const profile = '/profile';
  static const ratings = '/ratings/:profileId';
  static const settings = '/settings';
  static const language = '/language';
  static const editProfile = '/edit-profile';
  static const notificationsSettings = '/notifications-settings';
  static const smartAlerts = '/smart-alerts';
  static const createSmartAlert = '/smart-alerts/create';
  static const verificationIntro = '/verification';
  static const verificationDocumentType = '/verification/document-type';
  static const verificationUpload = '/verification/upload';
  static const verificationSuccess = '/verification/success';

  /// Resolved navigation paths (never append to [categoryBrowse] / [listings] constants).
  static String categoryBrowsePath(
    int categoryId, {
    String? listingType,
  }) {
    final path = '/categories/$categoryId';
    if (listingType == null || listingType.isEmpty) return path;
    return '$path?$listingTypeQueryKey=$listingType';
  }

  static String listingsPath(
    String categoryId, {
    String? listingType,
  }) {
    final path = '/listings/$categoryId';
    if (listingType == null || listingType.isEmpty) return path;
    return '$path?$listingTypeQueryKey=$listingType';
  }

  static String? listingTypeFromUri(Uri uri) =>
      uri.queryParameters[listingTypeQueryKey];

  static String editListingPath(String listingId) => '/listing/edit/$listingId';

  static String homeFeedPath(HomeListingsFeedType type) => '/feed/${type.slug}';
}

bool isGuestAllowedPath(String path) {
  if (path == AppRoutes.language) return true;
  if (path == AppRoutes.home ||
      path == AppRoutes.homeNav ||
      path == AppRoutes.search ||
      path == AppRoutes.searchResults ||
      path == AppRoutes.heatmap) {
    return true;
  }
  if (path.startsWith('/listings/')) return true;
  if (path.startsWith('/feed/')) return true;
  if (path.startsWith('/categories/')) return true;
  if (RegExp(r'^/listing/[^/]+$').hasMatch(path)) return true;
  if (path.startsWith('/seller/')) return true;
  if (path.startsWith('/ratings/')) return true;
  return false;
}

bool isGuestBlockedPath(String path) {
  return path.startsWith(AppRoutes.favorites) ||
      path.startsWith(AppRoutes.conversations) ||
      path.startsWith(AppRoutes.profile) ||
      path == AppRoutes.createListing ||
      path == AppRoutes.post ||
      path.startsWith(AppRoutes.myListings) ||
      path.startsWith('/listing/edit/') ||
      path.startsWith(AppRoutes.smartAlerts) ||
      path.startsWith('/chat/');
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      try {
        return await _resolveRedirect(ref, state);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('Router redirect error (ignored): $e\n$st');
        }
        return null;
      }
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppBottomNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'heatmap',
                builder: (_, _) => const ListingHeatmapScreen(),
              ),
              GoRoute(
                path: AppRoutes.homeFeed,
                builder: (_, state) {
                  final feedType = HomeListingsFeedType.fromSlug(
                    state.pathParameters['feedType'] ?? '',
                  );
                  if (feedType == null) {
                    return const HomeScreen();
                  }
                  return HomeFeedScreen(feedType: feedType);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.homeNav,
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (_, _) => const SearchScreen(),
            routes: [
              GoRoute(
                path: 'results',
                builder: (_, _) => const SearchResultsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.conversations,
            builder: (_, _) => const ConversationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.listings,
        builder: (_, state) => ListingsScreen(
          categoryId: state.pathParameters['categoryId']!,
          listingType: AppRoutes.listingTypeFromUri(state.uri),
        ),
      ),
      GoRoute(
        path: AppRoutes.categoryBrowse,
        builder: (_, state) => CategoryBrowseScreen(
          categoryId: int.parse(state.pathParameters['categoryId']!),
          listingType: ListingType.fromQuery(
            AppRoutes.listingTypeFromUri(state.uri),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        redirect: (_, _) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneVerify,
        builder: (_, state) => PhoneVerifyScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
          purpose: state.uri.queryParameters['purpose'],
        ),
      ),
      GoRoute(
        path: AppRoutes.profilePhoneVerify,
        builder: (_, state) => ProfilePhoneOtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.emailVerify,
        builder: (_, state) => EmailVerifyScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.passwordResetEmailSent,
        builder: (_, state) => PasswordResetEmailSentScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, _) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.usernameSetup,
        builder: (_, _) => const UsernameSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.createListing,
        builder: (_, _) => const PostListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.post,
        builder: (_, _) => const PostListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (_, _) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.editListing,
        builder: (_, state) => EditListingScreen(
          listingId: state.pathParameters['listingId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.listing,
        builder: (_, state) {
          final param = state.pathParameters['id']!;
          if (RegExp(r'^\d+$').hasMatch(param)) {
            return ListingDetailScreen(referenceNo: int.parse(param));
          }
          return ListingDetailScreen(listingId: param);
        },
        routes: [
          GoRoute(
            path: 'edit',
            redirect: (_, state) {
              final id = state.pathParameters['id'];
              if (id == null) return AppRoutes.home;
              return AppRoutes.editListingPath(id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/seller/:sellerId',
        builder: (_, state) => SellerProfileScreen(
          sellerId: state.pathParameters['sellerId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.myListings,
        builder: (_, _) => const MyListingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ratings,
        builder: (_, state) => RatingsScreen(
          profileId: state.pathParameters['profileId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (_, state) => LanguageScreen(
          isOnboarding: state.uri.queryParameters['onboarding'] != 'false',
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationsSettings,
        builder: (_, _) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.smartAlerts,
        builder: (_, _) => const MyAlertsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createSmartAlert,
        builder: (_, state) => CreateAlertScreen(
          prefill: state.extra as SmartAlertDraft?,
        ),
      ),
      GoRoute(
        path: AppRoutes.verificationIntro,
        builder: (_, _) => const VerificationIntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationDocumentType,
        builder: (_, _) => const VerificationDocumentTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationUpload,
        builder: (_, state) => VerificationUploadScreen(
          documentType: state.uri.queryParameters['type'] ??
              VerificationDocumentType.nationalId,
        ),
      ),
      GoRoute(
        path: AppRoutes.verificationSuccess,
        builder: (_, _) => const VerificationSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (_, state) {
      final strings = ref.read(appLocalizationsProvider);
      return Scaffold(
        appBar: SelloAppBar(title: Text(strings.appName)),
        body: Center(child: Text('${strings.pageNotFound}: ${state.uri}')),
      );
    },
  );

  ref.listen(authStateProvider, (_, _) => router.refresh());
  ref.listen(authNotifierProvider, (_, _) => router.refresh());
  ref.listen(currentProfileProvider, (_, _) => router.refresh());
  ref.listen(isGuestProvider, (_, _) => router.refresh());
  ref.listen(localeProvider, (_, _) => router.refresh());

  return router;
});

Future<String?> _resolveRedirect(Ref ref, GoRouterState state) async {
  final authFlow = ref.read(authNotifierProvider);
  final session = SupabaseConfig.isConfigured
      ? supabase.auth.currentSession
      : null;
  final isGuest = ref.read(isGuestProvider);
  final path = state.matchedLocation;
  final isLanguageOnboarding =
      state.uri.queryParameters['onboarding'] != 'false';

  // Signed-in users skip onboarding language picker.
  if (session != null && path == AppRoutes.language && isLanguageOnboarding) {
    return AppRoutes.home;
  }

  if (path == AppRoutes.language) return null;

  final isAuthFlow = path == AppRoutes.login ||
      path == AppRoutes.phone ||
      path == AppRoutes.signUp ||
      path == AppRoutes.forgotPassword ||
      path == AppRoutes.phoneVerify ||
      path == AppRoutes.emailVerify ||
      path == AppRoutes.passwordResetEmailSent ||
      path == AppRoutes.resetPassword ||
      path == AppRoutes.otp ||
      path == AppRoutes.profileSetup ||
      path == AppRoutes.usernameSetup;

  // OTP was sent — keep user on the verification screen (router-driven so
  // navigation survives refresh races from auth state / guest mode updates).
  if (authFlow.status == AuthFlowStatus.otpSent &&
      authFlow.phone != null &&
      authFlow.phone!.isNotEmpty) {
    if (path == AppRoutes.otp) return null;
    return '${AppRoutes.otp}?phone=${Uri.encodeComponent(authFlow.phone!)}';
  }

  if (session == null) {
    if (path == AppRoutes.home || path == AppRoutes.homeNav) {
      if (isGuest) return null;
      return AppRoutes.login;
    }
    if (isAuthFlow) return null;
    if (isGuest && isGuestAllowedPath(path)) return null;
    if (isGuest && isGuestBlockedPath(path)) return AppRoutes.home;
    return AppRoutes.login;
  }

  final profileAsync = ref.read(currentProfileProvider);
  if (profileAsync.isLoading) return null;
  if (profileAsync.hasError) return null;

  final profileComplete = profileAsync.maybeWhen(
    data: (profile) => profile?.isComplete ?? false,
    orElse: () => false,
  );

  final hasUsername = profileAsync.maybeWhen(
    data: (profile) => profile?.hasUsername ?? false,
    orElse: () => false,
  );

  final prefs = await SharedPreferences.getInstance();
  final usernameSkipped = prefs.getBool(usernameSetupSkippedKey) ?? false;
  final needsUsernameSetup = !hasUsername && !usernameSkipped;

  // Username setup first — right after sign-in.
  if (needsUsernameSetup && path != AppRoutes.usernameSetup) {
    return AppRoutes.usernameSetup;
  }

  if (path == AppRoutes.usernameSetup) {
    if (hasUsername || usernameSkipped) {
      if (!profileComplete) return AppRoutes.profileSetup;
      return AppRoutes.home;
    }
    return null;
  }

  if (!profileComplete && path != AppRoutes.profileSetup) {
    if (path == AppRoutes.editProfile ||
        path == AppRoutes.profilePhoneVerify) {
      return null;
    }
    return AppRoutes.profileSetup;
  }

  if (profileComplete && path == AppRoutes.profileSetup) {
    return AppRoutes.home;
  }

  if (path == AppRoutes.login ||
      path == AppRoutes.phone ||
      path == AppRoutes.signUp ||
      path == AppRoutes.otp ||
      path == AppRoutes.phoneVerify ||
      path == AppRoutes.language) {
    if (needsUsernameSetup) return AppRoutes.usernameSetup;
    if (!profileComplete) return AppRoutes.profileSetup;
    return AppRoutes.home;
  }

  return null;
}

void navigateToLogin(BuildContext context) {
  context.push(AppRoutes.login);
}

Future<bool> requireAuth(BuildContext context, WidgetRef ref) async {
  if (ref.read(isAuthenticatedProvider)) return true;

  if (ref.read(isGuestProvider)) {
    await showGuestBottomSheet(context);
    return false;
  }

  final strings = ref.read(appLocalizationsProvider);

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(strings.loginRequired),
      content: Text(strings.loginRequiredBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(strings.login),
        ),
      ],
    ),
  );
  if (result == true && context.mounted) {
    context.push(AppRoutes.login);
  }
  return false;
}
