"use client";

import * as React from "react";
import { useRouter } from "next/navigation";
import { Loader2, Send } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { sendSupportReply } from "@/app/actions/support";

export function SupportReplyForm({ userId }: { userId: string }) {
  const router = useRouter();
  const [body, setBody] = React.useState("");
  const [error, setError] = React.useState<string | null>(null);
  const [pending, startTransition] = React.useTransition();

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const trimmed = body.trim();
    if (!trimmed) return;
    setError(null);
    startTransition(async () => {
      const formData = new FormData();
      formData.set("userId", userId);
      formData.set("body", trimmed);
      const result = await sendSupportReply(formData);
      if (result.ok === false) {
        setError(result.error);
        return;
      }
      setBody("");
      router.refresh();
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <Textarea
        value={body}
        onChange={(e) => setBody(e.target.value)}
        placeholder="اكتب ردك..."
        rows={3}
        disabled={pending}
      />
      {error && <p className="text-sm text-destructive">{error}</p>}
      <div className="flex justify-end">
        <Button type="submit" disabled={pending || !body.trim()}>
          {pending ? <Loader2 className="size-4 animate-spin" /> : <Send className="size-4" />}
          إرسال
        </Button>
      </div>
    </form>
  );
}
