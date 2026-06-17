/**
 * Sello design tokens — mirrors Flutter `AppColors` / `AppTextStyles`.
 * Use these values in Tailwind config and CSS variables; do not duplicate hex elsewhere.
 */
export const appColors = {
  canvas: "#131315",
  fieldCarbon: "#18181A",
  volt: "#D4FF3A",
  pureWhite: "#FFFFFF",
  textMuted: "rgba(255, 255, 255, 0.6)",
  textLight: "rgba(255, 255, 255, 0.45)",
  borderLight: "rgba(255, 255, 255, 0.08)",
  glassBorder: "rgba(255, 255, 255, 0.1)",
  rowDivider: "rgba(255, 255, 255, 0.08)",
  rejected: "#F44336",
  pending: "#FF9800",
  approved: "#D4FF3A",
  surfaceMuted: "#202023",
  soldMuted: "#3C3C3C",
} as const;

export const appRadii = {
  card: "16px",
  field: "14px",
  pill: "12px",
  button: "9999px",
} as const;
