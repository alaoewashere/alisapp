import { format, formatDistanceToNow, parseISO } from "date-fns";
import { ar } from "date-fns/locale";

function toDate(value: string | Date): Date {
  return value instanceof Date ? value : parseISO(value);
}

/** Absolute date, e.g. "1 يونيو 2026". */
export function formatDate(value: string | Date | null | undefined): string {
  if (!value) return "—";
  return format(toDate(value), "d MMMM yyyy", { locale: ar });
}

/** Absolute date + time, e.g. "1 يونيو 2026، 14:30". */
export function formatDateTime(value: string | Date | null | undefined): string {
  if (!value) return "—";
  return format(toDate(value), "d MMM yyyy، HH:mm", { locale: ar });
}

/** "منذ 3 ساعات" style relative time. */
export function formatRelative(value: string | Date | null | undefined): string {
  if (!value) return "—";
  return formatDistanceToNow(toDate(value), { addSuffix: true, locale: ar });
}

/** YYYY-MM-DD key for grouping/charts. */
export function dateKey(value: string | Date): string {
  return format(toDate(value), "yyyy-MM-dd");
}
