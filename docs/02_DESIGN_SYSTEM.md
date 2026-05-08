# Дизайн-система AI-transformation

> Как платформа должна выглядеть. Простой и функциональный дизайн без претензий на премиум.

---

## Принципы

1. **Простота** — никаких сложных анимаций и эффектов
2. **Читаемость** — хорошие шрифты, контрастный текст
3. **Mobile-first** — сначала телефон, потом десктоп
4. **Скорость** — без тяжёлых картинок и шрифтов

---

## Цвета

Используем стандартную палитру Tailwind. Не придумываем свои цвета.

### Основные
- **Тёмный (заголовки, кнопки):** `slate-900`
- **Фон:** `white`
- **Фон карточек:** `slate-50`

### Акцентные
- **Акцент (ссылки, иконки):** `blue-600`
- **Успех (завершено):** `green-600`
- **Предупреждение:** `amber-500`
- **Ошибка:** `red-600`

### Текст
- **Основной:** `slate-900`
- **Вторичный:** `slate-700`
- **Подсказки:** `slate-500`

### Границы
- **Обычные:** `slate-200`
- **Для инпутов:** `slate-300`

---

## Шрифты

- **Основной:** Inter (через next/font/google, поддержка кириллицы)
- **Моноширинный (для кода):** JetBrains Mono

### Размеры
| Элемент | Класс | Размер |
|---------|-------|--------|
| Главный заголовок (H1) | `text-4xl font-bold` | 36px |
| Заголовок страницы (H1) | `text-3xl font-bold` | 30px |
| Заголовок секции (H2) | `text-2xl font-semibold` | 24px |
| Заголовок карточки (H3) | `text-xl font-semibold` | 20px |
| Подзаголовок | `text-lg font-medium` | 18px |
| Основной текст | `text-base` | 16px |
| Подписи | `text-sm` | 14px |

---

## Типичные элементы

### Контейнер страницы
```jsx
<main className="container mx-auto px-4 py-8 max-w-4xl">
  ...
</main>
```

### Кнопка primary
```jsx
<button className="bg-slate-900 text-white hover:bg-slate-800 px-4 py-2 rounded-lg font-medium">
  Действие
</button>
```

### Кнопка secondary
```jsx
<button className="bg-white text-slate-900 border border-slate-300 hover:bg-slate-50 px-4 py-2 rounded-lg font-medium">
  Отмена
</button>
```

### Карточка
```jsx
<div className="bg-white border border-slate-200 rounded-xl p-6 shadow-sm">
  ...
</div>
```

### Инпут
```jsx
<input className="w-full border border-slate-300 rounded-lg px-3 py-2 focus:border-blue-600 focus:ring-1 focus:ring-blue-600 outline-none" />
```

---

## Компоненты shadcn/ui

Установи через:
```bash
npx shadcn@latest add button card input label select radio-group checkbox progress tabs dialog
```

Потом просто используй в коде:
```jsx
import { Button } from '@/components/ui/button'

<Button>Действие</Button>
```

---

## Адаптивность

Брейкпоинты Tailwind:
- `sm` — 640px (большие телефоны)
- `md` — 768px (планшеты)
- `lg` — 1024px (ноутбуки)

**Правило:** все экраны должны нормально работать на iPhone SE (375px шириной).

### Пример responsive grid
```jsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* На мобильном — 1 колонка, на планшете — 2, на десктопе — 3 */}
</div>
```

---

## Иконки

Используем [lucide-react](https://lucide.dev/) — единственная библиотека.

```jsx
import { Check, ChevronRight, BookOpen } from 'lucide-react'

<Check className="w-5 h-5 text-green-600" />
```

Размеры:
- `w-4 h-4` — внутри текста (16px)
- `w-5 h-5` — стандарт в кнопках (20px)
- `w-6 h-6` — большие декоративные (24px)

---

## Правило простоты

❌ **Не делаем:**
- Кастомные градиенты
- Сложные анимации
- Большие фоновые изображения
- Тёмная тема (только в v2)
- Выпадающие меню при наведении

✅ **Делаем:**
- Простые цвета из Tailwind palette
- Только базовые transitions (`transition-colors duration-150`)
- Иконки lucide-react
- Чистая типографика
- Mobile-first

---

## Если непонятно

Когда спрашиваешь Claude Code "как сделать страницу" — добавляй:

```
Дизайн: следуй принципам в docs/02_DESIGN_SYSTEM.md.
Используй Tailwind, цвета slate-900/blue-600, шрифт Inter,
простой минималистичный стиль, mobile-first.
```

Этого хватит для нормального результата.
