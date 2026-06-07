"use client";

import * as React from "react";
import { MoreHorizontal } from "lucide-react";

import { cn } from "@/lib/utils/cn";

const DropdownContext = React.createContext<{ close: () => void }>({ close: () => {} });

export function Dropdown({ children, align = "end" }: { children: React.ReactNode; align?: "start" | "end" }) {
  const [open, setOpen] = React.useState(false);
  const ref = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    if (!open) return;
    const onClick = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, [open]);

  return (
    <div className="relative" ref={ref}>
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="flex size-8 items-center justify-center rounded-md text-muted-foreground hover:bg-muted"
        aria-label="إجراءات"
      >
        <MoreHorizontal className="size-4" />
      </button>
      {open && (
        <div
          className={cn(
            "absolute z-30 mt-1 min-w-40 rounded-md border border-border bg-card p-1 shadow-md",
            align === "end" ? "left-0" : "right-0",
          )}
        >
          <DropdownContext.Provider value={{ close: () => setOpen(false) }}>
            {children}
          </DropdownContext.Provider>
        </div>
      )}
    </div>
  );
}

export function DropdownItem({
  children,
  onSelect,
  destructive,
}: {
  children: React.ReactNode;
  onSelect?: () => void;
  destructive?: boolean;
}) {
  const { close } = React.useContext(DropdownContext);
  return (
    <button
      type="button"
      onClick={() => {
        onSelect?.();
        close();
      }}
      className={cn(
        "flex w-full items-center gap-2 rounded px-2 py-1.5 text-right text-sm hover:bg-muted",
        destructive ? "text-destructive" : "text-foreground",
      )}
    >
      {children}
    </button>
  );
}
