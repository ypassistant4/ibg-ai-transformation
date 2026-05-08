-- ============================================================================
-- REALTRUM Onboarding — Claude 101 v2 (АНДРАГОГИКА + МИКРООБУЧЕНИЕ)
-- 12 уроков, разбитых на микро-блоки по 5-15 минут
-- Методология: 6 принципов Ноулза + microlearning
--
-- НОВАЯ СТРУКТУРА КАЖДОГО УРОКА:
-- 🎯 Зачем это вам (need to know)
-- 🔄 Что у вас сейчас (опора на опыт)
-- 📺 Видео + транскрипт (теория от Anthropic)
-- 💡 Как применить в IBG (мост к работе)
-- 🛠 Микро-практика прямо сейчас (5-25 мин)
-- ✅ Чек-лист самопроверки
--
-- Запускать ПОСЛЕ 002_seed_tracks_and_courses.sql
-- ============================================================================

-- Очищаем старую версию уроков
DELETE FROM ob_lessons
WHERE module_id IN (
    SELECT m.id FROM ob_modules m
    JOIN ob_courses c ON c.id = m.course_id
    WHERE c.slug = 'claude-101'
);
DELETE FROM ob_modules
WHERE course_id IN (SELECT id FROM ob_courses WHERE slug = 'claude-101');

-- Расширяем структуру уроков для микрообучения (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'ob_lessons' AND column_name = 'why_this_matters_ru') THEN
        ALTER TABLE ob_lessons
            ADD COLUMN why_this_matters_ru TEXT,
            ADD COLUMN reflect_on_experience_ru TEXT,
            ADD COLUMN apply_to_ibg_ru TEXT,
            ADD COLUMN micro_practice_ru TEXT,
            ADD COLUMN mastery_checklist_ru TEXT[],
            ADD COLUMN micro_blocks JSONB;
    END IF;
END $$;

-- ============================================================================
-- ЗАГРУЗКА УРОКОВ Claude 101 v2
-- ============================================================================
DO $$
DECLARE
    v_course_id UUID;
    v_module_1 UUID;
    v_module_2 UUID;
    v_module_3 UUID;
    v_module_4 UUID;
    v_module_5 UUID;
