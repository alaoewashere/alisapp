import {
  BarChart3,
  FileText,
  Flag,
  FolderTree,
  LayoutDashboard,
  Settings,
  Users,
  type LucideIcon,
} from "lucide-react";

export interface NavItem {
  href: string;
  label: string;
  icon: LucideIcon;
  /** When true, the reports unread badge renders on this item. */
  badge?: "reports";
}

export const navItems: NavItem[] = [
  { href: "/dashboard", label: "نظرة عامة", icon: LayoutDashboard },
  { href: "/dashboard/listings", label: "الإعلانات", icon: FileText },
  { href: "/dashboard/users", label: "المستخدمون", icon: Users },
  { href: "/dashboard/reports", label: "البلاغات", icon: Flag, badge: "reports" },
  { href: "/dashboard/categories", label: "الفئات", icon: FolderTree },
  { href: "/dashboard/analytics", label: "التحليلات", icon: BarChart3 },
  { href: "/dashboard/settings", label: "الإعدادات", icon: Settings },
];

/** Resolves the page title for a given pathname (longest-prefix match). */
export function titleForPath(pathname: string): string {
  const match = [...navItems]
    .sort((a, b) => b.href.length - a.href.length)
    .find((item) => pathname === item.href || pathname.startsWith(item.href + "/"));
  return match?.label ?? "لوحة التحكم";
}
