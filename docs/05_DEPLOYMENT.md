# Деплой и настройка инфраструктуры

> Этот документ описывает, как развернуть проект с нуля в production.

## Что должен сделать Юра до старта работы Каролины

### 1. GitHub
- [x] Создать организацию `ibg-property` (если нет)
- [x] Создать приватный репозиторий `ibg-ai-transformation`
- [x] Пригласить `ypassistant4` как Collaborator с правами Write

### 2. Supabase
- [x] Создать новый проект `ibg-ai-transformation`
  - Регион: Southeast Asia (Singapore)
  - Plan: Free
- [x] Сохранить креды:
  - `Project URL`
  - `anon public key`
  - `service_role key` (секретный!)
  - Database password
- [x] Запустить SQL-миграции (см. ниже)

### 3. Vercel
- [x] Создать проект из GitHub `ibg-property/ibg-ai-transformation`
- [x] Framework Preset: Next.js
- [x] Добавить env vars (см. ниже)
- [x] Задеплоить (первый раз — после загрузки стартового кода)

### 4. Anthropic Console
- [x] Получить API key для проекта
- [x] Сохранить в Vercel env vars

### 5. Domain
- [x] Купить или назначить субдомен `academy.ibgproperty.com`
- [x] Настроить CNAME в DNS:
  - Type: CNAME
  - Name: academy
  - Value: cname.vercel-dns.com
- [x] Привязать к Vercel проекту

---

## Запуск SQL-миграций

### Где
Supabase Dashboard → SQL Editor → New query

### Порядок (строго!)
Запускать файлы по очереди, начиная с 001. После каждого — проверять, что нет ошибок.

```
1. 001_onboarding_schema.sql           ← базовые таблицы
2. 002_seed_tracks_and_courses.sql     ← 18 курсов и 4 трека
3. 004_schema_v2_assessment.sql        ← роли, опрос, программы
4. 005_seed_roles_levels_templates.sql ← 11 ролей × 3 уровня = 33 шаблона
5. 003_seed_claude_101_lessons.sql     ← уроки Claude 101 (новая v2 структура)
6. 006_seed_role_overlays_demo.sql     ← IBG-инжекции под роли (demo для 4 ролей)
```

⚠️ **Важно:** файл `003` запускается **после** `005`, потому что v2 lessons используют расширенную схему из `004`.

### Дополнительная миграция для invites

После основных миграций — выполнить эту дополнительную SQL:

```sql
-- Таблица invites
CREATE TABLE IF NOT EXISTS invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    pre_filled_role_id UUID REFERENCES ob_roles(id),
    created_by UUID REFERENCES auth.users(id),
    used_by UUID REFERENCES auth.users(id),
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days')
);

CREATE INDEX idx_invites_token ON invites(token);
CREATE INDEX idx_invites_email ON invites(email);

ALTER TABLE invites ENABLE ROW LEVEL SECURITY;

-- Только admin может создавать и видеть invites
CREATE POLICY "Admins manage invites" ON invites
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE id = auth.uid()
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Любой может проверить свой invite (для регистрации)
CREATE POLICY "Anyone can read invite by token" ON invites
    FOR SELECT USING (TRUE);

-- Функция для инкремента времени на уроке
CREATE OR REPLACE FUNCTION increment_lesson_time(
    p_user_id UUID,
    p_lesson_id UUID,
    p_seconds INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ob_user_progress
    SET time_spent_seconds = time_spent_seconds + p_seconds,
        updated_at = NOW()
    WHERE user_id = p_user_id AND lesson_id = p_lesson_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Создать первого admin (замени email на свой)
-- ВЫПОЛНИТЬ ВРУЧНУЮ ПОСЛЕ РЕГИСТРАЦИИ ЮРЫ:
-- UPDATE auth.users
-- SET raw_user_meta_data = jsonb_set(raw_user_meta_data, '{role}', '"admin"')
-- WHERE email = 'yury@ibgproperty.com';
```

---

## Environment Variables

Файл `.env.local` (только для локалки, **не коммитить**):

```env
NEXT_PUBLIC_SUPABASE_URL=https://[ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
ANTHROPIC_API_KEY=sk-ant-...

# Для будущих фич (можно пустыми пока)
RESEND_API_KEY=
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

В Vercel Dashboard → Settings → Environment Variables — те же переменные, но `NEXT_PUBLIC_APP_URL=https://academy.ibgproperty.com`.

---

## Локальная разработка

### Первый запуск
```bash
git clone https://github.com/ibg-property/ibg-ai-transformation.git
cd ibg-ai-transformation
pnpm install
cp .env.local.example .env.local
# Заполнить .env.local своими значениями
pnpm dev
```

### Открыть в браузере
http://localhost:3000

### Если что-то не работает
1. `pnpm install` ещё раз
2. Удалить `.next/` и `node_modules/`, запустить заново
3. Проверить, что в `.env.local` все ключи правильные
4. Спросить Юру

---

## Деплой в production

### Автоматический (через Vercel)
Любой `git push` в `main` автоматически деплоит на production.

### Preview-деплои
Каждый PR создаёт preview-URL вида `pr-N.ibg-ai-transformation.vercel.app`.
Можно проверять изменения до merge.

### Откат
В Vercel Dashboard → Deployments → выбрать предыдущий → Promote to Production.

---

## Мониторинг

### Vercel Analytics
Включить в Vercel Dashboard → Analytics. Покажет посещаемость, время загрузки, Core Web Vitals.

### Supabase Logs
Supabase Dashboard → Logs → API logs. Увидишь все запросы к базе.

### Errors
Пока нет интеграции с Sentry или подобным. Логи смотреть в Vercel Functions logs.

---

## Резервное копирование

### Supabase
Free план Supabase делает ежедневные бэкапы автоматически (хранятся 7 дней).
Для долговременного хранения — апгрейд до Pro плана ($25/мес) когда будет 100+ пользователей.

### Контент уроков
Контент хранится в Supabase. Раз в неделю экспортировать вручную в SQL-дамп через Supabase CLI:
```bash
supabase db dump --schema public > backup-$(date +%Y%m%d).sql
```

---

## Чеклист готовности к запуску

Перед открытием платформы для пользователей:

- [ ] Все SQL-миграции выполнены без ошибок
- [ ] Проверено: можно зарегистрироваться по invite
- [ ] Проверено: опрос проходится и сохраняется
- [ ] Проверено: программа генерируется
- [ ] Проверено: первый урок Claude 101 проходится полностью
- [ ] Проверено: прогресс сохраняется между сессиями
- [ ] Проверено: admin может создать invite
- [ ] Проверено: admin может отредактировать урок
- [ ] Все 8 экранов работают на iPhone SE (375px)
- [ ] HTTPS работает на academy.ibgproperty.com
- [ ] Vercel production URL = production deploy
- [ ] Юра — первый зарегистрированный admin
- [ ] Создан первый тестовый invite для Каролины

---

## Команды для повседневной работы

```bash
# Локалка
pnpm dev                # запустить локально
pnpm build              # собрать прод
pnpm lint               # проверить ESLint
pnpm typecheck          # проверить TypeScript

# Git
git checkout -b feature/new-feature
git add .
git commit -m "feat: описание"
git push origin feature/new-feature

# Supabase (если установлен CLI)
supabase db reset        # сбросить локальную базу (только локально!)
supabase db dump         # экспорт схемы
```

---

## Поддержка

- Юра в Telegram: `@4yupak`
- Канал: #claude-help
- Документация Vercel: https://vercel.com/docs
- Документация Supabase: https://supabase.com/docs
- Документация Next.js: https://nextjs.org/docs
