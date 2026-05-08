-- ============================================================================
-- REALTRUM Onboarding — Seed: Roles, AI Levels, Program Templates
-- 11 ролей IBG × 3 уровня AI = 33 шаблона программ
-- Запускать ПОСЛЕ 004_schema_v2_assessment.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- УРОВНИ AI-ОПЫТА (3 уровня — реальность IBG: почти никто не кодил)
-- ----------------------------------------------------------------------------
INSERT INTO ob_ai_levels (slug, title_ru, description_ru, sort_order) VALUES
('newcomer',
 'Новичок: никогда не использовал AI',
 'Не открывал ChatGPT, Claude или другие AI. Слышал, что есть такая штука. Может относиться скептически или, наоборот, с любопытством. Главная задача — снять страх и показать первый рабочий результат за 30 минут.',
 0),

('explorer',
 'Изучающий: иногда задаю вопросы',
 'Пользовался ChatGPT или Claude время от времени для бытовых задач или простых вопросов. Не использует системно. Не знает про Projects, Skills, коннекторы. Пишет короткие prompts, не в курсе про итерации.',
 1),

('practitioner',
 'Практик: использую AI регулярно',
 'Активно работает с AI каждый день или почти каждый день. Знает про итеративный диалог. Возможно, использовал Custom GPTs или Projects. Готов к продвинутым темам: автоматизации, агенты, MCP.',
 2);

-- ----------------------------------------------------------------------------
-- РОЛИ IBG (11 штук)
-- ----------------------------------------------------------------------------
INSERT INTO ob_roles (slug, title_ru, department, description_ru, is_management, common_tools, typical_pain_points, sort_order) VALUES

-- ===== ОТДЕЛ ПРОДАЖ =====
('sales-agent',
 'Агент по недвижимости',
 'sales',
 'Продаёт новостройки иностранным инвесторам. Работает с теплыми лидами из CRM, ведёт WhatsApp-переписку, проводит показы.',
 FALSE,
 ARRAY['amocrm', 'whatsapp', 'wazzup', 'telegram', 'google_drive'],
 ARRAY[
   'Перевод сообщений клиентов с разных языков',
   'Составление КП по проектам под конкретного клиента',
   'Ответы на типовые вопросы про юниты и условия',
   'Follow-up клиентам, замолчавшим на 3+ дня',
   'Подготовка к показам и встречам'
 ],
 1),

-- ===== ОТДЕЛ АРЕНДЫ =====
('rental-agent',
 'Агент по аренде',
 'rental',
 'Сдаёт квартиры в долгосрочную и краткосрочную аренду. Работает с собственниками и арендаторами, координирует заселения.',
 FALSE,
 ARRAY['amocrm', 'whatsapp', 'airbnb', 'booking', 'google_calendar'],
 ARRAY[
   'Ответы арендаторам на повторяющиеся вопросы (правила, гайды по району)',
   'Координация заселений и выселений',
   'Составление договоров аренды',
   'Перевод инструкций и правил для гостей',
   'Решение конфликтов между собственником и арендатором'
 ],
 2),

('rental-head',
 'Руководитель отдела аренды',
 'rental',
 'Управляет командой агентов по аренде, отвечает за общие KPI, разбирает сложные кейсы, развивает процессы.',
 TRUE,
 ARRAY['amocrm', 'notion', 'google_sheets', 'slack', 'whatsapp'],
 ARRAY[
   'Подготовка отчётов руководству по результатам отдела',
   'Анализ работы команды (выявление проблемных кейсов)',
   'Составление SOP и обучающих материалов',
   'Подготовка к 1:1 с агентами',
   'Стратегические заметки и предложения'
 ],
 3),

-- ===== УПРАВЛЯЮЩАЯ КОМПАНИЯ =====
('property-management',
 'Сотрудник управляющей компании',
 'property_management',
 'Обслуживает объекты в управлении: техническое содержание, координация ремонтов, общение с собственниками и арендаторами.',
 FALSE,
 ARRAY['amocrm', 'whatsapp', 'notion', 'google_drive'],
 ARRAY[
   'Документирование инцидентов и работ по объектам',
   'Согласование работ с собственниками',
   'Составление отчётов собственникам о состоянии объектов',
   'Координация подрядчиков',
   'Перевод технической переписки'
 ],
 4),

