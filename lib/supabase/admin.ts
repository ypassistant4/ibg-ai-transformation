import { createClient } from "@supabase/supabase-js";

/**
 * Серверный Supabase-клиент с service_role ключом.
 *
 * Обходит RLS — нужен для операций, где доверять клиентской сессии нельзя:
 * - помечать invite использованным после signUp (race-conditions с RLS)
 * - админские бэкенд-задачи (массовая выдача invites, аудит, и т.п.)
 *
 * ВНИМАНИЕ: использовать ТОЛЬКО на сервере (Server Actions, Route Handlers,
 * Server Components). НИКОГДА не импортировать в файлах с "use client":
 * service_role ключ нельзя отдавать на браузер — это даёт полный доступ к БД.
 *
 * Файл специально не помечен "use server" и не использует next/headers, чтобы
 * случайный импорт в client-компоненте сразу падал с понятной ошибкой
 * (service_role env-переменная без префикса NEXT_PUBLIC_ недоступна в browser).
 */
export function createAdminClient() {
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("SUPABASE_SERVICE_ROLE_KEY env variable is required");
  }

  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  );
}
