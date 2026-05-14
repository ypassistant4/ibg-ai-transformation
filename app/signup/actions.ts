"use server";

import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export type ConsumeInviteResult =
  | { ok: true }
  | { ok: false; error: string };

/**
 * Server Action: помечает invite использованным сразу после успешного signUp.
 *
 * Почему Server Action, а не клиентский UPDATE:
 * 1. Между signUp на клиенте и следующим запросом к Supabase есть тайминг —
 *    JWT может не успеть прицепиться, и UPDATE падает под анонимные права.
 * 2. RLS-политика для invites с FOR UPDATE сложно отлаживается из-за того, что
 *    PostgREST на 0 affected rows возвращает 200 OK без ошибки.
 * 3. Server-side у нас есть access ко всему: проверка сессии через cookies +
 *    UPDATE через service_role (минует RLS), плюс защита `.is("used_at", null)`
 *    от race condition между параллельными попытками потребить один invite.
 */
export async function consumeInvite(
  token: string,
): Promise<ConsumeInviteResult> {
  try {
    const supabase = await createClient();
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError) {
      return { ok: false, error: "Auth error: " + userError.message };
    }
    if (!user) {
      return { ok: false, error: "Сессия не найдена" };
    }

    const admin = createAdminClient();
    const { data, error } = await admin
      .from("invites")
      .update({
        used_at: new Date().toISOString(),
        used_by: user.id,
      })
      .eq("token", token)
      .is("used_at", null) // race-safe: только если ещё не потреблён
      .select("id");

    if (error) {
      return { ok: false, error: error.message };
    }
    if (!data || data.length === 0) {
      return {
        ok: false,
        error: "Invite не найден или уже использован",
      };
    }

    return { ok: true };
  } catch (e) {
    console.error("[consumeInvite] unexpected error:", e);
    return {
      ok: false,
      error: e instanceof Error ? e.message : String(e),
    };
  }
}
