"use client";

import * as React from "react";
import { Check, GripVertical, Loader2, Pencil, Plus, Trash2, X } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
  createCategory,
  deleteCategory,
  reorderCategories,
  updateCategory,
} from "@/app/actions/categories";
import { cn } from "@/lib/utils/cn";

export interface CategoryNode {
  id: number;
  name_ar: string;
  icon: string;
  parent_id: number | null;
  display_order: number;
  listingsCount: number;
  childCount: number;
}

export function CategoriesManager({ categories }: { categories: CategoryNode[] }) {
  const parents = React.useMemo(
    () => categories.filter((c) => c.parent_id == null).sort(byOrder),
    [categories],
  );
  const [selectedParent, setSelectedParent] = React.useState<number | null>(parents[0]?.id ?? null);

  const children = React.useMemo(
    () => categories.filter((c) => c.parent_id === selectedParent).sort(byOrder),
    [categories, selectedParent],
  );

  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <CategoryPanel
        title="الفئات الرئيسية"
        items={parents}
        parentId={null}
        isParentPanel
        selectedId={selectedParent}
        onSelect={setSelectedParent}
        showChildCount
      />
      <CategoryPanel
        title={selectedParent ? "الفئات الفرعية" : "اختر فئة رئيسية"}
        items={children}
        parentId={selectedParent}
        emptyHint={selectedParent ? "لا توجد فئات فرعية" : "اختر فئة رئيسية من اليمين"}
      />
    </div>
  );
}

function byOrder(a: CategoryNode, b: CategoryNode) {
  return a.display_order - b.display_order || a.id - b.id;
}

interface PanelProps {
  title: string;
  items: CategoryNode[];
  parentId: number | null;
  isParentPanel?: boolean;
  selectedId?: number | null;
  onSelect?: (id: number) => void;
  showChildCount?: boolean;
  emptyHint?: string;
}

function CategoryPanel({
  title,
  items,
  parentId,
  isParentPanel = false,
  selectedId,
  onSelect,
  showChildCount,
  emptyHint = "لا توجد فئات",
}: PanelProps) {
  const [order, setOrder] = React.useState<CategoryNode[]>(items);
  const [dragIndex, setDragIndex] = React.useState<number | null>(null);
  const [adding, setAdding] = React.useState(false);
  const [pending, start] = React.useTransition();
  // Root panel always allows adding; child panel only once a parent is chosen.
  const canAdd = isParentPanel || parentId !== null;

  React.useEffect(() => setOrder(items), [items]);

  function persistOrder(next: CategoryNode[]) {
    setOrder(next);
    start(async () => {
      const fd = new FormData();
      fd.set("ids", next.map((c) => c.id).join(","));
      await reorderCategories(fd);
    });
  }

  function onDrop(index: number) {
    if (dragIndex === null || dragIndex === index) return setDragIndex(null);
    const next = [...order];
    const [moved] = next.splice(dragIndex, 1);
    next.splice(index, 0, moved);
    setDragIndex(null);
    persistOrder(next);
  }

  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between">
        <CardTitle className="text-base">{title}</CardTitle>
        {canAdd && (
          <Button size="sm" variant="outline" onClick={() => setAdding((v) => !v)}>
            <Plus className="size-4" /> إضافة
          </Button>
        )}
      </CardHeader>
      <CardContent className="space-y-2">
        {adding && (
          <AddForm
            parentId={parentId}
            onDone={() => setAdding(false)}
          />
        )}

        {order.length === 0 && !adding && (
          <p className="py-4 text-center text-sm text-muted-foreground">{emptyHint}</p>
        )}

        {order.map((category, index) => (
          <div
            key={category.id}
            draggable
            onDragStart={() => setDragIndex(index)}
            onDragOver={(e) => e.preventDefault()}
            onDrop={() => onDrop(index)}
            className={cn(
              "flex items-center gap-2 rounded-lg border border-border p-2 transition-colors",
              dragIndex === index && "opacity-50",
              selectedId === category.id && "border-primary bg-primary/5",
            )}
          >
            <GripVertical className="size-4 cursor-grab text-muted-foreground" />
            <CategoryRow
              category={category}
              selectable={!!onSelect}
              selected={selectedId === category.id}
              onSelect={() => onSelect?.(category.id)}
              showChildCount={showChildCount}
            />
          </div>
        ))}
        {pending && (
          <p className="flex items-center gap-1 text-xs text-muted-foreground">
            <Loader2 className="size-3 animate-spin" /> جارٍ حفظ الترتيب...
          </p>
        )}
      </CardContent>
    </Card>
  );
}

