import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils/cn";

const badgeVariants = cva(
  "inline-flex items-center rounded-pill border px-2.5 py-0.5 text-xs font-bold transition-colors",
  {
    variants: {
      variant: {
        default: "border-volt/30 bg-volt/15 text-volt",
        secondary: "border-white/10 bg-sold text-white",
        success: "border-volt/40 bg-volt text-canvas shadow-sm",
        warning: "border-white/20 bg-field text-white",
        destructive: "border-destructive/50 bg-destructive text-white",
        muted: "border-white/10 bg-sold text-white/70",
        outline: "border-white/20 bg-field text-white",
      },
    },
    defaultVariants: { variant: "default" },
  },
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return <span className={cn(badgeVariants({ variant }), className)} {...props} />;
}

export { Badge, badgeVariants };
