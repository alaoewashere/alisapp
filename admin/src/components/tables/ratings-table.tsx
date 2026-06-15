"use client";

import { Trash2 } from "lucide-react";

import { hideRating } from "@/app/actions/ratings";
import { ActionDialog } from "@/components/ui/action-dialog";
import { SubmitButton } from "@/components/ui/submit-button";

export type AdminRatingRow = {
  id: string;
  stars: number;
  reviewText: string | null;
  createdAtLabel: string;
  reviewerName: string;
  reviewedName: string;
  listingTitle: string;
  listingRef: string | null;
};

function Stars({ value }: { value: number }) {
  return (
    <span className="text-amber-500" aria-label={`${value} نجوم`}>
      {"★".repeat(value)}
      {"☆".repeat(5 - value)}
    </span>
  );
}

export function RatingsTable({ rows }: { rows: AdminRatingRow[] }) {
  if (rows.length === 0) {
    return (
      <p className="rounded-lg border border-border bg-card p-8 text-center text-muted-foreground">
        لا توجد تقييمات
      </p>
    );
  }

  return (
    <div className="overflow-hidden rounded-lg border border-border bg-card">
      <table className="w-full text-sm">
        <thead className="border-b border-border bg-muted/40 text-muted-foreground">
          <tr>
            <th className="px-4 py-3 text-right font-medium">المُقيِّم</th>
            <th className="px-4 py-3 text-right font-medium">صاحب الاعلان</th>
            <th className="px-4 py-3 text-right font-medium">النجوم</th>
            <th className="px-4 py-3 text-right font-medium">التعليق</th>
            <th className="px-4 py-3 text-right font-medium">التاريخ</th>
            <th className="px-4 py-3 text-right font-medium">الإعلان</th>
            <th className="px-4 py-3 text-right font-medium">إجراء</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id} className="border-b border-border/60 last:border-0">
              <td className="px-4 py-3">{row.reviewerName}</td>
              <td className="px-4 py-3">{row.reviewedName}</td>
              <td className="px-4 py-3">
                <Stars value={row.stars} />
              </td>
              <td className="max-w-xs truncate px-4 py-3 text-muted-foreground">
                {row.reviewText?.trim() || "—"}
              </td>
              <td className="px-4 py-3 whitespace-nowrap">{row.createdAtLabel}</td>
              <td className="px-4 py-3">
                {row.listingRef ? `#${row.listingRef} — ` : ""}
                {row.listingTitle}
              </td>
              <td className="px-4 py-3">
                <ActionDialog
                  title="إخفاء التقييم"
                  description="سيتم إخفاء هذا التقييم ولن يُحسب في متوسط التقييم."
                  trigger={
                    <button
                      type="button"
                      className="inline-flex items-center gap-1 rounded-md px-2 py-1 text-destructive hover:bg-destructive/10"
                      title="إخفاء"
                    >
                      <Trash2 className="size-4" />
                    </button>
                  }
                >
                  <form action={hideRating}>
                    <input type="hidden" name="id" value={row.id} />
                    <SubmitButton variant="destructive">إخفاء</SubmitButton>
                  </form>
                </ActionDialog>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
