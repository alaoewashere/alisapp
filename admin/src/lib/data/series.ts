import { eachDayOfInterval, format, subDays } from "date-fns";
import { ar } from "date-fns/locale";

import type { SeriesPoint } from "@/components/charts/line-chart";

/**
 * Buckets rows by day over the trailing `days` window, filling gaps with zero.
 * `pick` extracts an ISO timestamp; `weight` optionally sums a numeric field
 * (e.g. revenue) instead of counting rows.
 */
export function buildDailySeries<T>(
  rows: T[],
  days: number,
  pick: (row: T) => string,
  weight?: (row: T) => number,
): SeriesPoint[] {
  const today = new Date();
  const start = subDays(today, days - 1);
  const buckets = new Map<string, number>();

  for (const day of eachDayOfInterval({ start, end: today })) {
    buckets.set(format(day, "yyyy-MM-dd"), 0);
  }

  for (const row of rows) {
    const key = format(new Date(pick(row)), "yyyy-MM-dd");
    if (buckets.has(key)) {
      buckets.set(key, (buckets.get(key) ?? 0) + (weight ? weight(row) : 1));
    }
  }

  return Array.from(buckets.entries()).map(([key, value]) => ({
    label: format(new Date(key), "d MMM", { locale: ar }),
    value,
  }));
}
