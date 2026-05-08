# User Flows — что происходит на каждом экране

> Этот документ описывает каждый экран и что должно работать.
> Используй как референс, когда Claude Code будет реализовывать страницы.

---

## Flow 1: Регистрация по invite

### Что видит пользователь

1. Получает в Telegram сообщение с invite-ссылкой типа `https://academy.ibgproperty.com/signup?invite=abc123`
2. Кликает → попадает на форму регистрации
3. Если ссылка валидная — заполняет (имя, email, пароль)
4. Нажимает "Зарегистрироваться"
5. Автоматически попадает на страницу опроса `/onboarding`

### Что происходит технически

1. URL `/signup?invite=abc123` открывается
2. JavaScript читает параметр `invite` из URL
3. Делает запрос: `SELECT * FROM invites WHERE token='abc123' AND used_at IS NULL AND expires_at > NOW()`
4. Если invite не найден или устарел → показать ошибку "Ссылка недействительна"
5. Если invite валидный → показать форму
6. После submit:
   - Валидация пароля (≥8 символов, совпадает с повтором)
   - `supabase.auth.signUp({ email, password, options: { data: { full_name } } })`
   - `UPDATE invites SET used_at=NOW(), used_by=auth.uid() WHERE token='abc123'`
   - Редирект на `/onboarding`

### Edge cases

- ❌ Invite не существует → "Эта ссылка недействительна"
- ❌ Invite уже использован → "Эта ссылка уже была использована"
- ❌ Email уже зарегистрирован → "Этот email уже используется. Войти?"
- ❌ Пароли не совпадают → "Пароли не совпадают"
- ❌ Пароль короче 8 символов → "Пароль должен быть минимум 8 символов"

---

## Flow 2: Опрос (10 вопросов)

### Что видит пользователь

1. После регистрации попадает на `/onboarding`
2. Видит первый вопрос на полный экран
3. Прогресс-бар сверху: "Шаг 1 из 10"
4. Заполняет → "Далее"
5. Может листать назад/вперёд
6. После 10 вопросов — кнопка "Получить мою программу"
7. Loader 2-3 секунды → редирект на `/program`

### Что происходит технически

**Структура опроса:** в файле `docs/03_ASSESSMENT.json` — 10 вопросов с типами и опциями.

**Сохранение состояния:**
- Локальный state в React (через useState или React Hook Form)
- Сохранение в localStorage после каждого шага (на случай закрытия вкладки)
- Финальный submit → запись в Supabase

**Запись результатов:**
```typescript
// После submit финального шага
await supabase
  .from('ob_user_assessments')
  .upsert({
    user_id: user.id,
    role_id: answers.role,
    ai_level_id: answers.ai_level,
    full_name: answers.full_name,
    job_description_ru: answers.job_description,
    pain_points: answers.pain_points,
    tools_used: answers.tools_used,
    preferred_language: answers.preferred_language,
    weekly_time_budget_hours: answers.weekly_time_budget,
    learning_goal: answers.learning_goal,
    has_claude_subscription: answers.claude_subscription,
    completed_at: new Date()
  })

// Генерируем программу
await supabase.rpc('fn_generate_user_program', { p_user_id: user.id })

// Редирект
router.push('/program')
```

### Edge cases

- ⚠️ Закрыл вкладку → восстанавливаем из localStorage при возврате
- ⚠️ Не выбран обязательный ответ → блокируем кнопку "Далее"
- ⚠️ Pain points меньше 3 → блокируем (минимум 3)
- ⚠️ RPC fn_generate_user_program не нашла шаблон → fallback на базовый трек

---

## Flow 3: Прохождение урока

### Что видит пользователь

1. На `/program` нажимает "Продолжить" → попадает в первый незавершённый урок
2. URL: `/courses/claude-101/lessons/what-is-claude`
3. Видит sticky-навигацию: "Claude 101 / Урок 1: Что такое Claude" + прогресс по микро-блокам "1/6"
4. Читает блок "Зачем это вам" (1 мин) → "Понятно, далее" → следующий
5. Блок "Что у вас сейчас" (рефлексия) → "Далее"
6. Блок "Видео + транскрипт" — встроенный YouTube + транскрипт под ним → "Далее"
7. Блок "Применение в IBG" — общий текст + блок под ВАШУ роль → "Далее"
8. Блок "Микро-практика" — markdown + кнопка "Открыть claude.ai" → "Я выполнил" → "Далее"
9. Блок "Чек-лист самопроверки" — массив строк как чек-боксы → когда все отмечены → "Завершить урок"
10. Редирект на следующий урок (или на `/courses/[slug]` если был последний)

### Что происходит технически

