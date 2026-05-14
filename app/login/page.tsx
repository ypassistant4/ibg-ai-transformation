"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { toast } from "sonner";
import { Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [formData, setFormData] = useState({ email: "", password: "" });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (!formData.email || !formData.password) {
      setError("Введите email и пароль");
      return;
    }

    setSubmitting(true);
    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email: formData.email,
        password: formData.password,
      });

      if (signInError || !data.user) {
        setError("Неверный email или пароль");
        return;
      }

      // После входа решаем, куда вести: /program если опрос пройден, иначе /onboarding.
      // RLS политика "Users see own assessment" разрешает чтение собственной строки.
      const { data: assessment } = await supabase
        .from("ob_user_assessments")
        .select("completed_at")
        .eq("user_id", data.user.id)
        .maybeSingle();

      const target = assessment?.completed_at ? "/program" : "/onboarding";

      toast.success("С возвращением!");
      router.push(target);
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Что-то пошло не так");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col items-center justify-center px-4 py-12">
      <Link
        href="/"
        className="mb-8 text-base font-bold tracking-tight text-slate-900 hover:text-slate-700"
      >
        AI-transformation
      </Link>

      <h1 className="mb-6 text-2xl font-bold tracking-tight text-slate-900">
        Вход
      </h1>

      <div className="w-full rounded-xl border border-slate-200 bg-white p-6 shadow-sm sm:p-8">
        <form className="space-y-4" onSubmit={handleSubmit} noValidate>
          <Field label="Email" htmlFor="email">
            <input
              id="email"
              type="email"
              value={formData.email}
              onChange={(e) =>
                setFormData({ ...formData, email: e.target.value })
              }
              disabled={submitting}
              required
              autoComplete="email"
              className={inputClass}
            />
          </Field>

          <Field label="Пароль" htmlFor="password">
            <input
              id="password"
              type="password"
              value={formData.password}
              onChange={(e) =>
                setFormData({ ...formData, password: e.target.value })
              }
              disabled={submitting}
              required
              autoComplete="current-password"
              className={inputClass}
            />
          </Field>

          {error && (
            <p className="text-sm text-red-600" role="alert">
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="flex w-full items-center justify-center gap-2 rounded-lg bg-slate-900 px-4 py-3 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting && <Loader2 className="h-4 w-4 animate-spin" />}
            {submitting ? "Входим…" : "Войти"}
          </button>
        </form>

        <p className="mt-5 text-center text-sm text-slate-500">
          <Link href="#" className="hover:text-slate-700">
            Забыли пароль?
          </Link>
        </p>
      </div>

      <p className="mt-6 text-center text-xs text-slate-500">
        Нет аккаунта? Получите invite-ссылку у HR.
      </p>
    </main>
  );
}

const inputClass =
  "block w-full rounded-md border border-slate-300 px-3 py-2 text-sm text-slate-900 shadow-sm transition-colors placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 disabled:bg-slate-50 disabled:text-slate-500";

function Field({
  label,
  htmlFor,
  children,
}: {
  label: string;
  htmlFor: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label
        htmlFor={htmlFor}
        className="mb-1.5 block text-sm font-medium text-slate-700"
      >
        {label}
      </label>
      {children}
    </div>
  );
}
