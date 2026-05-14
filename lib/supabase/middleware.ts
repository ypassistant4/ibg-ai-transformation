import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * Обновление сессии Supabase для каждого запроса.
 * Вызывается из корневого middleware.ts на каждый matched роут.
 *
 * Делает три вещи:
 * 1. Читает auth-cookies из request
 * 2. Запрашивает getUser() — это рефрешит токен если он близок к истечению
 * 3. Сохраняет обновлённые cookies в response
 *
 * ВАЖНО: не удаляй вызов supabase.auth.getUser() — без него сессия не
 * обновляется и пользователя начнёт разлогинивать через час.
 */
export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // Принудительный рефреш токена, если он близок к истечению.
  await supabase.auth.getUser();

  return supabaseResponse;
}
