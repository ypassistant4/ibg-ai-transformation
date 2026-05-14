"use client";

import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { toast } from "sonner";
import { Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { consumeInvite } from "./actions";

// useSearchParams в Client Component требует force-dynamic, иначе сборка ругается.
export const dynamic = "force-dynamic";

type InviteState =
  | { kind: "loading" }
  | { kind: "no-token" }
  | { kind: "invalid" }
  | { kind: "valid"; id: string; email: string; token: string };

export default function SignupPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("invite");
  const supabase = createClient();

  const [invite, setInvite] = useState<InviteState>({ kind: "loading" });
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    passwordConfirm: "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Проверяем invite при первой загрузке
  useEffect(() => {
    if (!token) {
      setInvite({ kind: "no-token" });
      return;
    }

    let cancelled = false;
    (async () => {
      const { data, error } = await supabase
        .from("invites")
        .select("id, email, token, used_at, expires_at")
        .eq("token", token)
        .maybeSingle();

      if (cancelled) return;

      if (error || !data) {
        setInvite({ kind: "invalid" });
        return;
      }

      const expired = new Date(data.expires_at) <= new Date();
      if (data.used_at || expired) {
        setInvite({ kind: "invalid" });
        return;
      }

      setInvite({ kind: "valid", id: data.id, email: data.email, token: data.token });
      setFormData((f) => ({ ...f, email: data.email }));
    })();

    return () => {
      cancelled = true;
    };
  }, [token, supabase]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (invite.kind !== "valid") return;

    if (formData.name.trim().length < 2) {
      setError("Введите имя и фамилию");
      return;
    }
    if (formData.password.length < 8) {
      setError("Пароль должен быть не короче 8 символов");
      return;
    }
    if (formData.password !== formData.passwordConfirm) {
      setError("Пароли не совпадают");
      return;
    }

    setSubmitting(true);
    try {
      const { data, error: signUpError } = await supabase.auth.signUp({
        email: formData.email,
        password: formData.password,
        options: { data: { full_name: formData.name.trim() } },
      });

      if (signUpError) {
        setError(signUpError.message);
        return;
      }

      // Если email confirmation включён в Supabase Auth — сессии нет.
      // В таком случае мы не можем сразу пометить invite и зайти на /onboarding.
      if (!data.session) {
        toast.info("Проверьте почту — мы отправили письмо для подтверждения.");
        return;
      }

      // Помечаем invite использованным через Server Action — обходит race
      // между signUp и client-side UPDATE (см. app/signup/actions.ts).
      const consumeResult = await consumeInvite(invite.token);
      if (!consumeResult.ok) {
        // Не критично: пользователь уже зарегистрирован. Логируем для отладки.
        console.warn("consumeInvite failed:", consumeResult.error);
      }

      toast.success("Аккаунт создан!");
      router.push("/onboarding");
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
        Регистрация
      </h1>

      <div className="w-full rounded-xl border border-slate-200 bg-white p-6 shadow-sm sm:p-8">
        {invite.kind === "loading" && (
          <div className="py-4 text-center text-sm text-slate-500">
            <Loader2 className="mx-auto h-5 w-5 animate-spin text-blue-600" />
            <p className="mt-3">Проверяем приглашение…</p>
          </div>
        )}

        {invite.kind === "no-token" && (
          <p className="py-2 text-center text-sm leading-relaxed text-slate-700">
            Эта страница доступна только по приглашению. Свяжитесь с HR или Юрой Пак,
            чтобы получить персональную invite-ссылку.
          </p>
        )}

        {invite.kind === "invalid" && (
          <div className="space-y-2 py-2 text-center">
            <p className="text-sm leading-relaxed text-slate-700">
              Эта ссылка недействительна или уже использована.
            </p>
            <p className="text-sm text-slate-500">Получите новую у HR.</p>
          </div>
        )}

        {invite.kind === "valid" && (
          <form className="space-y-4" onSubmit={handleSubmit} noValidate>
            <Field label="Имя и фамилия" htmlFor="name">
              <input
                id="name"
                type="text"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                disabled={submitting}
                required
                autoComplete="name"
                placeholder="Каролина Петрова"
                className={inputClass}
              />
            </Field>

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

            <Field label="Пароль (минимум 8 символов)" htmlFor="password">
              <input
                id="password"
                type="password"
                value={formData.password}
                onChange={(e) =>
                  setFormData({ ...formData, password: e.target.value })
                }
                disabled={submitting}
                required
                minLength={8}
                autoComplete="new-password"
                className={inputClass}
              />
            </Field>

            <Field label="Повторите пароль" htmlFor="passwordConfirm">
              <input
                id="passwordConfirm"
                type="password"
                value={formData.passwordConfirm}
                onChange={(e) =>
                  setFormData({ ...formData, passwordConfirm: e.target.value })
                }
                disabled={submitting}
                required
                minLength={8}
                autoComplete="new-password"
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
              {submitting ? "Создаём аккаунт…" : "Зарегистрироваться"}
            </button>
          </form>
        )}
      </div>
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
