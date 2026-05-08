-- ============================================================================
-- REALTRUM Onboarding — Seed Data
-- Назначение: загрузка треков и всех 18 курсов Anthropic Academy
-- Запускать ПОСЛЕ 001_onboarding_schema.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ТРЕКИ (категории)
-- ----------------------------------------------------------------------------
INSERT INTO ob_tracks (slug, title_ru, title_en, description_ru, description_en, icon, sort_order, is_published) VALUES
('foundation', 'База: первые шаги с Claude', 'Foundation',
 'Старт для всех новичков. Что такое Claude, как с ним работать, как получать качественные результаты.',
 'Starting point for everyone. What Claude is, how to work with it, how to get quality results.',
 '🎯', 1, TRUE),

('developer', 'Разработка с Claude', 'Developer Track',
 'Claude Code, API, MCP, Skills, субагенты — всё для технических ролей.',
 'Claude Code, API, MCP, Skills, subagents — everything for technical roles.',
 '💻', 2, TRUE),

('ai-fluency', 'AI Fluency', 'AI Fluency',
 'Фреймворки эффективной работы с AI для разных аудиторий: специалисты, преподаватели, студенты, НКО.',
 'Frameworks for effective AI collaboration for different audiences: professionals, educators, students, nonprofits.',
 '🧠', 3, TRUE),

('enterprise', 'Корпоративное развёртывание', 'Enterprise',
 'Claude через AWS Bedrock, Google Vertex AI — для энтерпрайз-инфраструктуры.',
 'Claude via AWS Bedrock, Google Vertex AI — for enterprise infrastructure.',
 '🏢', 4, TRUE);

-- ----------------------------------------------------------------------------
-- КУРСЫ (18 штук)
-- ----------------------------------------------------------------------------

-- ===== TRACK 1: FOUNDATION =====
INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'claude-101',
    'Claude 101: основы',
    'Claude 101',
    'Как использовать Claude для повседневных рабочих задач, основные функции и ресурсы для дальнейшего обучения.',
    'Learn how to use Claude for everyday work tasks, understand core features, and explore resources for more advanced learning.',
    270, 'beginner', ARRAY['agent', 'manager', 'qc', 'developer'],
    'https://anthropic.skilljar.com/claude-101', 1, TRUE
FROM ob_tracks WHERE slug = 'foundation';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'ai-capabilities-and-limitations',
    'Возможности и ограничения AI',
    'AI Capabilities and Limitations',
    'Вводный курс о том, как работает AI: что он умеет, где ошибается, как калибровать ожидания.',
    'An introductory course about how AI works.',
    90, 'beginner', ARRAY['agent', 'manager', 'qc'],
    'https://anthropic.skilljar.com/ai-capabilities-and-limitations', 2, TRUE
FROM ob_tracks WHERE slug = 'foundation';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'introduction-to-claude-cowork',
    'Введение в Claude Cowork',
    'Introduction to Claude Cowork',
    'Совместная работа с Claude над реальными файлами и проектами: task loop, плагины, Skills, файловые workflow.',
    'Learn to work alongside Claude on your real files and projects. Covers Cowork task loop, plugins and skills, file and research workflows.',
    180, 'beginner', ARRAY['agent', 'manager'],
    'https://anthropic.skilljar.com/introduction-to-claude-cowork', 3, TRUE
FROM ob_tracks WHERE slug = 'foundation';

-- ===== TRACK 2: DEVELOPER =====
INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'claude-code-101',
    'Claude Code 101',
    'Claude Code 101',
    'Как эффективно использовать Claude Code в ежедневном рабочем процессе разработчика.',
    'Learn how to use Claude Code effectively in your daily development workflow.',
    150, 'beginner', ARRAY['developer'],
    'https://anthropic.skilljar.com/claude-code-101', 1, TRUE
FROM ob_tracks WHERE slug = 'developer';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'claude-code-in-action',
    'Claude Code in Action',
    'Claude Code in Action',
    'Интеграция Claude Code в реальные процессы разработки: продвинутые сценарии и интеграции.',
    'Integrate Claude Code into your development workflow.',
    240, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/claude-code-in-action', 2, TRUE
FROM ob_tracks WHERE slug = 'developer';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'building-with-claude-api',
    'Разработка с Claude API',
    'Building with the Claude API',
    'Полный спектр работы с моделями Anthropic через Claude API: от базовых вызовов до продакшн-паттернов.',
    'This comprehensive course covers the full spectrum of working with Anthropic models using the Claude API.',
    300, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/claude-with-the-anthropic-api', 3, TRUE
FROM ob_tracks WHERE slug = 'developer';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'introduction-to-mcp',
    'Введение в Model Context Protocol',
    'Introduction to Model Context Protocol',
    'Создание MCP-серверов и клиентов с нуля на Python. Три ключевых примитива: tools, resources, prompts.',
    'Learn to build Model Context Protocol servers and clients from scratch using Python. Master MCP three core primitives — tools, resources, and prompts.',
    240, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/introduction-to-model-context-protocol', 4, TRUE
FROM ob_tracks WHERE slug = 'developer';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'mcp-advanced-topics',
    'MCP: продвинутые темы',
    'Model Context Protocol: Advanced Topics',
    'Продвинутые паттерны MCP: sampling, notifications, доступ к файловой системе, транспорт для продакшна.',
    'Discover advanced Model Context Protocol implementation patterns including sampling, notifications, file system access, and transport mechanisms for production MCP server development.',
    180, 'advanced', ARRAY['developer'],
    'https://anthropic.skilljar.com/model-context-protocol-advanced-topics', 5, TRUE
