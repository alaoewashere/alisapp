"use client";

import { usePathname, useRouter, useSearchParams } from "next/navigation";

import { Button } from "@/components/ui/button";

const presets = [
  { days: "7", label: "٧ أيام" },
  { days: "30", label: "٣٠ يوم" },
  { days: "90", label: "٩٠ يوم" },
];

export function RangeSelector() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const current = searchParams.get("days") ?? "30";

  function select(days: string) {
    const params = new URLSearchParams(searchParams.toString());
    params.set("days", days);
    router.push(`${pathname}?${params.toString()}`);
  }

  return (
    <div className="flex items-center gap-2">
      {presets.map((p) => (
        <Button
          key={p.days}
          size="sm"
          variant={current === p.days ? "default" : "outline"}
          onClick={() => select(p.days)}
        >
          {p.label}
        </Button>
      ))}
    </div>
  );
}
