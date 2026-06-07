import { requireAdmin } from "@/lib/auth";
import { getPendingReportsCount } from "@/lib/data/stats";
import { Sidebar } from "@/components/layout/sidebar";
import { Topbar } from "@/components/layout/topbar";

export const dynamic = "force-dynamic";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await requireAdmin();
  const reportsCount = await getPendingReportsCount();

  return (
    <div className="min-h-screen bg-background">
      <Sidebar
        email={session.email}
        role={session.admin.role}
        reportsCount={reportsCount}
      />
      <div className="pr-60">
        <Topbar email={session.email} reportsCount={reportsCount} />
        <main className="p-6">{children}</main>
      </div>
    </div>
  );
}
