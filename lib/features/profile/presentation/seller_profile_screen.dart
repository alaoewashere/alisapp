import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_screen.dart';

/// Legacy route — redirects to unified [ProfileScreen].
class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileScreen(userId: sellerId);
  }
}
