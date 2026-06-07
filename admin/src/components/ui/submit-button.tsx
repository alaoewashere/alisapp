"use client";

import * as React from "react";
import { useFormStatus } from "react-dom";
import { Loader2 } from "lucide-react";

import { Button, type ButtonProps } from "@/components/ui/button";

/** Submit button that reflects the enclosing <form> action's pending state. */
export function SubmitButton({ children, disabled, ...props }: ButtonProps) {
  const { pending } = useFormStatus();
  return (
    <Button type="submit" disabled={pending || disabled} {...props}>
      {pending && <Loader2 className="size-4 animate-spin" />}
      {children}
    </Button>
  );
}
