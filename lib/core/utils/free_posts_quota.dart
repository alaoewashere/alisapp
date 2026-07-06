/// Ongoing free standard-tier listing posts per user, per calendar week
/// (resets Monday). Separate from the one-time launch-week unlimited promo.
const weeklyFreeListingLimit = 1;

int remainingFreePosts(int usedThisWeek) {
  final remaining = weeklyFreeListingLimit - usedThisWeek;
  return remaining < 0 ? 0 : remaining;
}

/// [unlimitedUntil] is the one-time launch-week promo end date fetched from
/// the `app_settings` table (key `free_posts_unlimited_until`) — while
/// active, the free quota is bypassed entirely so every user can post as
/// many standard listings as they want. After it expires, the ongoing
/// policy applies: 1 free standard listing per calendar week.
bool standardListingRequiresPayment(
  int usedThisWeek, {
  DateTime? unlimitedUntil,
}) {
  if (unlimitedUntil != null && DateTime.now().isBefore(unlimitedUntil)) {
    return false;
  }
  return usedThisWeek >= weeklyFreeListingLimit;
}
