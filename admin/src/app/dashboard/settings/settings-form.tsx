"use client";

import * as React from "react";
import { Check, Loader2 } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { saveSettings } from "@/app/actions/settings";

export interface SettingField {
  key: string;
  label: string;
  type?: "text" | "number" | "email" | "textarea";
  placeholder?: string;
}

interface SettingsFormProps {
  title: string;
  description?: string;
  fields: SettingField[];
  values: Record<string, string>;
}

export function SettingsForm({ title, description, fields, values }: SettingsFormProps) {
  const [pending, start] = React.useTransition();
  const [status, setStatus] = React.useState<"idle" | "saved" | "error">("idle");
  const [error, setError] = React.useState<string | null>(null);

  function onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    setStatus("idle");
    start(async () => {
      const res = await saveSettings(formData);
      if (res && res.ok === false) {
        setStatus("error");
        setError(res.error);
      } else {
        setStatus("saved");
        setTimeout(() => setStatus("idle"), 2500);
      }
    });
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        {description && <p className="text-sm text-muted-foreground">{description}</p>}
      </CardHeader>
      <CardContent>
        <form onSubmit={onSubmit} className="space-y-4">
          {fields.map((field) => (
            <div key={field.key} className="space-y-1.5">
              <Label htmlFor={field.key}>{field.label}</Label>
              {field.type === "textarea" ? (
                <Textarea
                  id={field.key}
                  name={`setting:${field.key}`}
                  defaultValue={values[field.key] ?? ""}
                  placeholder={field.placeholder}
                />
              ) : (
                <Input
                  id={field.key}
                  name={`setting:${field.key}`}
                  type={field.type ?? "text"}
                  defaultValue={values[field.key] ?? ""}
                  placeholder={field.placeholder}
                />
              )}
            </div>
          ))}

          <div className="flex items-center gap-3">
            <Button type="submit" disabled={pending}>
              {pending && <Loader2 className="size-4 animate-spin" />}
              حفظ
            </Button>
            {status === "saved" && (
              <span className="flex items-center gap-1 text-sm text-emerald-600">
                <Check className="size-4" /> تم الحفظ
              </span>
            )}
            {status === "error" && <span className="text-sm text-destructive">{error}</span>}
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
