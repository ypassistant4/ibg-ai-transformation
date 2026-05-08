-- ============================================================================
-- Migration 007: Invites + helper functions
-- Запускать ПОСЛЕ всех 001-006 миграций
-- ============================================================================

-- Таблица invites для регистрации сотрудников
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
CREATE INDEX idx_invites_used ON invites(used_at) WHERE used_at IS NULL;

ALTER TABLE invites ENABLE ROW LEVEL SECURITY;

-- Только admin может создавать и видеть все invites
CREATE POLICY "Admins manage invites" ON invites
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE id = auth.uid()
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Любой может проверить свой invite по токену (для регистрации)
CREATE POLICY "Anyone can read invite by token" ON invites
    FOR SELECT USING (TRUE);

-- ============================================================================
-- Функция увеличения времени на уроке (для tracking heartbeat)
-- ============================================================================
CREATE OR REPLACE FUNCTION increment_lesson_time(
    p_user_id UUID,
    p_lesson_id UUID,
    p_seconds INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ob_user_progress
    SET time_spent_seconds = COALESCE(time_spent_seconds, 0) + p_seconds,
        updated_at = NOW()
    WHERE user_id = p_user_id AND lesson_id = p_lesson_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VIEW: текущий незавершённый урок пользователя (для кнопки "Продолжить")
-- ============================================================================
CREATE OR REPLACE VIEW v_user_current_lesson AS
SELECT DISTINCT ON (p.user_id)
    p.user_id,
    l.id AS lesson_id,
    l.slug AS lesson_slug,
    m.course_id,
    c.slug AS course_slug,
    l.title_ru AS lesson_title,
    c.title_ru AS course_title,
    p.status,
    p.started_at,
    p.updated_at
FROM ob_user_progress p
JOIN ob_lessons l ON l.id = p.lesson_id
JOIN ob_modules m ON m.id = l.module_id
JOIN ob_courses c ON c.id = m.course_id
WHERE p.status IN ('in_progress', 'not_started')
ORDER BY p.user_id, p.updated_at DESC NULLS LAST;

-- ============================================================================
-- ПОСЛЕ ПРИМЕНЕНИЯ МИГРАЦИИ
-- ============================================================================
-- Выполнить вручную для назначения первого admin:
--
-- UPDATE auth.users
-- SET raw_user_meta_data = jsonb_set(
--     COALESCE(raw_user_meta_data, '{}'),
--     '{role}',
--     '"admin"'
-- )
-- WHERE email = 'твой-email@example.com';
--
-- ПРОВЕРКА:
-- SELECT id, email, raw_user_meta_data FROM auth.users WHERE email = 'твой-email@example.com';
-- ============================================================================