('owner-relations-head',
 'Руководитель по собственникам и OTA-площадкам',
 'property_management',
 'Управляет отношениями с собственниками квартир, листингами на Airbnb/Booking/других OTA, оптимизирует загрузку и доходность.',
 TRUE,
 ARRAY['airbnb', 'booking', 'amocrm', 'google_sheets', 'notion'],
 ARRAY[
   'Оптимизация описаний и фото листингов на OTA',
   'Анализ загрузки и доходности по объектам',
   'Подготовка отчётов собственникам',
   'Стратегические переговоры с собственниками',
   'Конкурентный анализ OTA-листингов'
 ],
 5),

-- ===== MAIN DANCE TEAM (главная команда менеджеров) =====
('main-dance-team-head',
 'Руководитель Main Dance Team',
 'main_dance',
 'Управляет ключевой командой менеджеров. Отвечает за стратегические инициативы, развитие команды, кросс-функциональные проекты.',
 TRUE,
 ARRAY['notion', 'google_workspace', 'slack', 'amocrm'],
 ARRAY[
   'Стратегические презентации руководству и инвесторам',
   'Координация межотдельных проектов',
   'Подготовка к встречам с founder',
   'Анализ результатов команды и формулировка инсайтов',
   'Развитие команды (1:1, фидбек, рост)'
 ],
 6),

-- ===== МАРКЕТИНГ =====
('marketing',
 'Маркетинг / Контент',
 'marketing',
 'Создаёт контент для соцсетей, ведёт рекламные кампании, разрабатывает лендинги, делает email-рассылки.',
 FALSE,
 ARRAY['notion', 'instagram', 'telegram', 'threads', 'meta_ads', 'google_ads'],
 ARRAY[
   'Производство контента для соцсетей (Reels, посты, stories)',
   'Написание копирайтинга для рекламы и лендингов',
   'A/B тестирование креативов и текстов',
   'Анализ эффективности кампаний',
   'Перевод и локализация контента'
 ],
 7),

-- ===== HR / НАЙМ =====
('hr',
 'Отдел найма / HR',
 'hr',
 'Закрывает вакансии (агенты, менеджеры), проводит первичные интервью, ведёт кадровую документацию, занимается онбордингом.',
 FALSE,
 ARRAY['notion', 'google_sheets', 'linkedin', 'telegram', 'email'],
 ARRAY[
   'Скрининг резюме и составление шорт-листов',
   'Подготовка вопросов к интервью',
   'Составление JD под новые позиции',
   'Подготовка офферов и онбординг-планов',
   'Поиск кандидатов через холодные каналы'
 ],
 8),

-- ===== КОНТРОЛЬ КАЧЕСТВА =====
('qc',
 'Контроль качества (QC)',
 'qc',
 'Слушает звонки агентов, оценивает по рубрикам (LPMAMA), даёт фидбек, формирует отчёты по качеству работы.',
 FALSE,
 ARRAY['amocrm', 'wazzup', 'notion', 'google_sheets'],
 ARRAY[
   'Прослушивание и оценка звонков по рубрике',
   'Составление детального фидбека агентам',
   'Транскрибирование и анализ звонков',
   'Поиск паттернов ошибок в работе агентов',
   'Подготовка обучающих материалов на основе кейсов'
 ],
 9),

-- ===== КОЛЛ-ЦЕНТР =====
('call-center',
 'Колл-центр',
 'call_center',
 'Обрабатывает входящие лиды, делает первичную квалификацию, передаёт горячих клиентов агентам, ведёт холодные обзвоны.',
 FALSE,
 ARRAY['amocrm', 'wazzup', 'whatsapp', 'phone'],
 ARRAY[
   'Скрипты первичных контактов под разные источники лидов',
   'Квалификация по 5-7 параметрам за короткий разговор',
   'Ответы на типовые вопросы перед передачей агенту',
   'Реанимация старых лидов из базы',
   'Заполнение полей в CRM после звонка'
 ],
 10),

-- ===== INNOVATIONS / РАЗРАБОТКА =====
('innovations',
 'Innovations / Разработка',
 'innovations',
 'Строит AI-системы, автоматизации, внутренние инструменты. Работает с n8n, Supabase, Claude API. Это ты, Юра, и потенциальные новые члены отдела.',
 FALSE,
 ARRAY['claude_code', 'n8n', 'supabase', 'github', 'vercel', 'notion'],
 ARRAY[
   'Проектирование архитектуры AI-систем под бизнес-задачи',
   'Разработка n8n workflow и интеграций',
   'Дебаг и оптимизация существующих систем',
   'Спецификации для бизнеса (как IBG_AI_QC_Spec)',
   'Research новых технологий и инструментов'
 ],
 11);

