"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LogOut, Store } from "lucide-react";

import { signOutAction } from "@/app/actions/auth";
import { navItems } from "@/lib/constants/nav";
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
      <div className="flex items-center gap-3 border-b border-border px-5 py-4">
        <div className="flex size-9 items-center justify-center rounded-lg bg-primary text-primary-foreground">
          <Store className="size-5" />
        </div>
        <div className="leading-tight">
          <p className="font-bold text-foreground">سوق العراق</p>
          <p className="text-xs text-muted-foreground">لوحة التحكم</p>
        </div>
      </div>

      <nav className="flex-1 space-y-1 overflow-y-auto p-3">
        {navItems.map((item) => {
          const isActive =
            pathname === item.href || pathname.startsWith(item.href + "/");
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium transition-colors",
                isActive
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground",
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
                    isActive ? "bg-white text-primary" : "bg-red-500 text-white",
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
            className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-red-600 transition-colors hover:bg-red-50"
          >
            <LogOut className="size-5" />
            تسجيل الخروج
          </button>
        </form>
      </div>
    </aside>
  );
}
