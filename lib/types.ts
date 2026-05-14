/**
 * TypeScript-типы для таблиц Supabase.
 *
 * Эти типы — ручная зарисовка схемы (см. migrations/001, 003, 004, 007).
 * Когда схема стабилизируется, заменим на авто-генерацию:
 *   npx supabase gen types typescript --project-id <ref> > lib/database.types.ts
 *
 * Используем нативные TS-типы (string, number, boolean) — никаких Database<>
 * generic'ов пока не нужно.
 */

// ----------------------------------------------------------------------------
// Базовые enum-подобные типы
// ----------------------------------------------------------------------------

/** Роль пользователя в системе (из auth.users.raw_user_meta_data->>'role'). */
export type UserRole = "student" | "admin";

/** Уровень AI-опыта пользователя (ob_ai_levels.slug). */
export type AILevel = "newcomer" | "explorer" | "practitioner";

/** Статус прохождения урока (ob_user_progress.status). */
export type LessonStatus = "not_started" | "in_progress" | "completed";

/** Статус курса в персональной программе (ob_user_program_courses.status). */
export type ProgramCourseStatus = LessonStatus | "skipped";

/** Сложность курса (ob_courses.difficulty). */
export type CourseDifficulty = "beginner" | "intermediate" | "advanced";

/** Сложность задания (ob_exercises.difficulty). */
export type ExerciseDifficulty = "easy" | "medium" | "hard";

/** Тип практического задания (ob_exercises.exercise_type). */
export type ExerciseType = "practical" | "quiz" | "reflection" | "checklist";

/** Предпочитаемый язык интерфейса (ob_user_assessments.preferred_language). */
export type PreferredLanguage = "ru" | "en" | "both";

/** Тариф Claude у пользователя (ob_user_assessments.has_claude_subscription). */
export type ClaudeSubscription = "free" | "pro" | "team" | "unknown";

// ----------------------------------------------------------------------------
// Контент: треки, курсы, модули, уроки, упражнения
// ----------------------------------------------------------------------------

export type Track = {
  id: string;
  slug: string;
  title_ru: string;
  title_en: string;
  description_ru: string | null;
  description_en: string | null;
  icon: string | null;
  sort_order: number;
  is_published: boolean;
  created_at: string;
  updated_at: string;
};

export type Course = {
  id: string;
  track_id: string | null;
  slug: string;
  title_ru: string;
  title_en: string;
  description_ru: string | null;
  description_en: string | null;
  duration_minutes: number | null;
  difficulty: CourseDifficulty | null;
  target_role: string[] | null;
  cover_image_url: string | null;
  source_url: string | null;
  sort_order: number;
  is_published: boolean;
  created_at: string;
  updated_at: string;
};

export type Module = {
  id: string;
  course_id: string;
  slug: string;
  title_ru: string;
  title_en: string;
  description_ru: string | null;
  sort_order: number;
  created_at: string;
};

/** Один из микро-блоков урока (поле ob_lessons.micro_blocks: JSONB). */
export type MicroBlock = {
  slug: string;
  title_ru: string;
  duration_minutes?: number;
  kind?: "intro" | "video" | "theory" | "practice" | "checklist";
  body_ru?: string;
};

export type Lesson = {
  id: string;
  module_id: string;
  slug: string;
  title_ru: string;
  title_en: string;
  summary_ru: string | null;
  summary_en: string | null;
  video_url: string | null;
  video_duration_seconds: number | null;
  transcript_en: string | null;
  transcript_ru: string | null;
  theory_ru: string | null;
  key_takeaways_ru: string[] | null;
  // Расширения миграции 003 (микрообучение по Ноулзу):
  why_this_matters_ru: string | null;
  reflect_on_experience_ru: string | null;
  apply_to_ibg_ru: string | null;
  micro_practice_ru: string | null;
  mastery_checklist_ru: string[] | null;
  micro_blocks: MicroBlock[] | null;
  estimated_minutes: number;
  sort_order: number;
  is_published: boolean;
  created_at: string;
  updated_at: string;
};

export type Exercise = {
  id: string;
  lesson_id: string;
  slug: string;
  title_ru: string;
  exercise_type: ExerciseType | null;
  instructions_ru: string;
  context_ru: string | null;
  success_criteria_ru: string[] | null;
  example_solution_ru: string | null;
  common_mistakes_ru: string[] | null;
  quiz_options: QuizOption[] | null;
  estimated_minutes: number;
  difficulty: ExerciseDifficulty | null;
  sort_order: number;
  created_at: string;
};

