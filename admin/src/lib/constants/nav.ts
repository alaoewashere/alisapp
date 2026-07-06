import {
  BarChart3,
  Ban,
  FileText,
  Flag,
  FolderTree,
  LayoutDashboard,
  MessageCircle,
  Settings,
  Shield,
  ShieldCheck,
  ShoppingBag,
  Star,
  Users,
  type LucideIcon,
} from "lucide-react";

export interface NavItem {
  href: string;
  label: string;
  icon: LucideIcon;
  /** When set, the matching unread badge renders on this item. */
  badge?: "reports" | "support";
}

export const navItems: NavItem[] = [
  { href: "/dashboard", label: "نظرة عامة", icon: LayoutDashboard },
  { href: "/dashboard/listings", label: "الإعلانات", icon: FileText },
  { href: "/dashboard/purchases", label: "المشتريات", icon: ShoppingBag },
  { href: "/dashboard/users", label: "المستخدمون", icon: Users },
  { href: "/dashboard/verification", label: "التوثيق", icon: ShieldCheck },
  { href: "/dashboard/ratings", label: "التقييمات", icon: Star },
  { href: "/dashboard/reports", label: "البلاغات", icon: Flag, badge: "reports" },
  { href: "/dashboard/support-messages", label: "الدعم", icon: MessageCircle, badge: "support" },
  { href: "/dashboard/categories", label: "الفئات", icon: FolderTree },
  { href: "/dashboard/blocked-words", label: "كلمات محظورة", icon: Ban },
  { href: "/dashboard/moderation", label: "إدارة المخالفات", icon: Shield },
  { href: "/dashboard/analytics", label: "التحليلات", icon: BarChart3 },
  { href: "/dashboard/settings", label: "الإعدادات", icon: Settings },
];

/** Resolves the page title for a given pathname (longest-prefix match). */
export function titleForPath(pathname: string): string {
  const match = [...navItems]
    .sort((a, b) => b.href.length - a.href.length)
    .find((item) => isNavItemActive(pathname, item.href));
  return match?.label ?? "لوحة التحكم";
}

/** True when [pathname] is under [href]. Overview (/dashboard) is exact-only. */
export function isNavItemActive(pathname: string, href: string): boolean {
  if (href === "/dashboard") {
    return pathname === "/dashboard";
  }
  return pathname === href || pathname.startsWith(`${href}/`);
}