-- ============================================================================
-- ШАБЛОНЫ ПРОГРАММ
-- ============================================================================
-- Логика маршрутизации:
--
-- УРОВЕНЬ NEWCOMER (никогда не использовал AI):
--   Все роли получают: Claude 101 → AI Capabilities and Limitations →
--                      AI Fluency Foundations
--   Это базовый минимум для каждого. Без него остальное не сработает.
--
-- УРОВЕНЬ EXPLORER (иногда использовал):
--   База + Cowork + рекомендации по роли (без необходимости начинать с самых азов)
--
-- УРОВЕНЬ PRACTITIONER (использует регулярно):
--   Сразу к продвинутым темам по роли (Skills, Subagents, Cowork);
--   только Innovations роль идёт в техническую глубину (API, MCP)
--
-- Только роль 'innovations' получает технические курсы (Claude Code, API, MCP).
-- Все остальные — no-code путь.
-- ============================================================================

-- Утилитарная функция для быстрого создания шаблонов
CREATE OR REPLACE FUNCTION fn_create_program_template(
    p_role_slug TEXT,
    p_level_slug TEXT,
    p_title TEXT,
    p_description TEXT,
    p_total_hours INTEGER,
    p_courses JSONB  -- [{slug, sort_order, is_required, rationale}]
) RETURNS UUID AS $$
DECLARE
    v_role_id UUID;
    v_level_id UUID;
    v_template_id UUID;
    v_course RECORD;
    v_course_id UUID;
BEGIN
    SELECT id INTO v_role_id FROM ob_roles WHERE slug = p_role_slug;
    SELECT id INTO v_level_id FROM ob_ai_levels WHERE slug = p_level_slug;

    INSERT INTO ob_program_templates (role_id, ai_level_id, title_ru, description_ru, estimated_total_hours)
    VALUES (v_role_id, v_level_id, p_title, p_description, p_total_hours)
    ON CONFLICT (role_id, ai_level_id) DO UPDATE
        SET title_ru = EXCLUDED.title_ru,
            description_ru = EXCLUDED.description_ru,
            estimated_total_hours = EXCLUDED.estimated_total_hours
    RETURNING id INTO v_template_id;

    DELETE FROM ob_program_template_courses WHERE template_id = v_template_id;

    FOR v_course IN SELECT * FROM jsonb_to_recordset(p_courses) AS x(slug TEXT, sort_order INT, is_required BOOLEAN, rationale TEXT)
    LOOP
        SELECT id INTO v_course_id FROM ob_courses WHERE slug = v_course.slug;
        IF v_course_id IS NOT NULL THEN
            INSERT INTO ob_program_template_courses (template_id, course_id, sort_order, is_required, rationale_ru)
            VALUES (v_template_id, v_course_id, v_course.sort_order, v_course.is_required, v_course.rationale);
        END IF;
    END LOOP;

    RETURN v_template_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ШАБЛОНЫ: NEWCOMER (никогда не использовал AI)
-- Универсальная структура для всех нетехнических ролей:
-- 1. Claude 101 (база)
-- 2. AI Capabilities and Limitations (как работает AI, чтобы не было разочарования)
-- 3. AI Fluency Foundations (фреймворк сотрудничества)
-- ============================================================================

-- ===== Sales Agent — Newcomer =====
SELECT fn_create_program_template('sales-agent', 'newcomer',
    'Программа агента по продажам: с нуля',
    'Базовая программа для агента, который никогда не использовал AI. Цель: за 9 часов уметь самостоятельно использовать Claude для писем, КП и follow-up.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Базовое знакомство с Claude. Без этого невозможно идти дальше."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Калибровка ожиданий: где AI помогает, где ошибается. Критично для работы с клиентами."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк работы с AI: контекст, итерации, проверка. Сделает работу с Claude в разы эффективнее."}
    ]'::jsonb);

-- ===== Sales Agent — Explorer =====
SELECT fn_create_program_template('sales-agent', 'explorer',
    'Программа агента по продажам: ускорение',
    'Для агента, который уже пользовался AI. Углубление и подключение Cowork для работы с документами.',
    7,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация знаний: Projects, Artifacts, Skills, коннекторы."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк, который структурирует ваш стихийный опыт работы с AI."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":false,"rationale":"Когда работа с файлами (договоры, КП) станет более сложной."}
    ]'::jsonb);