export type QuizOption = {
  text: string;
  is_correct: boolean;
  explanation?: string;
};

// ----------------------------------------------------------------------------
// Роли, уровни, шаблоны программ
// ----------------------------------------------------------------------------

export type Role = {
  id: string;
  slug: string;
  title_ru: string;
  department: string;
  description_ru: string | null;
  is_management: boolean;
  common_tools: string[] | null;
  typical_pain_points: string[] | null;
  sort_order: number;
  created_at: string;
};

export type AILevelRecord = {
  id: string;
  slug: AILevel;
  title_ru: string;
  description_ru: string | null;
  sort_order: number;
};

export type ProgramTemplate = {
  id: string;
  role_id: string;
  ai_level_id: string;
  title_ru: string;
  description_ru: string | null;
  estimated_total_hours: number | null;
};

export type ProgramTemplateCourse = {
  id: string;
  template_id: string;
  course_id: string;
  sort_order: number;
  is_required: boolean;
  rationale_ru: string | null;
};

// ----------------------------------------------------------------------------
// Опрос пользователя, программа, прогресс
// ----------------------------------------------------------------------------

/** Один из пунктов "болей" пользователя из опроса. */
export type PainPoint = {
  task: string;
  hours_per_week?: number;
  frequency?: "daily" | "weekly" | "occasional";
};

export type UserAssessment = {
  id: string;
  user_id: string;
  role_id: string | null;
  ai_level_id: string | null;
  full_name: string | null;
  job_description_ru: string | null;
  pain_points: PainPoint[] | null;
  tools_used: string[] | null;
  preferred_language: PreferredLanguage;
  weekly_time_budget_hours: number | null;
  learning_goal: string | null;
  has_claude_subscription: ClaudeSubscription | null;
  completed_at: string | null;
  created_at: string;
  updated_at: string;
};

export type UserProgram = {
  id: string;
  user_id: string;
  assessment_id: string;
  template_id: string | null;
  title_ru: string;
  estimated_hours: number | null;
  started_at: string;
  completed_at: string | null;
  ibg_context_overlay: Record<string, unknown> | null;
  created_at: string;
  updated_at: string;
};

export type UserProgramCourse = {
  id: string;
  program_id: string;
  course_id: string;
  sort_order: number;
  is_required: boolean;
  status: ProgramCourseStatus;
  started_at: string | null;
  completed_at: string | null;
};

export type UserProgress = {
  id: string;
  user_id: string;
  lesson_id: string;
  status: LessonStatus;
  started_at: string | null;
  completed_at: string | null;
  time_spent_seconds: number;
  created_at: string;
  updated_at: string;
};

export type ExerciseSubmission = {
  id: string;
  user_id: string;
  exercise_id: string;
  answer_text: string | null;
  quiz_selected: Record<string, unknown> | null;
  checklist_state: Record<string, boolean> | null;
  is_correct: boolean | null;
  reviewer_id: string | null;
  reviewer_feedback: string | null;
  reviewed_at: string | null;
  ai_feedback: string | null;
  ai_score: number | null;
  submitted_at: string;
  created_at: string;
};

export type Certificate = {
  id: string;
  user_id: string;
  course_id: string;
  issued_at: string;
  certificate_number: string;
  pdf_url: string | null;
};

// ----------------------------------------------------------------------------
// IBG-инжекции под роли (overlays)
// ----------------------------------------------------------------------------

export type LessonRoleOverlay = {
  id: string;
  lesson_id: string;
  role_id: string;
  extra_examples_ru: string | null;
  role_specific_tips_ru: string | null;
  pain_point_addresses: Record<string, unknown> | null;
  sort_order: number;
  created_at: string;
};

export type ExerciseRoleVariant = {
  id: string;
  exercise_id: string;
  role_id: string;
  instructions_override_ru: string | null;
  context_override_ru: string | null;
  example_solution_override_ru: string | null;
  suggested_pain_points: string[] | null;
  created_at: string;
};

// ----------------------------------------------------------------------------
// Invites
// ----------------------------------------------------------------------------

export type Invite = {
  id: string;
  token: string;
  email: string;
  pre_filled_role_id: string | null;
  created_by: string | null;
  used_by: string | null;
  used_at: string | null;
  created_at: string;
  expires_at: string;
};
