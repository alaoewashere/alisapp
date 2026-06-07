"use client";

import * as React from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Loader2 } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [email, setEmail] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [error, setError] = React.useState<string | null>(null);
  const [loading, setLoading] = React.useState(false);

  async function onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    const supabase = createClient();
    const { data, error: signInError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (signInError || !data.user) {
      setError("بيانات الدخول غير صحيحة");
      setLoading(false);
      return;
    }

    const { data: admin } = await supabase
      .from("admin_users")
      .select("id")
      .eq("id", data.user.id)
      .maybeSingle();

    if (!admin) {
      await supabase.auth.signOut();
      setError("هذا الحساب لا يملك صلاحيات الإدارة");
      setLoading(false);
      return;
    }

    const redirectTo = searchParams.get("redirect") ?? "/dashboard";
    router.replace(redirectTo);
    router.refresh();
  }

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <div className="space-y-1.5">
        <Label htmlFor="email">البريد الإلكتروني</Label>
        <Input
          id="email"
          type="email"
          dir="ltr"
          required
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="admin@souqiq.com"
        />
      </div>
      <div className="space-y-1.5">
        <Label htmlFor="password">كلمة المرور</Label>
        <Input
          id="password"
          type="password"
          dir="ltr"
          required
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </div>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <Button type="submit" className="w-full" disabled={loading}>
        {loading && <Loader2 className="size-4 animate-spin" />}
        تسجيل الدخول
      </Button>
    </form>
  );
}
