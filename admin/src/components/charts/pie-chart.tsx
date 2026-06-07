"use client";

import { Cell, Legend, Pie, PieChart as RePieChart, ResponsiveContainer, Tooltip } from "recharts";

import type { SeriesPoint } from "@/components/charts/line-chart";

interface PieChartProps {
  data: SeriesPoint[];
  colors?: string[];
  height?: number;
}

const defaultColors = ["#16a34a", "#f59e0b", "#0ea5e9", "#8b5cf6", "#ef4444"];

export function PieChart({ data, colors = defaultColors, height = 280 }: PieChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RePieChart>
        <Pie
          data={data}
          dataKey="value"
          nameKey="label"
          cx="50%"
          cy="50%"
          innerRadius={60}
          outerRadius={100}
          paddingAngle={2}
        >
          {data.map((_, index) => (
            <Cell key={index} fill={colors[index % colors.length]} />
          ))}
        </Pie>
        <Tooltip
          contentStyle={{ direction: "rtl", borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12 }}
        />
        <Legend wrapperStyle={{ direction: "rtl", fontSize: 12 }} />
      </RePieChart>
    </ResponsiveContainer>
  );
}