-- ===== Sales Agent — Practitioner =====
SELECT fn_create_program_template('sales-agent', 'practitioner',
    'Программа агента по продажам: продвинутый уровень',
    'Для агента, активно использующего AI. Сразу к Skills и Cowork — построение масштабируемого личного workflow.',
    6,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":false,"rationale":"Опционально для проверки покрытия фич Claude (Skills, Connectors, Research)."},
      {"slug":"introduction-to-claude-cowork","sort_order":2,"is_required":true,"rationale":"Cowork — следующий уровень: работа Claude с файлами, автоматизация workflow."},
      {"slug":"introduction-to-agent-skills","sort_order":3,"is_required":true,"rationale":"Skills — переиспользуемая экспертиза. Для опытного агента это масштабирование себя."}
    ]'::jsonb);

-- ===== Rental Agent — Newcomer =====
SELECT fn_create_program_template('rental-agent', 'newcomer',
    'Программа агента по аренде: с нуля',
    'Базовая программа. Цель: уметь использовать Claude для общения с арендаторами, переводов, координации.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База. Всё начинается отсюда."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Понять, где AI спасает время, а где надо проверять."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк: как давать контекст и итерировать."}
    ]'::jsonb);

-- ===== Rental Agent — Explorer =====
SELECT fn_create_program_template('rental-agent', 'explorer',
    'Программа агента по аренде: ускорение',
    'Углубление + Cowork для работы с документами договоров.',
    7,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация знаний: Projects под чек-листы, Skills под повторяющиеся задачи."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк сотрудничества с AI."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":false,"rationale":"Для работы с договорами и инструкциями для гостей."}
    ]'::jsonb);

-- ===== Rental Agent — Practitioner =====
SELECT fn_create_program_template('rental-agent', 'practitioner',
    'Программа агента по аренде: продвинутый уровень',
    'Skills + Cowork для масштабирования. Один Skill = один тип повторяющейся коммуникации.',
    6,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":false,"rationale":"Проверка покрытия фич."},
      {"slug":"introduction-to-claude-cowork","sort_order":2,"is_required":true,"rationale":"Cowork с файлами договоров и гайдов."},
      {"slug":"introduction-to-agent-skills","sort_order":3,"is_required":true,"rationale":"Skills под все повторяющиеся коммуникации (заселение, выселение, правила, ответы на жалобы)."}
    ]'::jsonb);

-- ===== Rental Head — Newcomer =====
SELECT fn_create_program_template('rental-head', 'newcomer',
    'Программа руководителя отдела аренды: с нуля',
    'Для руководителя — фокус на управленческих задачах: отчёты, 1:1, SOP. + базовая работа с Claude.',
    11,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База Claude."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Понимание границ AI."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк сотрудничества."},
      {"slug":"introduction-to-claude-cowork","sort_order":4,"is_required":true,"rationale":"Управленческая работа = много документов: отчёты, SOP, аналитика. Cowork критичен."}
    ]'::jsonb);

-- ===== Rental Head — Explorer =====
SELECT fn_create_program_template('rental-head', 'explorer',
    'Программа руководителя отдела аренды: ускорение',
    'Углубление + Cowork + Skills для построения масштабируемых процессов отдела.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Закрытие пробелов в фичах: Projects, Skills, Research."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк: критично для руководителя, который потом учит команду."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Cowork для аналитики и отчётов."},
      {"slug":"introduction-to-agent-skills","sort_order":4,"is_required":false,"rationale":"Skills могут быть командными — построить набор для всего отдела."}
    ]'::jsonb);

-- ===== Rental Head — Practitioner =====
SELECT fn_create_program_template('rental-head', 'practitioner',
    'Программа руководителя отдела аренды: продвинутый',
    'Сразу к Skills и Cowork. Цель — стать AI-power-user, который масштабирует подход на отдел.',
    8,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Cowork — основа продвинутой работы."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Skills для масштабирования экспертизы на команду."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":false,"rationale":"Если хочешь учить команду — нужен общий фреймворк."}
    ]'::jsonb);

-- ===== Property Management — Newcomer =====
SELECT fn_create_program_template('property-management', 'newcomer',
    'Программа УК: с нуля',
    'Документация, отчёты собственникам, координация работ. Все три базовых курса.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Калибровка ожиданий."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк."}
    ]'::jsonb);

