const BAGHDAD_OFFSET_MS = 3 * 60 * 60 * 1000;

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

/** SSR-safe Baghdad datetime (UTC+3, fixed offset). */
export function formatBaghdadDateTime(iso: string | null | undefined): string {
  if (!iso) return "—";
  const ms = Date.parse(iso);
  if (Number.isNaN(ms)) return "—";

  const baghdad = new Date(ms + BAGHDAD_OFFSET_MS);
  return (
    `${baghdad.getUTCFullYear()}-${pad2(baghdad.getUTCMonth() + 1)}-` +
    `${pad2(baghdad.getUTCDate())} ${pad2(baghdad.getUTCHours())}:` +
    `${pad2(baghdad.getUTCMinutes())}`
  );
}

export function isPostingBanActive(
  isBanned: boolean,
  bannedUntil: string | null,
  nowMs: number = Date.now(),
): boolean {
  if (!isBanned) return false;
  if (bannedUntil === null) return true;
  const untilMs = Date.parse(bannedUntil);
  return !Number.isNaN(untilMs) && untilMs > nowMs;
}
