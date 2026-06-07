import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/supabase/supabase_client.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/guest_bottom_sheet.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/conversations_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/listings/presentation/category_browse_screen.dart';
import '../../features/listings/presentation/edit_listing_screen.dart';
import '../../features/listings/presentation/listing_detail_screen.dart';
import '../../features/listings/presentation/listings_screen.dart';
import '../../features/listings/presentation/post_listing_screen.dart';
import '../../features/listings/presentation/search_results_screen.dart';
import '../../features/listings/presentation/search_screen.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/my_listings_screen.dart';
import '../../features/profile/presentation/notifications_settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/seller_profile_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/models/listing_model.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const phone = '/phone';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';
  static const search = '/search';
  static const searchResults = '/search/results';
  static const listing = '/listing/:id';
  static const listings = '/listings/:categoryId';
  static const categoryBrowse = '/categories/:categoryId';
  static const createListing = '/listing/create';
  static const post = '/post';
  static const myListings = '/my-listings';
  static const favorites = '/favorites';
  static const conversations = '/conversations';
  static const chat = '/chat/:id';
  static const profile = '/profile';
  static const settings = '/settings';
  static const editProfile = '/edit-profile';
  static const notificationsSettings = '/notifications-settings';

  /// Legacy alias — redirects to [phone].
  static const login = phone;

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
}

bool isGuestAllowedPath(String path) {
  if (path == AppRoutes.home ||
      path == AppRoutes.search ||
      path == AppRoutes.searchResults) {
    return true;
  }
  if (path.startsWith('/listings/')) return true;
  if (path.startsWith('/categories/')) return true;
  if (RegExp(r'^/listing/[^/]+$').hasMatch(path)) return true;
  return false;
}

bool isGuestBlockedPath(String path) {
  return path.startsWith(AppRoutes.favorites) ||
      path.startsWith(AppRoutes.conversations) ||
      path.startsWith(AppRoutes.profile) ||
      path == AppRoutes.createListing ||
      path == AppRoutes.post ||
      path.startsWith(AppRoutes.myListings) ||
      path.startsWith('/chat/');
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authFlow = ref.read(authNotifierProvider);
      final session = ref.read(currentSessionProvider);
      final isGuest = ref.read(isGuestProvider);
      final path = state.matchedLocation;

      final isAuthFlow = path == AppRoutes.phone ||
          path == AppRoutes.otp ||
          path == AppRoutes.profileSetup;

      // OTP was sent — keep user on the verification screen (router-driven so
      // navigation survives refresh races from auth state / guest mode updates).
      if (authFlow.status == AuthFlowStatus.otpSent &&
          authFlow.phone != null &&
          authFlow.phone!.isNotEmpty) {
        if (path == AppRoutes.otp) return null;
        return '${AppRoutes.otp}?phone=${Uri.encodeComponent(authFlow.phone!)}';
      }

      if (session == null) {
        if (isAuthFlow) return null;
        if (isGuest && isGuestAllowedPath(path)) return null;
        if (isGuest && isGuestBlockedPath(path)) return AppRoutes.home;
        return AppRoutes.phone;
      }

      final profileAsync = ref.read(currentProfileProvider);
      if (profileAsync.isLoading) return null;

      final profileComplete = profileAsync.maybeWhen(
        data: (profile) => profile?.isComplete ?? false,
        orElse: () => false,
      );

      if (profileComplete && path == AppRoutes.profileSetup) {
        return AppRoutes.home;
      }

      if (!profileComplete && path != AppRoutes.profileSetup) {
        return AppRoutes.profileSetup;
      }

      if (profileComplete && (path == AppRoutes.phone || path == AppRoutes.otp)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppBottomNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
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
        path: AppRoutes.phone,
        builder: (_, _) => const PhoneScreen(),
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
        path: AppRoutes.listing,
        builder: (_, state) => ListingDetailScreen(
          listingId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => EditListingScreen(
              listingId: state.pathParameters['id']!,
            ),
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
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
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
        path: AppRoutes.chat,
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (_, state) {
      final strings = ref.read(appLocalizationsProvider);
      return Scaffold(
        appBar: AppBar(title: Text(strings.appName)),
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

void navigateToLogin(BuildContext context) {
  context.push(AppRoutes.phone);
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
    context.push(AppRoutes.phone);
  }
  return false;
}
