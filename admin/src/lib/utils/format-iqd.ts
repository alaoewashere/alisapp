// IQD has no decimals. Admin uses Western numerals (en-US grouping) per spec.
const iqdFormatter = new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 });

export function formatIqd(amount: number | null | undefined): string {
  if (amount == null) return "—";
  return `${iqdFormatter.format(amount)} د.ع`;
}

export function formatNumber(value: number | null | undefined): string {
  if (value == null) return "0";
  return iqdFormatter.format(value);
}
