/**
 * Verifies admin theme tokens mirror Flutter AppColors values.
 * Run: npx tsx admin/src/lib/theme/tokens.test.ts (or node with ts-node)
 */
import { appColors } from "./tokens";

function assertEqual(actual: string, expected: string, label: string) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

assertEqual(appColors.canvas, "#131315", "canvas");
assertEqual(appColors.fieldCarbon, "#18181A", "fieldCarbon");
assertEqual(appColors.volt.toUpperCase(), "#D4FF3A", "volt");
assertEqual(appColors.soldMuted, "#3C3C3C", "soldMuted");

console.log("admin theme tokens OK");
