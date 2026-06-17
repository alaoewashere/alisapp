/**
 * Verifies package tier resolution for admin listing detail.
 * Run: npx tsx admin/src/lib/utils/listing-package-tier.test.ts
 */

type ListingPackageTier = "standard" | "pro" | "premium";

interface ListingLike {
  is_featured: boolean;
  is_boosted: boolean;
  metadata?: Record<string, unknown> | null;
}

function packageTierFromListing(listing: ListingLike): ListingPackageTier {
  const meta = listing.metadata;
  const pkg = meta?.listing_package;
  if (listing.is_featured || pkg === "premium") return "premium";
  if (listing.is_boosted || pkg === "pro") return "pro";
  return "standard";
}

function assertEqual<T>(actual: T, expected: T, label: string) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

assertEqual(
  packageTierFromListing({
    is_featured: false,
    is_boosted: false,
    metadata: { listing_package: "standard" },
  }),
  "standard",
  "metadata standard",
);

assertEqual(
  packageTierFromListing({
    is_featured: false,
    is_boosted: true,
    metadata: { listing_package: "pro" },
  }),
  "pro",
  "pro boosted",
);

assertEqual(
  packageTierFromListing({
    is_featured: true,
    is_boosted: false,
    metadata: { listing_package: "premium" },
  }),
  "premium",
  "premium featured",
);

console.log("listing package tier resolution OK");
