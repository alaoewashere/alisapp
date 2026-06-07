"use client";

import {
  Bar,
  BarChart as ReBarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import type { SeriesPoint } from "@/components/charts/line-chart";

interface BarChartProps {
  data: SeriesPoint[];
  valueName: string;
  color?: string;
  horizontal?: boolean;
  height?: number;
}

const palette = ["#16a34a", "#0ea5e9", "#f59e0b", "#8b5cf6", "#ef4444", "#14b8a6"];

export function BarChart({ data, valueName, color, horizontal, height = 300 }: BarChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <ReBarChart
        data={data}
        layout={horizontal ? "vertical" : "horizontal"}
        margin={{ top: 8, right: 8, left: 8, bottom: 0 }}
      >
        <CartesianGrid strokeDasharray="3 3" stroke="#eef2f7" vertical={!horizontal} horizontal={horizontal} />
        {horizontal ? (
          <>
            <XAxis type="number" tick={{ fontSize: 11, fill: "#64748b" }} axisLine={false} tickLine={false} allowDecimals={false} orientation="top" />
            <YAxis type="category" dataKey="label" tick={{ fontSize: 11, fill: "#64748b" }} axisLine={false} tickLine={false} width={90} orientation="right" />
          </>
        ) : (
          <>
            <XAxis dataKey="label" tick={{ fontSize: 11, fill: "#64748b" }} axisLine={false} tickLine={false} reversed />
            <YAxis tick={{ fontSize: 11, fill: "#64748b" }} axisLine={false} tickLine={false} width={32} allowDecimals={false} orientation="right" />
          </>
        )}
        <Tooltip
          cursor={{ fill: "#f1f5f9" }}
          contentStyle={{ direction: "rtl", borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 12 }}
          formatter={(value: number) => [value, valueName]}
        />
        <Bar dataKey="value" name={valueName} radius={horizontal ? [0, 6, 6, 0] : [6, 6, 0, 0]}>
          {data.map((_, index) => (
            <Cell key={index} fill={color ?? palette[index % palette.length]} />
          ))}
        </Bar>
      </ReBarChart>
    </ResponsiveContainer>
  );
}