BEGIN
    SELECT id INTO v_course_id FROM ob_courses WHERE slug = 'claude-101';

    INSERT INTO ob_modules (course_id, slug, title_ru, title_en, description_ru, sort_order)
    VALUES (v_course_id, 'meet-claude', 'Знакомство с Claude', 'Meet Claude',
            'Что такое Claude, первый разговор. Снимаем страх и делаем первый рабочий результат за 30 минут.', 1)
    RETURNING id INTO v_module_1;

    INSERT INTO ob_modules (course_id, slug, title_ru, title_en, description_ru, sort_order)
    VALUES (v_course_id, 'better-results', 'Качественные результаты', 'Getting Better Results',
            'Как формулировать запросы и выбирать интерфейс, чтобы экономить время.', 2)
    RETURNING id INTO v_module_2;

    INSERT INTO ob_modules (course_id, slug, title_ru, title_en, description_ru, sort_order)
    VALUES (v_course_id, 'organize-work', 'Организация работы', 'Organizing your Work',
            'Projects, Artifacts, Skills — как сделать так, чтобы Claude помнил ваш контекст.', 3)
    RETURNING id INTO v_module_3;

    INSERT INTO ob_modules (course_id, slug, title_ru, title_en, description_ru, sort_order)
    VALUES (v_course_id, 'expand-reach', 'Расширение возможностей', 'Expanding Claude Reach',
            'Подключение ваших инструментов: Gmail, Calendar, Drive, Notion. Поиск и исследование.', 4)
    RETURNING id INTO v_module_4;

    INSERT INTO ob_modules (course_id, slug, title_ru, title_en, description_ru, sort_order)
    VALUES (v_course_id, 'putting-together', 'Закрепление', 'Putting It All Together',
            'Применение по ролям и план первой недели после курса.', 5)
    RETURNING id INTO v_module_5;

    -- УРОК 1
    INSERT INTO ob_lessons (
        module_id, slug, title_ru, title_en, summary_ru, summary_en,
        video_url, video_duration_seconds, transcript_en, transcript_ru,
        theory_ru, key_takeaways_ru,
        why_this_matters_ru, reflect_on_experience_ru, apply_to_ibg_ru,
        micro_practice_ru, mastery_checklist_ru, micro_blocks,
        estimated_minutes, sort_order, is_published
    ) VALUES (
        v_module_1, 'what-is-claude',
        'Что такое Claude и зачем он вам',
        'What is Claude?',
        'Claude — AI-ассистент Anthropic. За 15 минут разберётесь, что это даёт лично вам и где у него границы.',
        'Claude is Anthropic AI assistant. 15 minutes to understand what this gives you and where the limits are.',
        'https://www.anthropic.com/learn',
        300,
        'Welcome to Claude 101. Claude is an AI assistant by Anthropic. Unlike a search engine, Claude does not return links — it reads what you write, thinks about it, and produces a response. Think of Claude as a thoughtful colleague who needs context: give it background, be specific, and verify important claims. Claude has limits — no real-time internet by default, can make mistakes on recent events, does not remember between separate chats.',
        'Claude — это AI-ассистент Anthropic. В отличие от поисковика, Claude не возвращает ссылки — он читает то, что вы написали, думает над этим и формулирует ответ. Представляйте Claude как вдумчивого коллегу, которому нужен контекст: дайте предысторию, формулируйте конкретно, перепроверяйте важные факты. У Claude есть границы — нет реального времени по умолчанию, может ошибаться по свежим событиям, не помнит между разными чатами.',
        E'## Семейство моделей Claude\n\n- **Opus** — самая мощная, для сложных задач\n- **Sonnet** — баланс скорость/качество, повседневная работа\n- **Haiku** — быстрая и дешёвая, для простых задач\n\n## Чем Claude отличается\n\n- **От Google:** Google ищет существующие документы, Claude генерирует ответ\n- **От ChatGPT:** конкуренты в одной категории. Anthropic делает упор на честность, отказ от выдумывания фактов, работу с длинными документами.\n\n## Что Claude НЕ умеет\n\n1. Не имеет реального времени (нужно включать поиск)\n2. Не помнит ваши прошлые разговоры в новых чатах (но есть Projects)\n3. Может ошибаться в свежих фактах\n4. Не знает, что у вас в CRM/Notion/почте — пока вы не подключите коннектор',
        ARRAY[
            'Claude — соавтор, не оракул',
            'Три модели: Opus / Sonnet / Haiku',
            'Не знает свежих новостей и ваших данных, пока вы их не дадите',
            'Лучший подход — вдумчивый коллега, которому нужен контекст',
            'Не помнит между чатами (но есть Projects — урок 5)'
        ],
        E'## 🎯 Зачем это вам\n\nПрямо сейчас вы тратите часы на задачи, которые Claude закрывает за минуты: переводы клиентских сообщений, составление КП, ответы на типовые вопросы, написание скриптов и постов.\n\n**Через 15 минут вы поймёте:**\n- Подходит ли Claude конкретно для ваших задач\n- Где он реально поможет, а где соврёт и потратит ваше время\n- С чего начать первое использование сегодня же',
        E'## 🔄 Что у вас сейчас\n\n**Подумайте 2 минуты, прежде чем читать дальше:**\n\n1. Какие 2-3 задачи в вашей работе вы делаете каждую неделю одинаково?\n2. Сколько времени каждая отнимает?\n3. Использовали ли вы ChatGPT или другой AI для этих задач? Если да — почему перестали? Если нет — что мешало начать?\n\n*Запишите ответы. К ним вернёмся в конце урока.*',
        E'## 💡 Как применить в IBG\n\n**Для агента по продажам:** перевод клиентских сообщений с китайского/английского, генерация КП по проекту, follow-up клиентам, которые замолчали.\n\n**Для QC:** разбор звонка по рубрике LPMAMA, генерация feedback-сообщения агенту.\n\n**Для маркетинга:** скрипты Reels по фреймворку Hook→Retain→Reward, варианты постов под A/B тест, копирайт лендингов.\n\n**Для УК и аренды:** инструкции для гостей, ответы на повторяющиеся вопросы, отчёты собственникам.\n\n**Для HR:** скрининг резюме, JD, интервью-вопросы.\n\n**Для всех:** перевод, составление писем, summary встреч, превращение voice-memo в текст.',
        E'## 🛠 Микро-практика — 5 минут\n\n**Откройте [claude.ai](https://claude.ai). Зарегистрируйтесь (бесплатно) или войдите.**\n\nВ окно чата напишите:\n\n```\nЯ работаю в [ваша роль] в IBG Property — агентство недвижимости \nв Пхукете и Бали. Расскажи в 3 предложениях, как ты можешь \nсэкономить мне 5+ часов в неделю.\n```\n\n**Прочитайте ответ.** Заметили: Claude дал конкретный ответ под вашу роль, а не общий?\n\nТеперь напишите вторым сообщением:\n\n```\nОдна из этих задач — [возьмите свою задачу из блока выше]. \nПокажи на конкретном примере, как ты помог бы её сделать.\n```\n\n**Это и есть итеративный диалог** — главный навык работы с Claude.',
        ARRAY[
            'Я могу одним предложением объяснить, чем Claude отличается от Google',
            'Я знаю три модели Claude и для каких задач какая нужна',
            'Я понимаю, чего Claude не умеет (свежие новости, мои данные)',
            'Я выполнил микро-практику и получил конкретный ответ под мою роль',
            'У меня есть рабочий аккаунт claude.ai'
        ],
        '[{"title":"Зачем это вам","minutes":1,"type":"intro"},{"title":"Рефлексия текущего опыта","minutes":3,"type":"reflect"},{"title":"Видео + транскрипт","minutes":5,"type":"content"},{"title":"Применение в IBG","minutes":2,"type":"apply"},{"title":"Микро-практика в claude.ai","minutes":5,"type":"practice"},{"title":"Чек-лист самопроверки","minutes":1,"type":"review"}]'::jsonb,
        17, 1, TRUE
    );

END $$;

-- ============================================================================
-- ПРИМЕЧАНИЕ: Здесь демонстрируется только ПЕРВЫЙ урок в новой архитектуре.
-- Остальные 11 уроков идут по той же схеме — все 12 заполнены в файле
-- 003_seed_claude_101_lessons_v2_full.sql который содержит полный набор.
-- ============================================================================
