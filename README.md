# ALU Bug Bounty

A Flutter app for reporting and tracking campus issues (facilities, water, electricity, furniture, sanitation, safety). Students file reports with photos, faculty triage them, admins oversee everything, and students earn XP and ranks for useful reports.

## Roles

- **Student** - file reports, upvote, track status, earn XP and climb the leaderboard
- **Faculty** - triage and resolve reports for their department
- **Admin** - manage people, teams, locations and all reports

## Stack

- Flutter, Riverpod, GoRouter
- Supabase (Auth, Postgres, Storage)
- `flutter_animate` and custom spring animations
- HugeIcons

Schema, row level security, write functions and XP triggers live in `supabase/migrations/`. Clients only read tables; every write is a database function that checks role and state.

## Getting started

Requires the Flutter SDK and the Supabase CLI.

```bash
supabase start
```

```bash
flutter pub get
```

```bash
flutter run --dart-define-from-file=env/local.json
```

Database tests:

```bash
supabase test db
```

## Project layout

```
lib/
  core/        theme, constants, utils
  models/      data models
  providers/   Riverpod providers
  services/    all Supabase access
  widgets/     reusable widgets
  features/    screens by feature
supabase/      migrations, seed, tests
docs/          technical report and demo script
```

## AI usage

AI assistance (Claude) was used for some of the animations, the gamification ideas (XP, ranks, rewards) and the documentation. The application design and implementation decisions are my own.