FROM ob_tracks WHERE slug = 'developer';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'introduction-to-agent-skills',
    'Введение в Agent Skills',
    'Introduction to agent skills',
    'Как создавать, конфигурировать и распространять Skills в Claude Code — переиспользуемые markdown-инструкции.',
    'Learn how to build, configure, and share Skills in Claude Code — reusable markdown instructions that Claude automatically applies to the right tasks at the right time.',
    120, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/introduction-to-agent-skills', 6, TRUE
FROM ob_tracks WHERE slug = 'developer';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'introduction-to-subagents',
    'Введение в субагенты',
    'Introduction to subagents',
    'Как использовать и создавать sub-agents в Claude Code: управление контекстом, делегирование задач, специализированные workflow.',
    'Learn how to use and create sub-agents in Claude Code to manage context, delegate tasks, and build specialized workflows that keep your main conversation clean and focused.',
    120, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/introduction-to-subagents', 7, TRUE
FROM ob_tracks WHERE slug = 'developer';

-- ===== TRACK 3: AI FLUENCY =====
INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'ai-fluency-framework-foundations',
    'AI Fluency: фреймворк и основы',
    'AI Fluency: Framework & Foundations',
    'Как эффективно, этично и безопасно сотрудничать с AI-системами. Фундамент мышления, а не просто кнопки.',
    'Learn to collaborate with AI systems effectively, efficiently, ethically, and safely.',
    240, 'beginner', ARRAY['agent', 'manager', 'qc', 'developer'],
    'https://anthropic.skilljar.com/ai-fluency-framework-foundations', 1, TRUE
FROM ob_tracks WHERE slug = 'ai-fluency';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'ai-fluency-for-educators',
    'AI Fluency для преподавателей',
    'AI Fluency for educators',
    'Курс для преподавателей и образовательных лидеров: как применять AI Fluency в обучении.',
    'This course empowers faculty, instructional designers, and educational leaders to apply AI Fluency into their own teaching practice and institutional strategy.',
    180, 'beginner', ARRAY['manager'],
    'https://anthropic.skilljar.com/ai-fluency-for-educators', 2, TRUE
FROM ob_tracks WHERE slug = 'ai-fluency';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'ai-fluency-for-students',
    'AI Fluency для студентов',
    'AI Fluency for students',
    'Развитие AI Fluency у студентов: обучение, карьера, академический успех через ответственную работу с AI.',
    'This course empowers students to develop AI Fluency skills that enhance learning, career planning, and academic success through responsible AI collaboration.',
    180, 'beginner', ARRAY['agent'],
    'https://anthropic.skilljar.com/ai-fluency-for-students', 3, TRUE
FROM ob_tracks WHERE slug = 'ai-fluency';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'teaching-ai-fluency',
    'Преподавание AI Fluency',
    'Teaching AI Fluency',
    'Как преподавать и оценивать AI Fluency в очном формате.',
    'This course empowers academic faculty, instructional designers, and others to teach and assess AI Fluency in instructor-led settings.',
    180, 'intermediate', ARRAY['manager'],
    'https://anthropic.skilljar.com/teaching-ai-fluency', 4, TRUE
FROM ob_tracks WHERE slug = 'ai-fluency';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'ai-fluency-for-nonprofits',
    'AI Fluency для НКО',
    'AI Fluency for nonprofits',
    'Курс для специалистов НКО: AI Fluency для увеличения impact с сохранением миссии.',
    'This course empowers nonprofit professionals to develop AI fluency in order to increase organizational impact and efficiency while staying true to their mission and values.',
    180, 'beginner', ARRAY['manager'],
    'https://anthropic.skilljar.com/ai-fluency-for-nonprofits', 5, TRUE
FROM ob_tracks WHERE slug = 'ai-fluency';

-- ===== TRACK 4: ENTERPRISE =====
INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'claude-with-amazon-bedrock',
    'Claude через Amazon Bedrock',
    'Claude with Amazon Bedrock',
    'Развёртывание Claude через AWS Bedrock — программа аккредитации, первоначально созданная для AWS.',
    'As part of an accreditation program created for AWS, Anthropic launched a first-of-its-kind training for AWS employees.',
    240, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/claude-in-amazon-bedrock', 1, TRUE
FROM ob_tracks WHERE slug = 'enterprise';

INSERT INTO ob_courses (track_id, slug, title_ru, title_en, description_ru, description_en,
                        duration_minutes, difficulty, target_role, source_url, sort_order, is_published)
SELECT id, 'claude-with-google-vertex',
    'Claude через Google Vertex AI',
    'Claude with Google Cloud Vertex AI',
    'Полный спектр работы с моделями Anthropic через Google Cloud Vertex AI.',
    'This comprehensive course covers the full spectrum of working with Anthropic models through Google Cloud Vertex AI.',
    240, 'intermediate', ARRAY['developer'],
    'https://anthropic.skilljar.com/claude-with-google-vertex', 2, TRUE
FROM ob_tracks WHERE slug = 'enterprise';

-- ============================================================================
-- ГОТОВО. 18 курсов в 4 треках загружены.
-- Следующий шаг — 003_seed_claude_101_lessons.sql (эталонный курс)
-- ============================================================================
