import Link from "next/link";
import { Award, BookOpen, ClipboardList, Sparkles } from "lucide-react";

const HOW_IT_WORKS = [
  {
    icon: ClipboardList,
    title: "1. Опрос",
    text: "5–7 минут вопросов о вашей роли, опыте и болях",
  },
  {
    icon: Sparkles,
    title: "2. Программа",
    text: "Получаете персональный путь из 3–7 курсов под ваши задачи",
  },
  {
    icon: BookOpen,
    title: "3. Микро-уроки",
    text: "Блоки по 5–15 минут с практикой на ваших реальных задачах",
  },
];

const FEATURES = [
  "18 курсов Anthropic Academy с русским переводом",
  "Персонализация под 11 ролей IBG",
  "Микро-формат: уроки по 12–38 минут с практикой",
  "Андрагогика Ноулза: обучение для взрослых, не школьный подход",
  "Сертификат после завершения каждого курса",
];

export default function HomePage() {
  return (
    <>
      <header className="sticky top-0 z-50 w-full border-b border-slate-100 bg-white/80 backdrop-blur">
        <div className="mx-auto flex h-14 max-w-4xl items-center justify-between px-4">
          <span className="text-base font-bold tracking-tight text-slate-900 sm:text-lg">
            AI-transformation
          </span>
          <Link
            href="/signup"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-slate-900"
          >
            Войти
          </Link>
        </div>
      </header>

      <main className="flex-1">
        <section className="mx-auto max-w-4xl px-4 py-16 text-center sm:py-24">
          <h1 className="text-4xl font-bold tracking-tight text-slate-900 sm:text-5xl md:text-6xl">
            AI-transformation
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
            Программа обучения Claude для команды IBG. Персональная программа из 18 курсов
            Anthropic Academy на русском, под вашу роль.
          </p>
          <div className="mt-8 flex flex-col items-center gap-3">
            <Link
              href="/signup"
              className="inline-flex items-center justify-center rounded-lg bg-slate-900 px-6 py-3 text-base font-semibold text-white shadow-sm transition-colors hover:bg-slate-800"
            >
              У меня есть invite
            </Link>
            <p className="text-sm text-slate-500">
              Нет invite? Свяжитесь с HR или Юрой Пак
            </p>
          </div>
        </section>

        <section className="mx-auto max-w-4xl px-4 py-12 sm:py-16">
          <h2 className="text-center text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl">
            Как это работает
          </h2>
          <div className="mt-10 grid gap-8 sm:grid-cols-3 sm:gap-6">
            {HOW_IT_WORKS.map(({ icon: Icon, title, text }) => (
              <div key={title} className="text-center sm:text-left">
                <Icon
                  className="mx-auto h-8 w-8 text-blue-600 sm:mx-0"
                  aria-hidden
                />
                <h3 className="mt-4 text-lg font-semibold text-slate-900">
                  {title}
                </h3>
                <p className="mt-2 text-sm leading-relaxed text-slate-600">
                  {text}
                </p>
              </div>
            ))}
          </div>
        </section>

        <section className="mx-auto max-w-4xl px-4 py-12 sm:py-16">
          <h2 className="text-center text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl">
            Что внутри
          </h2>
          <ul className="mx-auto mt-10 max-w-2xl divide-y divide-slate-100 overflow-hidden rounded-xl border border-slate-200 bg-white">
            {FEATURES.map((feature) => (
              <li
                key={feature}
                className="flex items-start gap-3 px-5 py-4"
              >
                <Award
                  className="mt-0.5 h-5 w-5 shrink-0 text-blue-600"
                  aria-hidden
                />
                <span className="text-sm leading-relaxed text-slate-700 sm:text-base">
                  {feature}
                </span>
              </li>
            ))}
          </ul>
        </section>
      </main>

      <footer className="mt-12 border-t border-slate-100 py-8">
        <div className="mx-auto flex max-w-4xl flex-col items-center justify-between gap-3 px-4 text-center text-sm text-slate-500 sm:flex-row sm:text-left">
          <p>AI-transformation — внутренняя платформа IBG Property</p>
          <a
            href="https://t.me/+claude-help"
            target="_blank"
            rel="noopener noreferrer"
            className="text-slate-600 transition-colors hover:text-slate-900"
          >
            Поддержка
          </a>
        </div>
      </footer>
    </>
  );
}
