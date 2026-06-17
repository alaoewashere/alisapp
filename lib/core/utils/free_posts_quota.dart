/// Monthly free standard-tier listing posts per user.
const monthlyFreeListingLimit = 2;

int remainingFreePosts(int usedThisMonth) {
  final remaining = monthlyFreeListingLimit - usedThisMonth;
  return remaining < 0 ? 0 : remaining;
}

bool standardListingRequiresPayment(int usedThisMonth) {
  return usedThisMonth >= monthlyFreeListingLimit;
}
