import { ImageOff } from "lucide-react";

import { cn } from "@/lib/utils/cn";

interface ThumbnailProps {
  src: string | null;
  alt: string;
  className?: string;
}

export function Thumbnail({ src, alt, className }: ThumbnailProps) {
  if (!src) {
    return (
      <div
        className={cn(
          "flex items-center justify-center rounded-md bg-muted text-muted-foreground",
          className,
        )}
      >
        <ImageOff className="size-4" />
      </div>
    );
  }
  return (
    <img
      src={src}
      alt={alt}
      className={cn("rounded-md object-cover", className)}
      loading="lazy"
    />
  );
}
