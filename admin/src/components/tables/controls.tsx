"use client";

import * as React from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { ArrowUpDown, ArrowDown, ArrowUp, Search } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { cn } from "@/lib/utils/cn";

/** Builds a new querystring with the given updates; clears keys set to null. */
function useUpdateParams() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  return React.useCallback(
    (updates: Record<string, string | null>, resetPage = true) => {
      const params = new URLSearchParams(searchParams.toString());
      for (const [key, value] of Object.entries(updates)) {
        if (value === null || value === "") params.delete(key);
        else params.set(key, value);
      }
      if (resetPage) params.delete("page");
      router.push(`${pathname}?${params.toString()}`);
    },
    [router, pathname, searchParams],
  );
}

export function TableSearch({ placeholder = "بحث..." }: { placeholder?: string }) {
  const searchParams = useSearchParams();
  const update = useUpdateParams();
  const [value, setValue] = React.useState(searchParams.get("q") ?? "");
  const timer = React.useRef<ReturnType<typeof setTimeout>>();

  function onChange(next: string) {
    setValue(next);
    clearTimeout(timer.current);
    timer.current = setTimeout(() => update({ q: next || null }), 350);
  }

  return (
    <div className="relative w-full max-w-xs">
      <Search className="pointer-events-none absolute right-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="pr-9"
      />
    </div>
  );
}

interface FilterSelectProps {
  param: string;
  options: { value: string; label: string }[];
  allLabel?: string;
  className?: string;
}

export function FilterSelect({ param, options, allLabel = "الكل", className }: FilterSelectProps) {
  const searchParams = useSearchParams();
  const update = useUpdateParams();
  const current = searchParams.get(param) ?? "";

  return (
    <Select
      value={current}
      onChange={(e) => update({ [param]: e.target.value || null })}
      className={cn("w-44", className)}
    >
      <option value="">{allLabel}</option>
      {options.map((opt) => (
        <option key={opt.value} value={opt.value}>
          {opt.label}
        </option>
      ))}
    </Select>
  );
}

export function DateRangeFilter() {
  const searchParams = useSearchParams();
  const update = useUpdateParams();
  return (
    <div className="flex items-center gap-2">
      <Input
        type="date"
        value={searchParams.get("from") ?? ""}
        onChange={(e) => update({ from: e.target.value || null })}
        className="w-40"
        aria-label="من تاريخ"
      />
      <span className="text-muted-foreground">—</span>
      <Input
        type="date"
        value={searchParams.get("to") ?? ""}
        onChange={(e) => update({ to: e.target.value || null })}
        className="w-40"
        aria-label="إلى تاريخ"
      />
    </div>
  );
}

export function SortableHeader({ column, label }: { column: string; label: string }) {
  const searchParams = useSearchParams();
  const update = useUpdateParams();
  const activeSort = searchParams.get("sort");
  const dir = searchParams.get("dir") === "asc" ? "asc" : "desc";
  const isActive = activeSort === column;

  function toggle() {
    if (!isActive) update({ sort: column, dir: "desc" }, false);
    else if (dir === "desc") update({ sort: column, dir: "asc" }, false);
    else update({ sort: null, dir: null }, false);
  }

  const Icon = !isActive ? ArrowUpDown : dir === "asc" ? ArrowUp : ArrowDown;

  return (
    <button
      type="button"
      onClick={toggle}
      className="inline-flex items-center gap-1 font-medium hover:text-foreground"
    >
      {label}
      <Icon className="size-3.5" />
    </button>
  );
}

export function Pagination({ page, pageSize, total }: { page: number; pageSize: number; total: number }) {
  const update = useUpdateParams();
  const totalPages = Math.max(1, Math.ceil(total / pageSize));
  const from = total === 0 ? 0 : (page - 1) * pageSize + 1;
  const to = Math.min(page * pageSize, total);

  return (
    <div className="flex items-center justify-between gap-4 px-1 py-2 text-sm text-muted-foreground">
      <span>
        {from}–{to} من {total}
      </span>
      <div className="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          disabled={page <= 1}
          onClick={() => update({ page: String(page - 1) }, false)}
        >
          السابق
        </Button>
        <span className="text-foreground">
          {page} / {totalPages}
        </span>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= totalPages}
          onClick={() => update({ page: String(page + 1) }, false)}
        >
          التالي
        </Button>
      </div>
    </div>
  );
}
