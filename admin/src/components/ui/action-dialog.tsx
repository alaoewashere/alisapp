"use client";

import * as React from "react";
import { Loader2 } from "lucide-react";

import { Button, type ButtonProps } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Modal } from "@/components/ui/modal";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import type { ActionResult } from "@/lib/actions/types";

export interface DialogField {
  name: string;
  label: string;
  type?: "text" | "number" | "textarea" | "select";
  placeholder?: string;
  required?: boolean;
  defaultValue?: string;
  options?: { value: string; label: string }[];
}

interface ActionDialogProps {
  action: (formData: FormData) => Promise<ActionResult | void>;
  title: string;
  description?: string;
  confirmLabel?: string;
  triggerLabel: React.ReactNode;
  triggerVariant?: ButtonProps["variant"];
  triggerSize?: ButtonProps["size"];
  triggerClassName?: string;
  confirmVariant?: ButtonProps["variant"];
  hidden?: Record<string, string>;
  fields?: DialogField[];
}

/**
 * Reusable confirmation dialog backed by a Server Action. Renders a trigger
 * button; on confirm it submits collected fields + hidden values and closes on
 * success, surfacing any returned error inline.
 */
export function ActionDialog({
  action,
  title,
  description,
  confirmLabel = "تأكيد",
  triggerLabel,
  triggerVariant = "default",
  triggerSize = "default",
  triggerClassName,
  confirmVariant = "default",
  hidden,
  fields,
}: ActionDialogProps) {
  const [open, setOpen] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);
  const [pending, startTransition] = React.useTransition();

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    setError(null);
    startTransition(async () => {
      const result = await action(formData);
      if (result && result.ok === false) {
        setError(result.error);
      } else {
        setOpen(false);
      }
    });
  }

  return (
    <>
      <Button
        type="button"
        variant={triggerVariant}
        size={triggerSize}
        className={triggerClassName}
        onClick={() => {
          setError(null);
          setOpen(true);
        }}
      >
        {triggerLabel}
      </Button>

      <Modal open={open} onClose={() => setOpen(false)} title={title} description={description}>
        <form onSubmit={handleSubmit} className="space-y-4">
          {hidden &&
            Object.entries(hidden).map(([name, value]) => (
              <input key={name} type="hidden" name={name} value={value} />
            ))}

          {fields?.map((field) => (
            <div key={field.name} className="space-y-1.5">
              <Label htmlFor={field.name}>{field.label}</Label>
              {field.type === "textarea" ? (
                <Textarea
                  id={field.name}
                  name={field.name}
                  placeholder={field.placeholder}
                  required={field.required}
                  defaultValue={field.defaultValue}
                />
              ) : field.type === "select" ? (
                <Select
                  id={field.name}
                  name={field.name}
                  required={field.required}
                  defaultValue={field.defaultValue}
                >
                  {field.options?.map((opt) => (
                    <option key={opt.value} value={opt.value}>
                      {opt.label}
                    </option>
                  ))}
                </Select>
              ) : (
                <Input
                  id={field.name}
                  name={field.name}
                  type={field.type ?? "text"}
                  placeholder={field.placeholder}
                  required={field.required}
                  defaultValue={field.defaultValue}
                />
              )}
            </div>
          ))}

          {error && <p className="text-sm text-destructive">{error}</p>}

          <div className="flex justify-start gap-2 pt-2">
            <Button type="submit" variant={confirmVariant} disabled={pending}>
              {pending && <Loader2 className="size-4 animate-spin" />}
              {confirmLabel}
            </Button>
            <Button type="button" variant="outline" onClick={() => setOpen(false)}>
              إلغاء
            </Button>
          </div>
        </form>
      </Modal>
    </>
  );
}
