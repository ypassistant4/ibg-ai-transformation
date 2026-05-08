-- ============================================================================
-- REALTRUM Onboarding — Schema v2 (расширение)
-- Добавляет: роли IBG, квалификационный опрос, персональные программы,
--            IBG-инжекции (контекст и практика под роль)
-- Запускать ПОСЛЕ 001_onboarding_schema.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. РОЛИ IBG (каталог должностей)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title_ru TEXT NOT NULL,
    department TEXT NOT NULL,           -- 'sales', 'rental', 'qc', 'marketing', и т.д.
    description_ru TEXT,
    is_management BOOLEAN DEFAULT FALSE,
    common_tools TEXT[],                -- ['amocrm', 'whatsapp', 'notion', 'wazzup']
    typical_pain_points TEXT[],         -- наиболее частые боли роли (для подсказок в опросе)
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ob_roles_dept ON ob_roles(department);

-- ----------------------------------------------------------------------------
-- 2. УРОВНИ AI-ОПЫТА
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_ai_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title_ru TEXT NOT NULL,
    description_ru TEXT,
    sort_order INTEGER NOT NULL          -- 0 = новичок, 2 = продвинутый
);

-- ----------------------------------------------------------------------------
-- 3. ШАБЛОНЫ ДЕФОЛТНЫХ ПРОГРАММ (роль × уровень → набор курсов)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_program_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID REFERENCES ob_roles(id) ON DELETE CASCADE NOT NULL,
    ai_level_id UUID REFERENCES ob_ai_levels(id) ON DELETE CASCADE NOT NULL,
    title_ru TEXT NOT NULL,
    description_ru TEXT,
    estimated_total_hours INTEGER,
    UNIQUE(role_id, ai_level_id)
);

-- Курсы внутри шаблона программы (с порядком и приоритетом)
CREATE TABLE IF NOT EXISTS ob_program_template_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID REFERENCES ob_program_templates(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES ob_courses(id) ON DELETE CASCADE NOT NULL,
    sort_order INTEGER NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,    -- TRUE = обязательно, FALSE = рекомендовано
    rationale_ru TEXT,                   -- почему этот курс для этой роли
    UNIQUE(template_id, course_id)
);

-- ----------------------------------------------------------------------------
-- 4. КВАЛИФИКАЦИОННЫЙ ОПРОС — ОТВЕТЫ ПОЛЬЗОВАТЕЛЯ
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_user_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

    -- Базовые поля опроса
    role_id UUID REFERENCES ob_roles(id),
    ai_level_id UUID REFERENCES ob_ai_levels(id),

    -- Свободные поля
    full_name TEXT,
    job_description_ru TEXT,             -- "чем конкретно занимается" (свободный текст)

    -- Боли (3-5 задач, отнимающих больше всего времени)
    pain_points JSONB,                   -- [{task: "...", hours_per_week: 10, frequency: "daily"}]

    -- Инструменты, с которыми работает
    tools_used TEXT[],

    -- Дополнительные предпочтения
    preferred_language TEXT DEFAULT 'ru' CHECK (preferred_language IN ('ru', 'en', 'both')),
    weekly_time_budget_hours INTEGER,    -- сколько готов выделить
    learning_goal TEXT,                  -- 'general_boost', 'specific_project', 'build_automation'
    has_claude_subscription TEXT,        -- 'free', 'pro', 'team', 'unknown'

    -- Метаданные
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX idx_ob_assessments_user ON ob_user_assessments(user_id);
CREATE INDEX idx_ob_assessments_role ON ob_user_assessments(role_id);

-- ----------------------------------------------------------------------------
-- 5. ПЕРСОНАЛЬНАЯ ПРОГРАММА ОБУЧЕНИЯ ПОЛЬЗОВАТЕЛЯ
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ob_user_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    assessment_id UUID REFERENCES ob_user_assessments(id) ON DELETE CASCADE NOT NULL,
    template_id UUID REFERENCES ob_program_templates(id),  -- nullable если кастом

    title_ru TEXT NOT NULL,
    estimated_hours INTEGER,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    -- IBG-инжекции для этого пользователя (рендерятся в уроки)
    ibg_context_overlay JSONB,           -- {"role_examples": [...], "tool_examples": [...]}

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Курсы внутри персональной программы (порядок может отличаться от шаблона)
CREATE TABLE IF NOT EXISTS ob_user_program_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id UUID REFERENCES ob_user_programs(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES ob_courses(id) ON DELETE CASCADE NOT NULL,
    sort_order INTEGER NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'skipped')),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    UNIQUE(program_id, course_id)
);

CREATE INDEX idx_ob_program_courses_program ON ob_user_program_courses(program_id);

-- ----------------------------------------------------------------------------
-- 6. IBG-ИНЖЕКЦИИ В УРОКИ (контекст под роль/боль)
-- ----------------------------------------------------------------------------
-- Дополнительные блоки, которые рендерятся в существующие уроки в зависимости
-- от роли пользователя. НЕ заменяют контент урока, а ДОПОЛНЯЮТ.
CREATE TABLE IF NOT EXISTS ob_lesson_role_overlays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID REFERENCES ob_lessons(id) ON DELETE CASCADE NOT NULL,
    role_id UUID REFERENCES ob_roles(id) ON DELETE CASCADE NOT NULL,

    -- Что добавляется в урок для этой роли
    extra_examples_ru TEXT,              -- "## Применение для агента по аренде..."
    role_specific_tips_ru TEXT,
    pain_point_addresses JSONB,          -- какие из стандартных болей этой роли решает

    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(lesson_id, role_id)
);

