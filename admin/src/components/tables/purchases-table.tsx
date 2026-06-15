"use client";

import Link from "next/link";
import { Download } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { SortableHeader } from "@/components/tables/controls";
import { formatDate } from "@/lib/utils/format-date";
import { formatIqd } from "@/lib/utils/format-iqd";
import { exportToCsv } from "@/lib/utils/csv";
import type { ListingPurchaseRow } from "@/lib/types/database.types";

function packageLabel(type: ListingPurchaseRow["package_type"]): string {
  return type === "premium" ? "مميز" : "برو";
}

export function PurchasesTable({ data }: { data: ListingPurchaseRow[] }) {
  function handleExport() {
    exportToCsv(
      `purchases-${new Date().toISOString().slice(0, 10)}.csv`,
      data.map((row) => ({
        user_name: row.user_name,
        user_phone: row.user_phone ?? "",
        user_email: row.user_email ?? "",
        package_type: row.package_type,
        price: row.price,
        listing_id: row.listing_id,
        purchased_at: row.purchased_at,
      })),
    );
  }

  return (
    <div className="space-y-3">
      <div className="flex justify-end">
        <Button size="sm" variant="outline" onClick={handleExport}>
          <Download className="size-4" /> تصدير CSV
        </Button>
      </div>
      <div className="rounded-lg border border-border bg-card">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>المستخدم</TableHead>
              <TableHead>الهاتف</TableHead>
              <TableHead>البريد</TableHead>
              <TableHead>الباقة</TableHead>
              <TableHead>السعر</TableHead>
              <TableHead>معرّف الإعلان</TableHead>
              <TableHead>
                <SortableHeader column="purchased_at" label="تاريخ الشراء" />
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} className="py-10 text-center text-muted-foreground">
                  لا توجد مشتريات بعد
                </TableCell>
              </TableRow>
            ) : (
              data.map((row) => (
                <TableRow key={row.id}>
                  <TableCell className="font-medium">{row.user_name || "—"}</TableCell>
                  <TableCell dir="ltr">{row.user_phone ?? "—"}</TableCell>
                  <TableCell dir="ltr">{row.user_email ?? "—"}</TableCell>
                  <TableCell>
                    <Badge variant={row.package_type === "premium" ? "default" : "secondary"}>
                      {packageLabel(row.package_type)}
                    </Badge>
                  </TableCell>
                  <TableCell>{formatIqd(Number(row.price))}</TableCell>
                  <TableCell>
                    <Link
                      href={`/dashboard/listings/${row.listing_id}`}
                      className="font-mono text-xs text-primary hover:underline"
                      dir="ltr"
                    >
                      {row.listing_id.slice(0, 8)}…
                    </Link>
                  </TableCell>
                  <TableCell>{formatDate(row.purchased_at)}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
