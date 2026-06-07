import { ShieldCheck } from "lucide-react";

import { LoginForm } from "./login-form";

export const metadata = { title: "تسجيل الدخول — لوحة تحكم سوق العراق" };
export const dynamic = "force-dynamic";

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-muted/40 p-4">
      <div className="w-full max-w-sm rounded-xl border border-border bg-card p-8 shadow-sm">
        <div className="mb-6 flex flex-col items-center gap-3 text-center">
          <div className="flex size-14 items-center justify-center rounded-2xl bg-primary text-primary-foreground">
            <ShieldCheck className="size-7" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-foreground">لوحة تحكم سوق العراق</h1>
            <p className="mt-1 text-sm text-muted-foreground">
              تسجيل الدخول للمشرفين فقط
            </p>
          </div>
        </div>
        <LoginForm />
      </div>
    </main>
  );
}