-- ===== Property Management — Explorer =====
SELECT fn_create_program_template('property-management', 'explorer',
    'Программа УК: ускорение',
    'Базовые + Cowork для работы с актами, отчётами, технической документацией.',
    7,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Документы и отчёты — основная работа УК."}
    ]'::jsonb);

-- ===== Property Management — Practitioner =====
SELECT fn_create_program_template('property-management', 'practitioner',
    'Программа УК: продвинутый',
    'Cowork + Skills для шаблонов отчётов и инцидент-репортов.',
    6,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Cowork как основной инструмент."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Skills для типовых документов."}
    ]'::jsonb);

-- ===== Owner Relations Head — Newcomer =====
SELECT fn_create_program_template('owner-relations-head', 'newcomer',
    'Программа руководителя по собственникам и OTA: с нуля',
    'База + аналитика + работа с листингами Airbnb/Booking.',
    11,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Калибровка ожиданий."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":4,"is_required":true,"rationale":"Аналитика загрузки, отчёты собственникам — Cowork с Excel/CSV."}
    ]'::jsonb);

-- ===== Owner Relations Head — Explorer =====
SELECT fn_create_program_template('owner-relations-head', 'explorer',
    'Программа руководителя по собственникам и OTA: ускорение',
    'Cowork + Research для конкурентного анализа OTA.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация (особенно Research mode для анализа конкурентов на OTA)."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Cowork для аналитики."}
    ]'::jsonb);

-- ===== Owner Relations Head — Practitioner =====
SELECT fn_create_program_template('owner-relations-head', 'practitioner',
    'Программа руководителя по собственникам и OTA: продвинутый',
    'Cowork + Skills для шаблонов отчётов собственникам и оптимизации листингов.',
    8,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Основной инструмент аналитики."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Skills под отчёты, описания листингов, переговоры."}
    ]'::jsonb);

-- ===== Main Dance Team Head — Newcomer =====
SELECT fn_create_program_template('main-dance-team-head', 'newcomer',
    'Программа руководителя Main Dance Team: с нуля',
    'Стратегические задачи + презентации + развитие команды. База + Cowork.',
    11,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Понимание границ AI — критично для C-level."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк (важно учить и команду)."},
      {"slug":"introduction-to-claude-cowork","sort_order":4,"is_required":true,"rationale":"Презентации, отчёты, стратегические документы — Cowork."}
    ]'::jsonb);

-- ===== Main Dance Team Head — Explorer =====
SELECT fn_create_program_template('main-dance-team-head', 'explorer',
    'Программа руководителя Main Dance Team: ускорение',
    'Cowork + Research для стратегических решений.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация (особенно Research для стратегических задач)."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Cowork для презентаций и отчётов."}
    ]'::jsonb);

-- ===== Main Dance Team Head — Practitioner =====
SELECT fn_create_program_template('main-dance-team-head', 'practitioner',
    'Программа руководителя Main Dance Team: продвинутый',
    'Cowork + Skills + AI Fluency for Educators (для развития команды).',
    9,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Основной инструмент."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Командные Skills — масштабирование экспертизы."},
      {"slug":"ai-fluency-for-educators","sort_order":3,"is_required":false,"rationale":"Если развиваешь команду в AI — этот курс даст методики обучения."}
    ]'::jsonb);

-- ===== Marketing — Newcomer =====
SELECT fn_create_program_template('marketing', 'newcomer',
    'Программа маркетинга: с нуля',
    'Базовая программа. Контент-производство, перевод, A/B тесты — всё это про работу с текстом.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База — критична для копирайтера."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Понимание галлюцинаций — важно для фактов в маркетинге."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк генерации вариантов."}
    ]'::jsonb);

-- ===== Marketing — Explorer =====
SELECT fn_create_program_template('marketing', 'explorer',
    'Программа маркетинга: ускорение',
    'Cowork + Skills под производство контента в потоке.',
    8,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Cowork для production-pipeline контента."}
    ]'::jsonb);

-- ===== Marketing — Practitioner =====
SELECT fn_create_program_template('marketing', 'practitioner',
    'Программа маркетинга: продвинутый',
    'Cowork + Skills для масштабирования голоса бренда.',
    7,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Cowork как основа."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Skills под форматы (Reels, Threads, Email, Лендинг) — масштабирует tone of voice."}
    ]'::jsonb);