CREATE INDEX idx_ob_overlays_lesson ON ob_lesson_role_overlays(lesson_id);
CREATE INDEX idx_ob_overlays_role ON ob_lesson_role_overlays(role_id);

-- ----------------------------------------------------------------------------
-- 7. ВАРИАНТЫ ПРАКТИЧЕСКИХ ЗАДАНИЙ ПОД РОЛЬ
-- ----------------------------------------------------------------------------
-- Базовое упражнение в ob_exercises остаётся универсальным.
-- Здесь — варианты ТОЙ ЖЕ механики, но с темой/контекстом под роль.
CREATE TABLE IF NOT EXISTS ob_exercise_role_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES ob_exercises(id) ON DELETE CASCADE NOT NULL,
    role_id UUID REFERENCES ob_roles(id) ON DELETE CASCADE NOT NULL,

    -- Адаптированные поля
    instructions_override_ru TEXT,       -- если переопределяем формулировку
    context_override_ru TEXT,            -- IBG-контекст для этой роли
    example_solution_override_ru TEXT,
    suggested_pain_points TEXT[],        -- какие боли роли можно адресовать в практике

    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(exercise_id, role_id)
);

CREATE INDEX idx_ob_exercise_variants_ex ON ob_exercise_role_variants(exercise_id);
CREATE INDEX idx_ob_exercise_variants_role ON ob_exercise_role_variants(role_id);

-- ----------------------------------------------------------------------------
-- RLS
-- ----------------------------------------------------------------------------
ALTER TABLE ob_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_ai_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_program_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_program_template_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_user_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_user_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_user_program_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_lesson_role_overlays ENABLE ROW LEVEL SECURITY;
ALTER TABLE ob_exercise_role_variants ENABLE ROW LEVEL SECURITY;

-- Каталоги — читают все
CREATE POLICY "Anyone reads roles" ON ob_roles FOR SELECT USING (TRUE);
CREATE POLICY "Anyone reads ai_levels" ON ob_ai_levels FOR SELECT USING (TRUE);
CREATE POLICY "Anyone reads templates" ON ob_program_templates FOR SELECT USING (TRUE);
CREATE POLICY "Anyone reads template_courses" ON ob_program_template_courses FOR SELECT USING (TRUE);
CREATE POLICY "Anyone reads overlays" ON ob_lesson_role_overlays FOR SELECT USING (TRUE);
CREATE POLICY "Anyone reads exercise variants" ON ob_exercise_role_variants FOR SELECT USING (TRUE);

-- Опрос и программа — только сам пользователь
CREATE POLICY "Users see own assessment" ON ob_user_assessments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users see own program" ON ob_user_programs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users see own program courses" ON ob_user_program_courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM ob_user_programs p WHERE p.id = program_id AND p.user_id = auth.uid())
    );

-- ----------------------------------------------------------------------------
-- ФУНКЦИЯ: сгенерировать программу по результатам опроса
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_generate_user_program(p_user_id UUID)
RETURNS UUID AS $$
DECLARE
    v_assessment ob_user_assessments%ROWTYPE;
    v_template_id UUID;
    v_program_id UUID;
    v_template_course RECORD;
BEGIN
    -- Получаем результаты опроса
    SELECT * INTO v_assessment FROM ob_user_assessments WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Assessment not found for user %', p_user_id;
    END IF;

    -- Находим подходящий шаблон
    SELECT id INTO v_template_id
    FROM ob_program_templates
    WHERE role_id = v_assessment.role_id AND ai_level_id = v_assessment.ai_level_id;

    IF v_template_id IS NULL THEN
        RAISE EXCEPTION 'No template found for role/level combination';
    END IF;

    -- Создаём (или обновляем) персональную программу
    INSERT INTO ob_user_programs (user_id, assessment_id, template_id, title_ru, estimated_hours)
    SELECT
        p_user_id,
        v_assessment.id,
        v_template_id,
        t.title_ru,
        t.estimated_total_hours
    FROM ob_program_templates t WHERE t.id = v_template_id
    ON CONFLICT (user_id) DO UPDATE
        SET assessment_id = EXCLUDED.assessment_id,
            template_id = EXCLUDED.template_id,
            title_ru = EXCLUDED.title_ru,
            estimated_hours = EXCLUDED.estimated_hours,
            updated_at = NOW()
    RETURNING id INTO v_program_id;

    -- Очищаем старые курсы программы (если перегенерация)
    DELETE FROM ob_user_program_courses WHERE program_id = v_program_id;

    -- Копируем курсы из шаблона
    FOR v_template_course IN
        SELECT course_id, sort_order, is_required
        FROM ob_program_template_courses
        WHERE template_id = v_template_id
        ORDER BY sort_order
    LOOP
        INSERT INTO ob_user_program_courses (program_id, course_id, sort_order, is_required)
        VALUES (v_program_id, v_template_course.course_id, v_template_course.sort_order, v_template_course.is_required);
    END LOOP;

    RETURN v_program_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ГОТОВО. Schema v2 расширена.
-- Следующий шаг — 005_seed_roles_levels_templates.sql
-- ============================================================================
