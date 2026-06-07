"use client";

import * as React from "react";
import { X } from "lucide-react";

import { cn } from "@/lib/utils/cn";

interface ModalProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  description?: string;
  children: React.ReactNode;
  className?: string;
}

export function Modal({ open, onClose, title, description, children, className }: ModalProps) {
  React.useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
    >
      <div
        className={cn(
          "w-full max-w-md rounded-lg border border-border bg-card p-6 shadow-lg",
          className,
        )}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mb-4 flex items-start justify-between gap-4">
          <div className="space-y-1">
            {title && <h2 className="text-lg font-semibold text-foreground">{title}</h2>}
            {description && (
              <p className="text-sm text-muted-foreground">{description}</p>
            )}
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1 text-muted-foreground hover:bg-muted"
          >
            <X className="size-4" />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}