function CategoryRow({
  category,
  selectable,
  selected,
  onSelect,
  showChildCount,
}: {
  category: CategoryNode;
  selectable: boolean;
  selected: boolean;
  onSelect: () => void;
  showChildCount?: boolean;
}) {
  const [editing, setEditing] = React.useState(false);
  const [name, setName] = React.useState(category.name_ar);
  const [error, setError] = React.useState<string | null>(null);
  const [pending, start] = React.useTransition();

  React.useEffect(() => setName(category.name_ar), [category.name_ar]);

  function save() {
    start(async () => {
      const fd = new FormData();
      fd.set("id", String(category.id));
      fd.set("name_ar", name);
      const res = await updateCategory(fd);
      if (res && res.ok === false) setError(res.error);
      else setEditing(false);
    });
  }

  function remove() {
    if (!confirm(`حذف الفئة "${category.name_ar}"؟`)) return;
    start(async () => {
      const fd = new FormData();
      fd.set("id", String(category.id));
      const res = await deleteCategory(fd);
      if (res && res.ok === false) setError(res.error);
    });
  }

  if (editing) {
    return (
      <div className="flex flex-1 items-center gap-2">
        <Input value={name} onChange={(e) => setName(e.target.value)} className="h-8" autoFocus />
        <Button size="icon" variant="ghost" className="size-8" onClick={save} disabled={pending}>
          {pending ? <Loader2 className="size-4 animate-spin" /> : <Check className="size-4 text-emerald-600" />}
        </Button>
        <Button
          size="icon"
          variant="ghost"
          className="size-8"
          onClick={() => {
            setEditing(false);
            setName(category.name_ar);
            setError(null);
          }}
        >
          <X className="size-4" />
        </Button>
      </div>
    );
  }

  return (
    <div className="flex flex-1 items-center justify-between gap-2">
      <button
        type="button"
        onClick={onSelect}
        disabled={!selectable}
        className={cn("text-right text-sm font-medium", selectable && "hover:text-primary")}
      >
        {category.name_ar}
      </button>
      <div className="flex items-center gap-2">
        {error && <span className="text-xs text-destructive">{error}</span>}
        {showChildCount && category.childCount > 0 && (
          <Badge variant="muted">{category.childCount} فرعية</Badge>
        )}
        <Badge variant="secondary">{category.listingsCount} إعلان</Badge>
        <Button size="icon" variant="ghost" className="size-8" onClick={() => setEditing(true)}>
          <Pencil className="size-4" />
        </Button>
        <Button size="icon" variant="ghost" className="size-8 text-destructive" onClick={remove} disabled={pending}>
          <Trash2 className="size-4" />
        </Button>
      </div>
    </div>
  );
}

function AddForm({ parentId, onDone }: { parentId: number | null; onDone: () => void }) {
  const [name, setName] = React.useState("");
  const [icon, setIcon] = React.useState("");
  const [error, setError] = React.useState<string | null>(null);
  const [pending, start] = React.useTransition();

  function submit(e: React.FormEvent) {
    e.preventDefault();
    start(async () => {
      const fd = new FormData();
      fd.set("name_ar", name);
      fd.set("icon", icon);
      if (parentId != null) fd.set("parent_id", String(parentId));
      const res = await createCategory(fd);
      if (res && res.ok === false) setError(res.error);
      else {
        setName("");
        setIcon("");
        onDone();
      }
    });
  }

  return (
    <form onSubmit={submit} className="flex items-center gap-2 rounded-lg border border-dashed border-border p-2">
      <Input value={name} onChange={(e) => setName(e.target.value)} placeholder="اسم الفئة" className="h-8" required />
      <Input value={icon} onChange={(e) => setIcon(e.target.value)} placeholder="الأيقونة (اختياري)" className="h-8 w-32" />
      <Button type="submit" size="sm" disabled={pending}>
        {pending ? <Loader2 className="size-4 animate-spin" /> : <Check className="size-4" />} حفظ
      </Button>
      {error && <span className="text-xs text-destructive">{error}</span>}
    </form>
  );
}
