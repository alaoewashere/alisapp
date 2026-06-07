"use client";

import * as React from "react";
import Link from "next/link";
import { ChevronDown, Loader2 } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ReportStatusBadge } from "@/components/ui/status-badge";
import {
  DeleteListingFromReportButton,
  DismissReportButton,
  ResolveReportButton,
  SuspendSellerFromReportButton,
  WarnSellerButton,
} from "@/app/dashboard/reports/report-actions";
import { bulkReportAction } from "@/app/actions/reports";
import { formatDateTime } from "@/lib/utils/format-date";
import { cn } from "@/lib/utils/cn";
import type { ReportWithRelations } from "@/lib/data/types";

function Checkbox(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input type="checkbox" className="size-4 cursor-pointer rounded border-input" {...props} />;
}

export function ReportsTable({ data }: { data: ReportWithRelations[] }) {
  const [selected, setSelected] = React.useState<Set<string>>(new Set());
  const [expanded, setExpanded] = React.useState<Set<string>>(new Set());
  const [pending, start] = React.useTransition();

  function toggleSelect(id: string) {
    setSelected((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  }

  function toggleAll() {
    setSelected((prev) => (prev.size === data.length ? new Set() : new Set(data.map((r) => r.id))));
  }

  function toggleExpand(id: string) {
    setExpanded((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  }

  function runBulk(op: "resolve" | "dismiss") {
    start(async () => {
      const fd = new FormData();
      fd.set("ids", [...selected].join(","));
      fd.set("op", op);
      await bulkReportAction(fd);
      setSelected(new Set());
    });
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        {selected.size > 0 ? (
          <>
            <span className="text-sm text-muted-foreground">{selected.size} محدد</span>
            <Button size="sm" variant="outline" disabled={pending} onClick={() => runBulk("resolve")}>
              {pending && <Loader2 className="size-4 animate-spin" />} وضع كمحلول
            </Button>
            <Button size="sm" variant="ghost" disabled={pending} onClick={() => runBulk("dismiss")}>
              تجاهل
            </Button>
          </>
        ) : (
          <span className="text-sm text-muted-foreground">حدد بلاغات لتنفيذ إجراءات جماعية</span>
        )}
      </div>

      <div className="rounded-lg border border-border bg-card">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-10">
                <Checkbox checked={selected.size === data.length && data.length > 0} onChange={toggleAll} />
              </TableHead>
              <TableHead>الإعلان</TableHead>
              <TableHead>السبب</TableHead>
              <TableHead>المُبلِّغ</TableHead>
              <TableHead>التاريخ</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead className="w-10" />
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.map((report) => {
              const isOpen = expanded.has(report.id);
              return (
                <React.Fragment key={report.id}>
                  <TableRow>
                    <TableCell>
                      <Checkbox checked={selected.has(report.id)} onChange={() => toggleSelect(report.id)} />
                    </TableCell>
                    <TableCell className="max-w-[220px]">
                      {report.listing ? (
                        <Link
                          href={`/dashboard/listings/${report.listing.id}`}
                          className="line-clamp-1 font-medium hover:text-primary"
                        >
                          {report.listing.title}
                        </Link>
                      ) : (
                        <span className="text-muted-foreground">إعلان محذوف</span>
                      )}
                    </TableCell>
                    <TableCell className="max-w-[260px]">
                      <span className="line-clamp-1">{report.reason}</span>
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {report.reporter?.full_name || report.reporter?.display_name || "—"}
                    </TableCell>
                    <TableCell className="text-muted-foreground">{formatDateTime(report.created_at)}</TableCell>
                    <TableCell>
                      <ReportStatusBadge status={report.status} />
                    </TableCell>
                    <TableCell>
                      <button
                        type="button"
                        onClick={() => toggleExpand(report.id)}
                        className="flex size-8 items-center justify-center rounded-md hover:bg-muted"
                        aria-label="تفاصيل"
                      >
                        <ChevronDown className={cn("size-4 transition-transform", isOpen && "rotate-180")} />
                      </button>
                    </TableCell>
                  </TableRow>
                  {isOpen && (
                    <TableRow className="bg-muted/30 hover:bg-muted/30">
                      <TableCell colSpan={7}>
                        <div className="space-y-3 p-2">
                          <div>
                            <p className="text-xs text-muted-foreground">نص البلاغ كاملاً</p>
                            <p className="text-sm">{report.reason}</p>
                          </div>
                          <div className="flex flex-wrap items-center gap-2">
                            {report.status === "pending" && <ResolveReportButton reportId={report.id} />}
                            {report.listing && (
                              <DeleteListingFromReportButton reportId={report.id} listingId={report.listing.id} />
                            )}
                            {report.listing?.user_id && (
                              <WarnSellerButton listingId={report.listing.id} sellerId={report.listing.user_id} />
                            )}
                            {report.listing?.user_id && (
                              <SuspendSellerFromReportButton reportId={report.id} sellerId={report.listing.user_id} />
                            )}
                            {report.status === "pending" && <DismissReportButton reportId={report.id} />}
                          </div>
                        </div>
                      </TableCell>
                    </TableRow>
                  )}
                </React.Fragment>
              );
            })}
            {data.length === 0 && (
              <TableRow>
                <TableCell colSpan={7} className="py-10 text-center text-muted-foreground">
                  لا توجد بلاغات مطابقة
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
