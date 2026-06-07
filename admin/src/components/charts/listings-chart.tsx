"use client";

import { LineChart, type SeriesPoint } from "@/components/charts/line-chart";

export function ListingsChart({ data }: { data: SeriesPoint[] }) {
  return <LineChart data={data} color="#16a34a" valueName="إعلانات جديدة" />;
}
