/** Minimal CSV export — escapes quotes/commas, prepends a UTF-8 BOM for Excel. */
export function exportToCsv(
  filename: string,
  rows: Record<string, unknown>[],
): void {
  if (rows.length === 0) return;
  const headers = Object.keys(rows[0]);
  const escape = (value: unknown): string => {
    const str = value == null ? "" : String(value);
    return /[",\n]/.test(str) ? `"${str.replace(/"/g, '""')}"` : str;
  };
  const lines = [
    headers.join(","),
    ...rows.map((row) => headers.map((h) => escape(row[h])).join(",")),
  ];
  const blob = new Blob(["\uFEFF" + lines.join("\n")], {
    type: "text/csv;charset=utf-8;",
  });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}