**Загрузка урока:**
```typescript
const lesson = await supabase
  .from('ob_lessons')
  .select(`
    *,
    module:ob_modules(course_id, title_ru),
    overlay:ob_lesson_role_overlays(extra_examples_ru, role_specific_tips_ru)
  `)
  .eq('id', lessonId)
  .eq('overlay.role_id', userRoleId)
  .single()

// Создаём запись прогресса
await supabase.from('ob_user_progress').upsert({
  user_id: user.id,
  lesson_id: lesson.id,
  status: 'in_progress',
  started_at: new Date()
})
```

**Структура страницы:**
```tsx
<LessonPlayer lesson={lesson}>
  {lesson.micro_blocks.map((block, i) => (
    <MicroBlock key={i} block={block} lesson={lesson} index={i} />
  ))}
</LessonPlayer>
```

**Компонент MicroBlock рендерит контент в зависимости от `block.type`:**
- `intro` → markdown(`lesson.why_this_matters_ru`)
- `reflect` → markdown(`lesson.reflect_on_experience_ru`)
- `content` → `<VideoEmbed url={lesson.video_url} />` + markdown(`lesson.transcript_ru`)
- `apply` → markdown(`lesson.apply_to_ibg_ru`) + если есть overlay → markdown(`overlay.extra_examples_ru`)
- `practice` → markdown(`lesson.micro_practice_ru`)
- `review` → checklist из `lesson.mastery_checklist_ru`

**Завершение урока:**
```typescript
// При отметке всех чек-боксов
const checklistComplete = checkedItems.length === lesson.mastery_checklist_ru.length

if (checklistComplete) {
  await supabase.from('ob_user_progress').update({
    status: 'completed',
    completed_at: new Date()
  }).eq('user_id', user.id).eq('lesson_id', lesson.id)
  
  router.push(nextLessonUrl || `/courses/${courseSlug}`)
}
```

**Tracking времени** (heartbeat каждые 30 секунд):
```typescript
useEffect(() => {
  const interval = setInterval(async () => {
    if (document.visibilityState === 'visible') {
      await supabase.rpc('increment_lesson_time', {
        p_user_id: user.id,
        p_lesson_id: lesson.id,
        p_seconds: 30
      })
    }
  }, 30000)
  return () => clearInterval(interval)
}, [])
```

---

## Flow 4: Создание invite (admin)

### Что видит admin

1. Заходит на `/admin/invites`
2. Видит таблицу инвайтов
3. Нажимает "Создать invite"
4. Форма: email + опционально pre-fill роль
5. Submit → создаётся запись + копируется ссылка в clipboard
6. Отправляет ссылку в Telegram сотруднику

### Что происходит технически

```typescript
const { data, error } = await supabase
  .from('invites')
  .insert({
    email: email.toLowerCase().trim(),
    pre_filled_role_id: roleId || null,
    created_by: admin.id,
    token: crypto.randomUUID()
  })
  .select()
  .single()

const inviteUrl = `${window.location.origin}/signup?invite=${data.token}`
await navigator.clipboard.writeText(inviteUrl)
toast.success('Ссылка скопирована')
```

---

## Flow 5: Редактирование урока (admin)

### Что видит admin

1. `/admin/courses/claude-101/lessons` — список уроков
2. Выбирает урок → `/admin/courses/claude-101/lessons/what-is-claude/edit`
3. Видит форму с textarea для каждого markdown-поля
4. Сбоку — preview (пересчитывается при изменении)
5. Нажимает "Сохранить" → изменения видны студентам сразу

### Что происходит технически

```typescript
await supabase
  .from('ob_lessons')
  .update({
    title_ru,
    summary_ru,
    why_this_matters_ru,
    reflect_on_experience_ru,
    transcript_ru,
    apply_to_ibg_ru,
    micro_practice_ru,
    mastery_checklist_ru,
    micro_blocks,
    video_url,
    updated_at: new Date()
  })
  .eq('id', lessonId)
```

---

## Защищённые маршруты (middleware)

```typescript
// middleware.ts проверяет на каждом запросе:

// Не залогинен → редирект на /login
if (!user && pathStartsWithProtected) → redirect('/login')

// Залогинен, опрос не пройден → редирект на /onboarding
if (user && !assessmentComplete && path !== '/onboarding') → redirect('/onboarding')

// Не admin пытается на /admin → редирект на /program
if (user && !isAdmin && path.startsWith('/admin')) → redirect('/program')
```

---

## Состояния загрузки и ошибок

### Loaders
Везде используем skeleton-loaders:
```tsx
<div className="animate-pulse">
  <div className="h-12 bg-slate-200 rounded mb-4"></div>
  <div className="h-8 bg-slate-200 rounded w-3/4"></div>
</div>
```

### Ошибки
Все ошибки → toast notifications + console.log:
```typescript
try {
  // действие
} catch (error) {
  console.error('Lesson load failed:', error)
  toast.error('Не удалось загрузить урок. Попробуйте обновить страницу.')
}
```