-- ===== HR — Newcomer =====
SELECT fn_create_program_template('hr', 'newcomer',
    'Программа HR: с нуля',
    'Скрининг резюме, JD, интервью-вопросы — все три базовых курса.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Понимание галлюцинаций критично — речь о людях."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк."}
    ]'::jsonb);

-- ===== HR — Explorer =====
SELECT fn_create_program_template('hr', 'explorer',
    'Программа HR: ускорение',
    'Cowork для работы с резюме и документами.',
    7,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Cowork для пакетного скрининга резюме."}
    ]'::jsonb);

-- ===== HR — Practitioner =====
SELECT fn_create_program_template('hr', 'practitioner',
    'Программа HR: продвинутый',
    'Cowork + Skills под весь HR-pipeline.',
    7,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Cowork — основа."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Skills под JD, интервью-вопросы, офферы, онбординг-планы."}
    ]'::jsonb);

-- ===== QC — Newcomer =====
SELECT fn_create_program_template('qc', 'newcomer',
    'Программа QC: с нуля',
    'Анализ звонков, фидбек, отчёты. База + Cowork для работы с транскриптами.',
    11,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Калибровка ожиданий — критично, ведь QC оценивает работу людей."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":4,"is_required":true,"rationale":"Cowork для работы с транскриптами и сводными отчётами."}
    ]'::jsonb);

-- ===== QC — Explorer =====
SELECT fn_create_program_template('qc', 'explorer',
    'Программа QC: ускорение',
    'Cowork + Skills для рубрик и шаблонов фидбека.',
    8,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":true,"rationale":"Cowork как основной инструмент."}
    ]'::jsonb);

-- ===== QC — Practitioner =====
SELECT fn_create_program_template('qc', 'practitioner',
    'Программа QC: продвинутый',
    'Skills под рубрики оценки и шаблоны фидбека. Подготовка к участию в архитектуре AI QC системы IBG.',
    7,
    '[
      {"slug":"introduction-to-claude-cowork","sort_order":1,"is_required":true,"rationale":"Cowork как ежедневный инструмент."},
      {"slug":"introduction-to-agent-skills","sort_order":2,"is_required":true,"rationale":"Skills под LPMAMA-рубрику и шаблоны коучинга."}
    ]'::jsonb);

-- ===== Call Center — Newcomer =====
SELECT fn_create_program_template('call-center', 'newcomer',
    'Программа колл-центра: с нуля',
    'Скрипты, квалификация, реанимация. Все три базовых курса.',
    9,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"База."},
      {"slug":"ai-capabilities-and-limitations","sort_order":2,"is_required":true,"rationale":"Калибровка."},
      {"slug":"ai-fluency-framework-foundations","sort_order":3,"is_required":true,"rationale":"Фреймворк."}
    ]'::jsonb);

-- ===== Call Center — Explorer =====
SELECT fn_create_program_template('call-center', 'explorer',
    'Программа колл-центра: ускорение',
    'Базовый стек + углубление по Skills для скриптов.',
    7,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Систематизация (Skills для повторяющихся скриптов)."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк."},
      {"slug":"introduction-to-claude-cowork","sort_order":3,"is_required":false,"rationale":"Опционально, если нужно работать с большими списками лидов."}
    ]'::jsonb);

-- ===== Call Center — Practitioner =====
SELECT fn_create_program_template('call-center', 'practitioner',
    'Программа колл-центра: продвинутый',
    'Skills под все типовые скрипты + Cowork для реанимации.',
    6,
    '[
      {"slug":"introduction-to-agent-skills","sort_order":1,"is_required":true,"rationale":"Skills — твои персональные скрипты, которые срабатывают автоматически."},
      {"slug":"introduction-to-claude-cowork","sort_order":2,"is_required":false,"rationale":"Если работаешь с массивами лидов из CRM — Cowork."}
    ]'::jsonb);

