-- ============================================================================
-- REALTRUM Onboarding Schema
-- Назначение: хранение курсов Anthropic Academy на русском языке
--             с EN/RU транскриптами и практическими заданиями
-- ============================================================================
-- Принципы:
-- 1. Все таблицы с префиксом ob_ (onboarding) для изоляции от core LMS
-- 2. RLS включён везде (single source of truth для прав доступа)
-- 3. Multi-language ready: EN оригинал + RU перевод в одной строке
-- 4. Прогресс отслеживается per-user, per-lesson
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ТРЕКИ (категории курсов: Базовый, Разработчик, AI Fluency, Корпоративный)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_tracks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title_ru TEXT NOT NULL,
    title_en TEXT NOT NULL,
    description_ru TEXT,
    description_en TEXT,
    icon TEXT,                          -- emoji или иконка lucide
    sort_order INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ob_tracks_slug ON ob_tracks(slug);
CREATE INDEX idx_ob_tracks_published ON ob_tracks(is_published) WHERE is_published = TRUE;

-- ----------------------------------------------------------------------------
-- 2. КУРСЫ (Claude 101, Claude Code 101, AI Fluency и т.д.)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    track_id UUID REFERENCES ob_tracks(id) ON DELETE CASCADE,
    slug TEXT UNIQUE NOT NULL,
    title_ru TEXT NOT NULL,
    title_en TEXT NOT NULL,
    description_ru TEXT,
    description_en TEXT,
    duration_minutes INTEGER,           -- ожидаемое время прохождения
    difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    target_role TEXT[],                 -- ['agent', 'developer', 'manager', 'qc']
    cover_image_url TEXT,
    source_url TEXT,                    -- ссылка на оригинал Anthropic Academy
    sort_order INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ob_courses_track ON ob_courses(track_id);
CREATE INDEX idx_ob_courses_slug ON ob_courses(slug);
CREATE INDEX idx_ob_courses_role ON ob_courses USING GIN(target_role);

-- ----------------------------------------------------------------------------
-- 3. МОДУЛИ (логические разделы внутри курса)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES ob_courses(id) ON DELETE CASCADE NOT NULL,
    slug TEXT NOT NULL,
    title_ru TEXT NOT NULL,
    title_en TEXT NOT NULL,
    description_ru TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(course_id, slug)
);

CREATE INDEX idx_ob_modules_course ON ob_modules(course_id);

-- ----------------------------------------------------------------------------
-- 4. УРОКИ (атомарная единица контента: видео + транскрипт + теория)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES ob_modules(id) ON DELETE CASCADE NOT NULL,
    slug TEXT NOT NULL,
    title_ru TEXT NOT NULL,
    title_en TEXT NOT NULL,

    -- Краткое содержание
    summary_ru TEXT,                    -- что узнаешь за 1 предложение
    summary_en TEXT,

    -- Видео
    video_url TEXT,                     -- ссылка на оригинал (YouTube/Skilljar)
    video_duration_seconds INTEGER,

    -- Контент урока (markdown)
    transcript_en TEXT,                 -- оригинальный транскрипт
    transcript_ru TEXT,                 -- перевод транскрипта
    theory_ru TEXT,                     -- теоретическая часть на русском (расширенная)
    key_takeaways_ru TEXT[],            -- 3-5 ключевых выводов

    -- Метаданные
    estimated_minutes INTEGER DEFAULT 15,
    sort_order INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(module_id, slug)
);

CREATE INDEX idx_ob_lessons_module ON ob_lessons(module_id);
CREATE INDEX idx_ob_lessons_slug ON ob_lessons(slug);

-- ----------------------------------------------------------------------------
-- 5. ПРАКТИЧЕСКИЕ ЗАДАНИЯ (1+ на урок)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID REFERENCES ob_lessons(id) ON DELETE CASCADE NOT NULL,
    slug TEXT NOT NULL,
    title_ru TEXT NOT NULL,

    -- Тип задания
    exercise_type TEXT CHECK (exercise_type IN (
        'practical',        -- открытое практическое задание
        'quiz',             -- тест с вариантами
        'reflection',       -- рефлексия (свободный текст)
        'checklist'         -- чеклист действий
    )),

    -- Контент задания
    instructions_ru TEXT NOT NULL,      -- что нужно сделать
    context_ru TEXT,                    -- контекст IBG (ситуация из real estate)
    success_criteria_ru TEXT[],         -- по каким критериям проверять
    example_solution_ru TEXT,           -- пример хорошего решения
    common_mistakes_ru TEXT[],          -- частые ошибки

    -- Для quiz-типа
    quiz_options JSONB,                 -- [{text, is_correct, explanation}]

    -- Метаданные
    estimated_minutes INTEGER DEFAULT 10,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(lesson_id, slug)
);

CREATE INDEX idx_ob_exercises_lesson ON ob_exercises(lesson_id);

