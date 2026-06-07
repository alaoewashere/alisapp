"use client";

import * as React from "react";
import Link from "next/link";
import {
  flexRender,
  getCoreRowModel,
  useReactTable,
  type ColumnDef,
  type RowSelectionState,
} from "@tanstack/react-table";
import { Download, Eye, Loader2, Star, Trash2 } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Thumbnail } from "@/components/ui/thumbnail";
import { Dropdown, DropdownItem } from "@/components/ui/dropdown";
import { ActionDialog } from "@/components/ui/action-dialog";
import { ListingStatusBadge, AvailabilityBadge } from "@/components/ui/status-badge";
import { SortableHeader } from "@/components/tables/controls";
import { bulkListingAction, deleteListing, setListingFlag } from "@/app/actions/listings";
import { governorateNameAr } from "@/lib/constants/governorates";
import { formatIqd } from "@/lib/utils/format-iqd";
import { formatDate } from "@/lib/utils/format-date";
import { coverImage } from "@/lib/utils/image-url";
import { exportToCsv } from "@/lib/utils/csv";
import type { ListingCard } from "@/lib/data/types";

function Checkbox(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input type="checkbox" className="size-4 cursor-pointer rounded border-input" {...props} />;
}

function FeatureToggleItem({ listing }: { listing: ListingCard }) {
  const [pending, start] = React.useTransition();
  return (
    <DropdownItem
      onSelect={() =>
        start(async () => {
          const fd = new FormData();
          fd.set("id", listing.id);
          fd.set("flag", "is_featured");
          fd.set("value", String(!listing.is_featured));
          await setListingFlag(fd);
        })
      }
    >
      {pending ? <Loader2 className="size-4 animate-spin" /> : <Star className="size-4" />}
      {listing.is_featured ? "إلغاء التمييز" : "تمييز"}
    </DropdownItem>
  );
}