-- ===== INNOVATIONS — Newcomer (для новых сотрудников отдела) =====
SELECT fn_create_program_template('innovations', 'newcomer',
    'Программа Innovations: с нуля (новый разработчик)',
    'Полный технический трек для нового сотрудника отдела. ~25 часов до уровня самостоятельной работы.',
    25,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":true,"rationale":"Понимание Claude как продукта, а не только API."},
      {"slug":"ai-fluency-framework-foundations","sort_order":2,"is_required":true,"rationale":"Фреймворк сотрудничества с AI — основа всего."},
      {"slug":"claude-code-101","sort_order":3,"is_required":true,"rationale":"Claude Code — главный инструмент разработки в IBG (стек на Contabo VPS)."},
      {"slug":"introduction-to-agent-skills","sort_order":4,"is_required":true,"rationale":"Skills — переиспользуемые компоненты разработки в стеке IBG."},
      {"slug":"introduction-to-subagents","sort_order":5,"is_required":true,"rationale":"Subagents — управление контекстом в Claude Code."},
      {"slug":"building-with-claude-api","sort_order":6,"is_required":true,"rationale":"API — основа всех n8n workflow в стеке IBG (Lucy OS, AI-CEO)."},
      {"slug":"introduction-to-mcp","sort_order":7,"is_required":true,"rationale":"MCP — то, как Claude интегрируется с amoCRM, Supabase, Wazzup в нашем стеке."}
    ]'::jsonb);

-- ===== INNOVATIONS — Explorer =====
SELECT fn_create_program_template('innovations', 'explorer',
    'Программа Innovations: ускорение',
    'Для тех, кто уже работает с AI и кодит — пропускаем самые азы, идём в технику.',
    20,
    '[
      {"slug":"claude-101","sort_order":1,"is_required":false,"rationale":"Опционально для проверки покрытия фич."},
      {"slug":"claude-code-101","sort_order":2,"is_required":true,"rationale":"Claude Code — обязательно."},
      {"slug":"introduction-to-agent-skills","sort_order":3,"is_required":true,"rationale":"Skills."},
      {"slug":"introduction-to-subagents","sort_order":4,"is_required":true,"rationale":"Subagents."},
      {"slug":"building-with-claude-api","sort_order":5,"is_required":true,"rationale":"API."},
      {"slug":"introduction-to-mcp","sort_order":6,"is_required":true,"rationale":"MCP."},
      {"slug":"claude-code-in-action","sort_order":7,"is_required":false,"rationale":"Углубление в реальные кейсы Claude Code."}
    ]'::jsonb);

-- ===== INNOVATIONS — Practitioner (это уровень Юры сейчас) =====
SELECT fn_create_program_template('innovations', 'practitioner',
    'Программа Innovations: продвинутый (для Юры и опытных)',
    'Углубление: продвинутые темы MCP, Claude Code in Action, Subagents в продакшне.',
    18,
    '[
      {"slug":"claude-code-in-action","sort_order":1,"is_required":true,"rationale":"Углубление в продакшн-сценарии Claude Code (актуально для текущей работы на Contabo)."},
      {"slug":"introduction-to-subagents","sort_order":2,"is_required":true,"rationale":"Subagents в архитектуре AI-CEO."},
      {"slug":"introduction-to-agent-skills","sort_order":3,"is_required":true,"rationale":"Skills как dev-pattern (актуально для всего IBG-стека)."},
      {"slug":"mcp-advanced-topics","sort_order":4,"is_required":true,"rationale":"MCP advanced — sampling, notifications, file system, transports. Прямо ложится на стек REALTRUM/Lucy OS."},
      {"slug":"building-with-claude-api","sort_order":5,"is_required":false,"rationale":"Опционально для углубления в API-паттерны."}
    ]'::jsonb);

-- ============================================================================
-- ГОТОВО. 11 ролей × 3 уровня = 33 шаблона программ.
-- Следующий шаг — структура опроса (отдельный файл или JSON-схема в коде)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VIEW: посмотреть программу для роли+уровня
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_ob_program_preview AS
SELECT
    r.title_ru AS role_title,
    r.department,
    al.title_ru AS ai_level,
    pt.title_ru AS program_title,
    pt.estimated_total_hours AS hours,
    string_agg(c.title_ru, ' → ' ORDER BY ptc.sort_order) AS courses_path,
    COUNT(*) FILTER (WHERE ptc.is_required) AS required_courses,
    COUNT(*) FILTER (WHERE NOT ptc.is_required) AS optional_courses
FROM ob_program_templates pt
JOIN ob_roles r ON r.id = pt.role_id
JOIN ob_ai_levels al ON al.id = pt.ai_level_id
JOIN ob_program_template_courses ptc ON ptc.template_id = pt.id
JOIN ob_courses c ON c.id = ptc.course_id
GROUP BY r.title_ru, r.department, al.title_ru, al.sort_order, pt.title_ru, pt.estimated_total_hours, r.sort_order
ORDER BY r.sort_order, al.sort_order;
