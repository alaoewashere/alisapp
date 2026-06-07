"use client";

import { LineChart, type SeriesPoint } from "@/components/charts/line-chart";

export function UsersChart({ data }: { data: SeriesPoint[] }) {
  return <LineChart data={data} color="#0ea5e9" valueName="مستخدمون جدد" />;
}
