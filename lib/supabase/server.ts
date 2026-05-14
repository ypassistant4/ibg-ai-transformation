import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

/**
 * Supabase-клиент для Server Components, Route Handlers, Server Actions.
 * Читает auth-cookies через next/headers и поддерживает обновление сессии.
 *
 * В Next.js 15 cookies() — async, поэтому функция async.
 *
 * Использование (Server Component):
 *   import { createClient } from "@/lib/supabase/server";
 *   const supabase = await createClient();
 *   const { data } = await supabase.from("ob_courses").select("*");
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // Вызов из Server Component — изменение cookies невозможно.
            // Это нормально, если middleware обновляет сессию.
          }
        },
      },
    },
  );
}
