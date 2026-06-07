"use client";

import {
  CartesianGrid,
  Line,
  LineChart as ReLineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

export interface SeriesPoint {
  label: string;
  value: number;
}

interface LineChartProps {
  data: SeriesPoint[];
  color?: string;
  valueName: string;
  height?: number;
}

export function LineChart({ data, color = "#16a34a", valueName, height = 280 }: LineChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <ReLineChart data={data} margin={{ top: 8, right: 8, left: 8, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#eef2f7" vertical={false} />
        <XAxis
          dataKey="label"
          tick={{ fontSize: 11, fill: "#64748b" }}
          tickLine={false}
          axisLine={false}
          minTickGap={24}
          reversed
        />
        <YAxis
          tick={{ fontSize: 11, fill: "#64748b" }}
          tickLine={false}
          axisLine={false}
          width={32}
          allowDecimals={false}
          orientation="right"
        />
        <Tooltip
          contentStyle={{
            direction: "rtl",
            borderRadius: 8,
            border: "1px solid #e2e8f0",
            fontSize: 12,
          }}
          labelStyle={{ color: "#0f172a" }}
          formatter={(value: number) => [value, valueName]}
        />
        <Line
          type="monotone"
          dataKey="value"
          name={valueName}
          stroke={color}
          strokeWidth={2.5}
          dot={false}
          activeDot={{ r: 4 }}
        />
      </ReLineChart>
    </ResponsiveContainer>
  );
}
