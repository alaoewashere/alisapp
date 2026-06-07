"use client";

import { LineChart, type SeriesPoint } from "@/components/charts/line-chart";

/** Revenue from paid boosts (boosts.amount_paid) per day. */
export function RevenueChart({ data }: { data: SeriesPoint[] }) {
  return <LineChart data={data} color="#f59e0b" valueName="الإيرادات (د.ع)" />;
}
