/**
 * Verifies sidebar active-route resolution.
 * Run: npx tsx admin/src/lib/constants/nav.test.ts
 */
import { isNavItemActive, titleForPath } from "./nav";

function assert(condition: boolean, message: string) {
  if (!condition) throw new Error(message);
}

assert(isNavItemActive("/dashboard", "/dashboard"), "overview exact");
assert(!isNavItemActive("/dashboard/listings", "/dashboard"), "listings not overview");
assert(isNavItemActive("/dashboard/listings", "/dashboard/listings"), "listings exact");
assert(
  isNavItemActive("/dashboard/listings/abc", "/dashboard/listings"),
  "listing detail under listings",
);
assert(!isNavItemActive("/dashboard/listings", "/dashboard/users"), "users not listings");
assert(titleForPath("/dashboard/listings") === "الإعلانات", "title listings");
assert(titleForPath("/dashboard") === "نظرة عامة", "title overview");

console.log("admin nav routes OK");
