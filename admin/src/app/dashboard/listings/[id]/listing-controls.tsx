"use client";

import * as React from "react";
import { ChevronDown, Loader2 } from "lucide-react";

import { setListingPackage, setListingStatus } from "@/app/actions/listings";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils/cn";
import { appColors } from "@/lib/theme/tokens";
import type { ListingStatus } from "@/lib/types/database.types";

export type ListingPackageTier = "standard" | "pro" | "premium";

const STATUS_OPTIONS: { value: ListingStatus; label: string }[] = [
  { value: "approved", label: "مقبول" },
  { value: "pending", label: "قيد المراجعة" },
  { value: "rejected", label: "مرفوض" },
];

const PACKAGE_OPTIONS: { value: ListingPackageTier; label: string }[] = [
  { value: "standard", label: "إعلان مجاني" },
  { value: "pro", label: "إعلان برو" },
  { value: "premium", label: "إعلان مميز" },
];

const fieldCarbon = appColors.fieldCarbon;
const pureWhite = appColors.pureWhite;

export function StatusControl({ id, status }: { id: string; status: ListingStatus }) {
  const [value, setValue] = React.useState<ListingStatus>(status);
  const [error, setError] = React.useState<string | null>(null);
  const [pending, start] = React.useTransition();

  React.useEffect(() => {
    setValue(status);
  }, [status]);

  function onChange(next: ListingStatus) {
    const previous = value;
    setError(null);
    setValue(next);
    start(async () => {
      const fd = new FormData();
      fd.set("id", id);
      fd.set("status", next);
      const result = await setListingStatus(fd);
      if (result.ok === false) {
        setValue(previous);
        setError(result.error);
      }
    });
  }

  const selectedLabel =
    STATUS_OPTIONS.find((option) => option.value === value)?.label ?? "—";

  return (
    <div className="space-y-2">
      <div className="relative">
        <select
          value={value}
          disabled={pending}
          onChange={(e) => onChange(e.target.value as ListingStatus)}
          aria-label="حالة المراجعة"
          className={cn(
            "admin-dark-select h-11 w-full appearance-none rounded-[14px] border border-white/20",
            "px-3 py-2 pl-9 text-sm font-bold text-transparent",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4FF3A]/50",
            "disabled:cursor-not-allowed disabled:opacity-60",
          )}
          style={{
            backgroundColor: fieldCarbon,
            colorScheme: "dark",
            WebkitTextFillColor: "transparent",
          }}
        >
          {STATUS_OPTIONS.map((option) => (
            <option
              key={option.value}
              value={option.value}
              style={{ backgroundColor: fieldCarbon, color: pureWhite }}
            >
              {option.label}
            </option>
          ))}
        </select>
        <ChevronDown
          className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-white/60"
          aria-hidden
        />
        {/* Visible label mirror — native select text is unreliable on some browsers */}
        <span
          className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-sm font-bold text-white"
          aria-hidden
        >
          {selectedLabel}
        </span>
      </div>
      {pending && (
        <div className="flex items-center gap-2 text-xs text-white/60">
          <Loader2 className="size-3.5 animate-spin" />
          جاري التحديث...
        </div>
      )}
      {error && <p className="text-xs text-[#F44336]">{error}</p>}
    </div>
  );
}

export function ListingStatusChips({
  status,
  availability,
  isFeatured,
}: {
  status: ListingStatus;
  availability: string;
  isFeatured: boolean;
}) {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Badge
        variant={
          status === "approved" ? "success" : status === "pending" ? "warning" : "destructive"
        }
      >
        {status === "approved" ? "مقبول" : status === "pending" ? "قيد المراجعة" : "مرفوض"}
      </Badge>
      <Badge
        variant={
          availability === "active"
            ? "success"
            : availability === "sold"
              ? "secondary"
              : "destructive"
        }
      >
        {availability === "active" ? "نشط" : availability === "sold" ? "مباع" : "محذوف"}
      </Badge>
      {isFeatured && <Badge variant="default">مميز</Badge>}
    </div>
  );
}

export function PackageTierControl({
  id,
  initialPackage,
}: {
  id: string;
  initialPackage: ListingPackageTier;
}) {
  const [value, setValue] = React.useState<ListingPackageTier>(initialPackage);
  const [error, setError] = React.useState<string | null>(null);
  const [pending, start] = React.useTransition();

  React.useEffect(() => {
    setValue(initialPackage);
  }, [initialPackage]);

  function onSelect(next: ListingPackageTier) {
    if (next === value || pending) return;
    const previous = value;
    setError(null);
    setValue(next);
    start(async () => {
      const fd = new FormData();
      fd.set("id", id);
      fd.set("package", next);
      const result = await setListingPackage(fd);
      if (result.ok === false) {
        setValue(previous);
        setError(result.error);
      }
    });
  }

  return (
    <div className="space-y-4">
      {PACKAGE_OPTIONS.map((option) => {
        const selected = value === option.value;
        return (
          <button
            key={option.value}
            type="button"
            disabled={pending}
            onClick={() => onSelect(option.value)}
            className={cn(
              "flex w-full items-center gap-3 rounded-[14px] border px-3 py-3 transition-colors",
              selected
                ? "border-[#D4FF3A]/50 bg-[#D4FF3A]/10"
                : "border-white/20 bg-[#18181A] hover:border-white/35",
            )}
          >
            <span
              className={cn(
                "flex size-5 shrink-0 items-center justify-center rounded-full border-2",
                selected ? "border-[#D4FF3A] bg-[#D4FF3A]" : "border-white/50 bg-transparent",
              )}
            >
              {selected && <span className="size-2 rounded-full bg-[#131315]" />}
            </span>
            <span className="text-sm font-bold text-white">{option.label}</span>
            {pending && selected && (
              <Loader2 className="ms-auto size-4 animate-spin text-white/50" />
            )}
          </button>
        );
      })}
      {error && <p className="text-xs text-[#F44336]">{error}</p>}
    </div>
  );
}
