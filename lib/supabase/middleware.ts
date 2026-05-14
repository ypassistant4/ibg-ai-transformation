import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * Префиксы роутов, на которые пускаем только залогиненных.
 * Не-авторизованный пользователь → редирект на /login.
 */
const PROTECTED_PREFIXES = [
  "/program",
  "/courses",
  "/profile",
  "/admin",
  "/onboarding",
];

/**
 * Страницы аутентификации.
 * Уже залогиненный пользователь → редирект на /program (там сам решит куда).
 */
const AUTH_PAGES = ["/login", "/signup"];

/**
 * Обновление сессии Supabase + проверка доступа на каждый запрос.
 *
 * Делает:
 * 1. Читает auth-cookies из request
 * 2. Запрашивает getUser() — рефрешит токен если он близок к истечению
 * 3. Решает, нужен ли редирект (по таблицам PROTECTED_PREFIXES / AUTH_PAGES)
 * 4. Сохраняет обновлённые cookies в response
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

  // Принудительный рефреш токена + получение текущего user.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const pathname = request.nextUrl.pathname;

  const isProtected = PROTECTED_PREFIXES.some(
    (prefix) => pathname === prefix || pathname.startsWith(prefix + "/"),
  );
  const isAuthPage = AUTH_PAGES.includes(pathname);

  // 1) Гость на защищённой странице → /login
  if (!user && isProtected) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // 2) Залогиненный на /login или /signup → /program
  //    ВАЖНО: только для GET-навигации. POST-запросы (Server Actions,
  //    form submissions) пропускаем — иначе мы убьём Server Action consumeInvite,
  //    который вызывается сразу после auth.signUp: signUp ставит cookies,
  //    следующий же POST к /signup уже видится middleware как залогиненный,
  //    и редирект на /program прибьёт сам Server Action.
  if (user && isAuthPage && request.method === "GET") {
    const url = request.nextUrl.clone();
    url.pathname = "/program";
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}
