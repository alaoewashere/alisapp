"use client";

import * as React from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Bell, Search } from "lucide-react";

import { Input } from "@/components/ui/input";
import { titleForPath } from "@/lib/constants/nav";

interface TopbarProps {
  email: string;
  reportsCount: number;
}

export function Topbar({ email, reportsCount }: TopbarProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [query, setQuery] = React.useState("");
  const title = titleForPath(pathname);
  const initial = email.charAt(0).toUpperCase();

  function onSearch(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const trimmed = query.trim();
    if (trimmed) router.push(`/dashboard/listings?q=${encodeURIComponent(trimmed)}`);
  }

  return (
    <header className="sticky top-0 z-20 flex h-16 items-center justify-between gap-4 border-b border-border bg-card/80 px-6 backdrop-blur">
      <h1 className="text-lg font-semibold text-foreground">{title}</h1>

      <div className="flex items-center gap-3">
        <form onSubmit={onSearch} className="relative hidden md:block">
          <Search className="pointer-events-none absolute right-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="بحث في الإعلانات..."
            className="w-64 pr-9"
          />
        </form>

        <Link
          href="/dashboard/reports"
          className="relative flex size-10 items-center justify-center rounded-lg text-muted-foreground hover:bg-muted hover:text-foreground"
          aria-label="البلاغات"
        >
          <Bell className="size-5" />
          {reportsCount > 0 && (
            <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold text-white">
              {reportsCount}
            </span>
          )}
        </Link>

        <div className="flex items-center gap-2">
          <div className="flex size-9 items-center justify-center rounded-full bg-primary text-sm font-bold text-primary-foreground">
            {initial}
          </div>
        </div>
      </div>
    </header>
  );
}
