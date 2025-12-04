# intelligrade

This template should help get you started developing with Vue 3 in Vite.

## Study Objectives Implementation

### Objective 1: Automated Grading System ✅

- Automatic quiz grading with instant feedback
- Multiple question type support (MC, T/F, Fill-in-blank)
- AI-powered feedback caching

### Objective 2: Class Management ✅

- Subjects, sections, and student enrollment
- Quiz creation and management
- Assignment submissions and tracking

### Objective 3: System Evaluation Features ✅

- **Productivity Dashboard** (`Analytics.vue`) - Shows grading metrics, time saved, auto-graded count
- **Weekly Activity Chart** - Visualizes grading activity over 7 days
- **User Feedback Collection** (`FeedbackSurvey.vue`) - Survey after quiz completion
- **PDF/Excel Export** (`Gradebook.vue`) - Export class records to PDF and Excel

### Database Schema for Feedback

Run the SQL in `db.sql` (commented section at top) to create the `user_feedback` table.

---

## Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

## Type Support for `.vue` Imports in TS

TypeScript cannot handle type information for `.vue` imports by default, so we replace the `tsc` CLI with `vue-tsc` for type checking. In editors, we need [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) to make the TypeScript language service aware of `.vue` types.

## Customize configuration

See [Vite Configuration Reference](https://vite.dev/config/).

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

### Type-Check, Compile and Minify for Production

```sh
npm run build
```

### Lint with [ESLint](https://eslint.org/)

```sh
npm run lint
```
