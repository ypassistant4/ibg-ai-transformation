-- ============================================================================
-- Migration 008: добавляем 18-й курс — AI Fluency for Small Businesses
--
-- Контекст: миграция 002 семитила 17 курсов (хотя её собственный комментарий
-- утверждает "18 курсов"). На academy.anthropic.com их фактически 18 —
-- недостающий курс из трека AI Fluency.
--
-- Идемпотентность: ON CONFLICT (slug) DO NOTHING. Запускать можно повторно.
-- Запускать ПОСЛЕ всех 001–007 миграций.
-- ============================================================================

INSERT INTO ob_courses (
    track_id, slug, title_ru, title_en, description_ru, description_en,
    duration_minutes, difficulty, target_role, source_url, sort_order, is_published
)
SELECT
    id,
    'ai-fluency-for-small-businesses',
    'AI Fluency для малого бизнеса',
    'AI Fluency for Small Businesses',
    'Курс для владельцев и команд малого бизнеса: применение AI Fluency для роста выручки, экономии времени и оптимизации операций.',
    'This course empowers small business owners and teams to develop AI fluency for growth, time savings, and operational efficiency.',
    180,
    'beginner',
    ARRAY['agent', 'manager'],
    'https://anthropic.skilljar.com/ai-fluency-for-small-businesses',
    6,
    TRUE
FROM ob_tracks
WHERE slug = 'ai-fluency'
ON CONFLICT (slug) DO NOTHING;

-- ============================================================================
-- ПРОВЕРКА после запуска:
--
-- SELECT count(*) FROM ob_courses;
-- → должно быть 18
--
-- SELECT slug, title_ru FROM ob_courses
-- WHERE track_id = (SELECT id FROM ob_tracks WHERE slug = 'ai-fluency')
-- ORDER BY sort_order;
-- → 6 курсов в треке AI Fluency, новый последний по sort_order
-- ============================================================================
