class ProfileStats {
  const ProfileStats({
    required this.totalListings,
    required this.activeListings,
    required this.totalViews,
    required this.memberSince,
  });

  final int totalListings;
  final int activeListings;
  final int totalViews;
  final DateTime memberSince;
}
