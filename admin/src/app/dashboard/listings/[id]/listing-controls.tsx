"use client";

import * as React from "react";
import { Loader2 } from "lucide-react";

import { Select } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { setListingFlag, setListingStatus } from "@/app/actions/listings";
import type { ListingStatus } from "@/lib/types/database.types";

export function StatusControl({ id, status }: { id: string; status: ListingStatus }) {
  const [value, setValue] = React.useState<ListingStatus>(status);
  const [pending, start] = React.useTransition();

  function onChange(next: ListingStatus) {
    setValue(next);
    start(async () => {
      const fd = new FormData();
      fd.set("id", id);
      fd.set("status", next);
      await setListingStatus(fd);
    });
  }

  return (
    <div className="flex items-center gap-2">
      <Select
        value={value}
        onChange={(e) => onChange(e.target.value as ListingStatus)}
        disabled={pending}
        className="w-40"
      >
        <option value="approved">مقبول</option>
        <option value="pending">قيد المراجعة</option>
        <option value="rejected">مرفوض</option>
      </Select>
      {pending && <Loader2 className="size-4 animate-spin text-muted-foreground" />}
    </div>
  );
}

export function FlagSwitch({
  id,
  flag,
  initial,
  label,
}: {
  id: string;
  flag: "is_featured" | "is_boosted";
  initial: boolean;
  label: string;
}) {
  const [checked, setChecked] = React.useState(initial);
  const [pending, start] = React.useTransition();

  function toggle(next: boolean) {
    setChecked(next);
    start(async () => {
      const fd = new FormData();
      fd.set("id", id);
      fd.set("flag", flag);
      fd.set("value", String(next));
      await setListingFlag(fd);
    });
  }

  return (
    <div className="flex items-center justify-between">
      <span className="text-sm font-medium">{label}</span>
      <div className="flex items-center gap-2">
        {pending && <Loader2 className="size-4 animate-spin text-muted-foreground" />}
        <Switch checked={checked} onCheckedChange={toggle} disabled={pending} />
      </div>
    </div>
  );
}