-- ----------------------------------------------------------------------------
-- 6. ПРОГРЕСС ПОЛЬЗОВАТЕЛЯ (одна строка на урок на пользователя)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES ob_lessons(id) ON DELETE CASCADE NOT NULL,

    status TEXT CHECK (status IN ('not_started', 'in_progress', 'completed')) DEFAULT 'not_started',
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    time_spent_seconds INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_ob_progress_user ON ob_user_progress(user_id);
CREATE INDEX idx_ob_progress_status ON ob_user_progress(user_id, status);

-- ----------------------------------------------------------------------------
-- 7. ОТВЕТЫ НА ПРАКТИЧЕСКИЕ ЗАДАНИЯ
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_exercise_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    exercise_id UUID REFERENCES ob_exercises(id) ON DELETE CASCADE NOT NULL,

    -- Содержимое ответа
    answer_text TEXT,                   -- для practical/reflection
    quiz_selected JSONB,                -- для quiz: [{option_index, is_correct}]
    checklist_state JSONB,              -- для checklist: {item_slug: bool}

    -- Оценка (если ручная проверка нужна)
    is_correct BOOLEAN,                 -- для quiz — авто
    reviewer_id UUID REFERENCES auth.users(id),
    reviewer_feedback TEXT,
    reviewed_at TIMESTAMPTZ,

    -- AI-обратная связь (Claude API оценивает свободные ответы)
    ai_feedback TEXT,
    ai_score INTEGER CHECK (ai_score >= 0 AND ai_score <= 100),

    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ob_submissions_user ON ob_exercise_submissions(user_id);
CREATE INDEX idx_ob_submissions_exercise ON ob_exercise_submissions(exercise_id);

-- ----------------------------------------------------------------------------
-- 8. СЕРТИФИКАТЫ (выдаются после завершения курса)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES ob_courses(id) ON DELETE CASCADE NOT NULL,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    certificate_number TEXT UNIQUE NOT NULL,
    pdf_url TEXT,
    UNIQUE(user_id, course_id)
);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE ob_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_exercise_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_certificates ENABLE ROW LEVEL SECURITY;

-- Контент видим всем авторизованным пользователям (только опубликованный)
CREATE POLICY "Anyone can read published tracks"
    ON ob_tracks FOR SELECT
    USING (is_published = TRUE OR auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can read published courses"
    ON ob_courses FOR SELECT
    USING (is_published = TRUE OR auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can read modules of accessible courses"
    ON ob_modules FOR SELECT USING (TRUE);

CREATE POLICY "Anyone can read published lessons"
    ON ob_lessons FOR SELECT
    USING (is_published = TRUE OR auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can read exercises"
    ON ob_exercises FOR SELECT USING (TRUE);

-- Прогресс видит только сам пользователь
CREATE POLICY "Users see own progress"
    ON ob_user_progress FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users see own submissions"
    ON ob_exercise_submissions FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users see own certificates"
    ON ob_certificates FOR SELECT
    USING (auth.uid() = user_id);

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ VIEWS
-- ============================================================================

-- Прогресс по курсу для пользователя
CREATE OR REPLACE VIEW v_ob_course_progress AS
SELECT
    p.user_id,
    c.id AS course_id,
    c.title_ru AS course_title,
    COUNT(DISTINCT l.id) AS total_lessons,
    COUNT(DISTINCT CASE WHEN p.status = 'completed' THEN l.id END) AS completed_lessons,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN p.status = 'completed' THEN l.id END) /
        NULLIF(COUNT(DISTINCT l.id), 0),
        1
    ) AS progress_percent
FROM ob_courses c
JOIN ob_modules m ON m.course_id = c.id
JOIN ob_lessons l ON l.module_id = m.id
LEFT JOIN ob_user_progress p ON p.lesson_id = l.id
WHERE l.is_published = TRUE
GROUP BY p.user_id, c.id, c.title_ru;

-- ============================================================================
-- TRIGGER: автообновление updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_ob_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ob_tracks_updated_at BEFORE UPDATE ON ob_tracks
    FOR EACH ROW EXECUTE FUNCTION update_ob_updated_at();
CREATE TRIGGER trg_ob_courses_updated_at BEFORE UPDATE ON ob_courses
    FOR EACH ROW EXECUTE FUNCTION update_ob_updated_at();
CREATE TRIGGER trg_ob_lessons_updated_at BEFORE UPDATE ON ob_lessons
    FOR EACH ROW EXECUTE FUNCTION update_ob_updated_at();
CREATE TRIGGER trg_ob_progress_updated_at BEFORE UPDATE ON ob_user_progress
    FOR EACH ROW EXECUTE FUNCTION update_ob_updated_at();

-- ============================================================================
-- ГОТОВО. Следующий шаг — запустить 002_seed_tracks_and_courses.sql
-- ============================================================================
