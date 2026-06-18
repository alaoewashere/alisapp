"use client";

import * as React from "react";
import { Loader2, Plus, Trash2 } from "lucide-react";

import {
  createBlockedWord,
  deleteBlockedWord,
  toggleBlockedWord,
} from "@/app/actions/blocked-words";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";

export interface BlockedWordRow {
  id: string;
  word: string;
  normalized_form: string;
  severity: string;
  active: boolean;
  created_at: string;
}

export function BlockedWordsManager({ words }: { words: BlockedWordRow[] }) {
  const [pending, start] = React.useTransition();
  const [error, setError] = React.useState<string | null>(null);
  const [newWord, setNewWord] = React.useState("");

  function run(action: () => Promise<{ ok: boolean; error?: string }>) {
    setError(null);
    start(async () => {
      const result = await action();
      if (!result.ok) setError(result.error ?? "حدث خطأ");
    });
  }

  function handleAdd(e: React.FormEvent) {
    e.preventDefault();
    const fd = new FormData();
    fd.set("word", newWord);
    fd.set("severity", "high");
    run(async () => {
      const result = await createBlockedWord(fd);
      if (result.ok) setNewWord("");
      return result;
    });
  }

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="text-base">إضافة كلمة محظورة</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleAdd} className="flex flex-wrap items-center gap-2">
            <Input
              value={newWord}
              onChange={(e) => setNewWord(e.target.value)}
              placeholder="أدخل الكلمة (مثال: testbadword1)"
              className="max-w-md"
              dir="auto"
            />
            <Button type="submit" size="sm" disabled={pending || !newWord.trim()}>
              {pending ? <Loader2 className="size-4 animate-spin" /> : <Plus className="size-4" />}
              إضافة
            </Button>
          </form>
          <p className="mt-2 text-xs text-muted-foreground">
            يُطبَّع النص تلقائياً (تشكيل، أ/إ/آ، تكرار الحروف) لمطابقة محاولات التهرب.
          </p>
          {error && <p className="mt-2 text-sm text-destructive">{error}</p>}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">القائمة ({words.length})</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {words.length === 0 ? (
            <p className="text-sm text-muted-foreground">لا توجد كلمات بعد.</p>
          ) : (
            words.map((row) => (
              <div
                key={row.id}
                className="flex flex-wrap items-center justify-between gap-2 rounded-lg border border-border/60 bg-field/40 px-3 py-2"
              >
                <div className="min-w-0">
                  <p className="font-medium" dir="auto">
                    {row.word}
                  </p>
                  <p className="text-xs text-muted-foreground" dir="ltr">
                    {row.normalized_form}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <Badge variant={row.active ? "default" : "secondary"}>
                    {row.active ? "نشطة" : "معطّلة"}
                  </Badge>
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={pending}
                    onClick={() => {
                      const fd = new FormData();
                      fd.set("id", row.id);
                      fd.set("active", String(!row.active));
                      run(() => toggleBlockedWord(fd));
                    }}
                  >
                    {row.active ? "تعطيل" : "تفعيل"}
                  </Button>
                  <Button
                    size="sm"
                    variant="destructive"
                    disabled={pending}
                    onClick={() => {
                      if (!confirm(`حذف «${row.word}»؟`)) return;
                      const fd = new FormData();
                      fd.set("id", row.id);
                      run(() => deleteBlockedWord(fd));
                    }}
                  >
                    <Trash2 className="size-4" />
                  </Button>
                </div>
              </div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  );
}