export function ListingsTable({ data }: { data: ListingCard[] }) {
  const [rowSelection, setRowSelection] = React.useState<RowSelectionState>({});
  const [bulkPending, startBulk] = React.useTransition();

  const columns = React.useMemo<ColumnDef<ListingCard>[]>(
    () => [
      {
        id: "select",
        header: ({ table }) => (
          <Checkbox
            checked={table.getIsAllRowsSelected()}
            onChange={table.getToggleAllRowsSelectedHandler()}
          />
        ),
        cell: ({ row }) => (
          <Checkbox checked={row.getIsSelected()} onChange={row.getToggleSelectedHandler()} />
        ),
      },
      {
        id: "title",
        header: () => <SortableHeader column="title" label="الإعلان" />,
        cell: ({ row }) => {
          const l = row.original;
          return (
            <Link
              href={`/dashboard/listings/${l.id}`}
              className="flex items-center gap-3 hover:text-primary"
            >
              <Thumbnail src={coverImage(l.listing_images)} alt={l.title} className="size-10" />
              <span className="line-clamp-1 max-w-[220px] font-medium">{l.title}</span>
            </Link>
          );
        },
      },
      {
        id: "seller",
        header: "البائع",
        cell: ({ row }) => {
          const seller = row.original.seller;
          if (!seller) return <span className="text-muted-foreground">—</span>;
          return (
            <Link href={`/dashboard/users/${seller.id}`} className="hover:text-primary">
              {seller.full_name || seller.display_name || "—"}
            </Link>
          );
        },
      },
      {
        id: "category",
        header: "الفئة",
        cell: ({ row }) => row.original.categories?.name_ar ?? "—",
      },
      {
        id: "price",
        header: () => <SortableHeader column="price_iqd" label="السعر" />,
        cell: ({ row }) => formatIqd(row.original.price_iqd),
      },
      {
        id: "governorate",
        header: "المحافظة",
        cell: ({ row }) => governorateNameAr(row.original.governorate),
      },
      {
        id: "status",
        header: "الحالة",
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-1">
            <ListingStatusBadge status={row.original.status} />
            <AvailabilityBadge availability={row.original.availability} />
          </div>
        ),
      },
      {
        id: "views",
        header: () => <SortableHeader column="views_count" label="المشاهدات" />,
        cell: ({ row }) => row.original.views_count,
      },
      {
        id: "created",
        header: () => <SortableHeader column="created_at" label="تاريخ النشر" />,
        cell: ({ row }) => formatDate(row.original.created_at),
      },
      {
        id: "actions",
        header: "",
        cell: ({ row }) => {
          const l = row.original;
          return (
            <Dropdown>
              <DropdownItem>
                <Link href={`/dashboard/listings/${l.id}`} className="flex items-center gap-2">
                  <Eye className="size-4" /> عرض
                </Link>
              </DropdownItem>
              <FeatureToggleItem listing={l} />
              <div className="px-1 pt-1">
                <ActionDialog
                  action={deleteListing}
                  title="حذف الإعلان"
                  description="سيتم نقل الإعلان إلى المحذوفات. يمكن استعادته لاحقًا."
                  confirmLabel="حذف"
                  confirmVariant="destructive"
                  triggerLabel={
                    <>
                      <Trash2 className="size-4" /> حذف
                    </>
                  }
                  triggerVariant="ghost"
                  triggerSize="sm"
                  triggerClassName="w-full justify-start text-destructive"
                  hidden={{ id: l.id }}
                />
              </div>
            </Dropdown>
          );
        },
      },
    ],
    [],
  );

  const table = useReactTable({
    data,
    columns,
    state: { rowSelection },
    enableRowSelection: true,
    onRowSelectionChange: setRowSelection,
    getRowId: (row) => row.id,
    getCoreRowModel: getCoreRowModel(),
    manualPagination: true,
    manualSorting: true,
  });

  const selectedIds = Object.keys(rowSelection);

  function runBulk(op: string) {
    startBulk(async () => {
      const fd = new FormData();
      fd.set("ids", selectedIds.join(","));
      fd.set("op", op);
      await bulkListingAction(fd);
      setRowSelection({});
    });
  }

  function handleExport() {
    exportToCsv(
      `listings-${new Date().toISOString().slice(0, 10)}.csv`,
      data.map((l) => ({
        id: l.id,
        title: l.title,
        seller: l.seller?.full_name || l.seller?.display_name || "",
        category: l.categories?.name_ar ?? "",
        price_iqd: l.price_iqd,
        governorate: governorateNameAr(l.governorate),
        status: l.status,
        availability: l.availability,
        views: l.views_count,
        created_at: l.created_at,
      })),
    );
  }

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          {selectedIds.length > 0 ? (
            <>
              <span className="text-sm text-muted-foreground">
                {selectedIds.length} محدد
              </span>
              <Button size="sm" variant="outline" disabled={bulkPending} onClick={() => runBulk("approve")}>
                قبول
              </Button>
              <Button size="sm" variant="outline" disabled={bulkPending} onClick={() => runBulk("feature")}>
                تمييز
              </Button>
              <Button size="sm" variant="outline" disabled={bulkPending} onClick={() => runBulk("unfeature")}>
                إلغاء التمييز
              </Button>
              <Button size="sm" variant="destructive" disabled={bulkPending} onClick={() => runBulk("delete")}>
                {bulkPending && <Loader2 className="size-4 animate-spin" />}
                حذف
              </Button>
            </>
          ) : (
            <span className="text-sm text-muted-foreground">حدد إعلانات لتنفيذ إجراءات جماعية</span>
          )}
        </div>
        <Button size="sm" variant="outline" onClick={handleExport}>
          <Download className="size-4" /> تصدير CSV
        </Button>
      </div>

      <div className="rounded-lg border border-border bg-card">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.map((row) => (
              <TableRow key={row.id} data-state={row.getIsSelected() ? "selected" : undefined}>
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))}
            {data.length === 0 && (
              <TableRow>
                <TableCell colSpan={columns.length} className="py-10 text-center text-muted-foreground">
                  لا توجد إعلانات مطابقة
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
