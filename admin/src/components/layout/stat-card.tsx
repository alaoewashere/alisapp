import { ArrowDownRight, ArrowUpRight, type LucideIcon } from "lucide-react";

import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils/cn";

interface StatCardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  /** Percentage change vs the comparison period. */
  trend?: number | null;
  trendLabel?: string;
  accent?: "primary" | "amber" | "red" | "blue";
}

const accentMap = {
  primary: "bg-primary/10 text-primary",
  amber: "bg-amber-100 text-amber-700",
  red: "bg-red-100 text-red-700",
  blue: "bg-blue-100 text-blue-700",
} as const;

export function StatCard({
  label,
  value,
  icon: Icon,
  trend,
  trendLabel = "مقارنة بالأمس",
  accent = "primary",
}: StatCardProps) {
  const hasTrend = trend != null && Number.isFinite(trend);
  const positive = (trend ?? 0) >= 0;

  return (
    <Card className="p-5">
      <div className="flex items-start justify-between">
        <div className="space-y-1">
          <p className="text-sm text-muted-foreground">{label}</p>
          <p className="text-3xl font-bold text-foreground">{value}</p>
        </div>
        <div className={cn("flex size-11 items-center justify-center rounded-xl", accentMap[accent])}>
          <Icon className="size-5" />
        </div>
      </div>
      {hasTrend && (
        <div className="mt-3 flex items-center gap-1 text-sm">
          <span
            className={cn(
              "inline-flex items-center gap-0.5 font-medium",
              positive ? "text-emerald-600" : "text-red-600",
            )}
          >
            {positive ? <ArrowUpRight className="size-4" /> : <ArrowDownRight className="size-4" />}
            {Math.abs(trend!).toFixed(0)}%
          </span>
          <span className="text-muted-foreground">{trendLabel}</span>
        </div>
      )}
    </Card>
  );
}
