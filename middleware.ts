import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

/**
 * Корневой middleware Next.js. Запускается перед каждым matched роутом
 * и обновляет Supabase-сессию (рефреш токенов).
 */
export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

/**
 * Применяется ко всем роутам, кроме статики и картинок:
 * - _next/static — серверные бандлы и CSS
 * - _next/image — оптимизатор изображений
 * - favicon.ico
 * - файлы со стандартными image-расширениями
 */
export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
