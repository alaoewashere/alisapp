"use client";

import Link from "next/link";
import { BadgeCheck, Download } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Dropdown, DropdownItem } from "@/components/ui/dropdown";
import { UserStatusBadge } from "@/components/ui/status-badge";
import { SortableHeader } from "@/components/tables/controls";
import {
  DeleteUserButton,
  SuspendUserButton,
  UnsuspendUserButton,
  VerifyButton,
} from "@/app/dashboard/users/user-actions";
import { governorateNameAr } from "@/lib/constants/governorates";
import { formatDate } from "@/lib/utils/format-date";
import { exportToCsv } from "@/lib/utils/csv";
import type { ProfileRow } from "@/lib/types/database.types";

export interface UserRowData extends ProfileRow {
  listingsCount: number;
}

export function UsersTable({ data }: { data: UserRowData[] }) {
  function handleExport() {
    exportToCsv(
      `users-${new Date().toISOString().slice(0, 10)}.csv`,
      data.map((u) => ({
        id: u.id,
        name: u.full_name || u.display_name || "",
        phone: u.phone ?? "",
        governorate: governorateNameAr(u.governorate),
        listings: u.listingsCount,
        verified: u.is_verified ? "yes" : "no",
        suspended: u.is_suspended ? "yes" : "no",
        created_at: u.created_at,
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
              <TableHead>المحافظة</TableHead>
              <TableHead>الإعلانات</TableHead>
              <TableHead>
                <SortableHeader column="created_at" label="تاريخ الانضمام" />
              </TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.map((user) => {
              const name = user.full_name || user.display_name || "—";
              return (
                <TableRow key={user.id}>
                  <TableCell>
                    <Link
                      href={`/dashboard/users/${user.id}`}
                      className="flex items-center gap-3 hover:text-primary"
                    >
                      <div className="flex size-9 items-center justify-center rounded-full bg-muted font-bold">
                        {name.charAt(0)}
                      </div>
                      <span className="flex items-center gap-1 font-medium">
                        {name}
                        {user.is_verified && <BadgeCheck className="size-4 text-primary" />}
                      </span>
                    </Link>
                  </TableCell>
                  <TableCell dir="ltr" className="text-muted-foreground">
                    {user.phone ?? "—"}
                  </TableCell>
                  <TableCell>{governorateNameAr(user.governorate)}</TableCell>
                  <TableCell>{user.listingsCount}</TableCell>
                  <TableCell className="text-muted-foreground">{formatDate(user.created_at)}</TableCell>
                  <TableCell>
                    <UserStatusBadge suspended={user.is_suspended} />
                  </TableCell>
                  <TableCell>
                    <Dropdown>
                      <DropdownItem>
                        <Link href={`/dashboard/users/${user.id}`} className="flex w-full items-center gap-2">
                          عرض الملف
                        </Link>
                      </DropdownItem>
                      <div className="grid gap-1 p-1">
                        <VerifyButton id={user.id} verified={user.is_verified} />
                        {user.is_suspended ? (
                          <UnsuspendUserButton id={user.id} />
                        ) : (
                          <SuspendUserButton id={user.id} />
                        )}
                        <DeleteUserButton id={user.id} />
                      </div>
                    </Dropdown>
                  </TableCell>
                </TableRow>
              );
            })}
            {data.length === 0 && (
              <TableRow>
                <TableCell colSpan={7} className="py-10 text-center text-muted-foreground">
                  لا يوجد مستخدمون مطابقون
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
