/**
 * Verifies deterministic Baghdad datetime formatting (SSR-safe).
 * Run: npx tsx admin/src/lib/utils/format-datetime.test.ts
 */
import {
  formatBaghdadDateTime,
  isPostingBanActive,
} from "./format-datetime";

function assert(condition: boolean, message: string) {
  if (!condition) throw new Error(message);
}

assert(formatBaghdadDateTime(null) === "—", "null");
assert(formatBaghdadDateTime("2026-06-18T00:08:27.178Z") === "2026-06-18 03:08", "baghdad offset");

const future = new Date(Date.now() + 60_000).toISOString();
assert(isPostingBanActive(true, future), "active timed ban");
assert(!isPostingBanActive(true, "2020-01-01T00:00:00.000Z"), "expired ban");
assert(isPostingBanActive(true, null), "permanent ban");

console.log("format-datetime OK");
