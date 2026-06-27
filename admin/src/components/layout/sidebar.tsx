"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { LogOut } from "lucide-react";

import { signOutAction } from "@/app/actions/auth";
import { isNavItemActive, navItems } from "@/lib/constants/nav";
import { cn } from "@/lib/utils/cn";

interface SidebarProps {
  email: string;
  role: string;
  reportsCount: number;
}

export function Sidebar({ email, role, reportsCount }: SidebarProps) {
  const pathname = usePathname();

  return (
    <aside className="fixed inset-y-0 right-0 z-30 flex w-60 flex-col border-l border-border bg-card">
      <div className="border-b border-border px-5 py-4">
        <Image
          src="/app_logo.png"
          alt="Souqak"
          width={120}
          height={36}
          className="h-9 w-auto object-contain object-right"
          priority
        />
        <p className="mt-1 text-xs text-muted-foreground">لوحة التحكم</p>
      </div>

      <nav className="flex-1 space-y-1 overflow-y-auto p-3">
        {navItems.map((item) => {
          const isActive = isNavItemActive(pathname, item.href);
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center justify-between rounded-full px-3 py-2.5 text-sm font-bold transition-colors",
                isActive
                  ? "bg-volt text-canvas"
                  : "text-white/60 hover:bg-field hover:text-white",
              )}
            >
              <span className="flex items-center gap-3">
                <Icon className="size-5" />
                {item.label}
              </span>
              {item.badge === "reports" && reportsCount > 0 && (
                <span
                  className={cn(
                    "flex h-5 min-w-5 items-center justify-center rounded-full px-1.5 text-xs font-bold",
                    isActive ? "bg-canvas text-volt" : "bg-destructive text-white",
                  )}
                >
                  {reportsCount}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-border p-3">
        <div className="mb-2 px-2">
          <p className="truncate text-sm font-medium text-foreground" dir="ltr">
            {email}
          </p>
          <p className="text-xs text-muted-foreground">
            {role === "super_admin" ? "مدير أعلى" : "مدير"}
          </p>
        </div>
        <form action={signOutAction}>
          <button
            type="submit"
            className="flex w-full items-center gap-3 rounded-full px-3 py-2.5 text-sm font-medium text-destructive transition-colors hover:bg-destructive/10"
          >
            <LogOut className="size-5" />
            تسجيل الخروج
          </button>
        </form>
      </div>
    </aside>
  );
}
