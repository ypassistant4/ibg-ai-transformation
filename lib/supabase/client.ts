import { createBrowserClient } from "@supabase/ssr";

/**
 * Supabase-клиент для Client Components (browser).
 * Использует NEXT_PUBLIC_* переменные — они попадают в bundle, это нормально:
 * anon key защищён Row Level Security в Postgres.
 *
 * Использование:
 *   "use client";
 *   import { createClient } from "@/lib/supabase/client";
 *   const supabase = createClient();
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
