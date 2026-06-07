import { CategoriesManager, type CategoryNode } from "@/app/dashboard/categories/categories-manager";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import type { CategoryRow } from "@/lib/types/database.types";

export const dynamic = "force-dynamic";

export default async function CategoriesPage() {
  await requireAdmin();
  const supabase = createAdminClient();

  const [categoriesRes, listingRows] = await Promise.all([
    supabase
      .from("categories")
      .select("id, name_ar, icon, parent_id, display_order")
      .order("display_order"),
    supabase.from("listings").select("category_id").neq("availability", "deleted"),
  ]);

  const categories = (categoriesRes.data ?? []) as Pick<
    CategoryRow,
    "id" | "name_ar" | "icon" | "parent_id" | "display_order"
  >[];

  const listingCounts = new Map<number, number>();
  for (const row of (listingRows.data ?? []) as { category_id: number }[]) {
    listingCounts.set(row.category_id, (listingCounts.get(row.category_id) ?? 0) + 1);
  }

  const childCounts = new Map<number, number>();
  for (const c of categories) {
    if (c.parent_id != null) {
      childCounts.set(c.parent_id, (childCounts.get(c.parent_id) ?? 0) + 1);
    }
  }

  const nodes: CategoryNode[] = categories.map((c) => ({
    id: c.id,
    name_ar: c.name_ar,
    icon: c.icon,
    parent_id: c.parent_id,
    display_order: c.display_order,
    listingsCount: listingCounts.get(c.id) ?? 0,
    childCount: childCounts.get(c.id) ?? 0,
  }));

  return (
    <div className="space-y-4">
      <p className="text-sm text-muted-foreground">
        اسحب الفئات لإعادة الترتيب. اضغط على فئة رئيسية لعرض فئاتها الفرعية.
      </p>
      <CategoriesManager categories={nodes} />
    </div>
  );
}
