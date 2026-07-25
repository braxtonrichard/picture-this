# Picture This

An AI lifestyle operating system for self-discovery — not another feed.
Choose a vibe, get recommendations, actually go experience them, reflect,
and let the app learn who you are over time. Full product vision:
[`docs/VISION.md`](docs/VISION.md).

This repo is the first build pass: a Flutter/Supabase skeleton with the
core loop — **Discover → Experience → Reflect** — wired end to end, plus
auth, onboarding, and a profile. It does not yet include the AI learning
engine, the "Apply this vibe" day-builder, community, or maps — see
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for exactly what's built
and what's deliberately deferred.

## Stack

- Flutter (iOS + Android + Web from one codebase)
- Supabase — Postgres, Auth (Email + Google; Apple documented but not
  wired up), Storage, Row Level Security from the start
- Riverpod for state, go_router for navigation
- Design system built on Fraunces + Inter, a warm editorial color
  palette, and a Pinterest-style masonry Discover feed — see
  [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#visual-system)
- Web build deploys to Vercel (`vercel.json` +
  `scripts/vercel_build.sh`) — same repo, same Supabase project, no
  separate web codebase

## Getting started

The sandbox this scaffold was written in has no Flutter SDK, so the
native `android/`/`ios` folders aren't generated yet (`web/` is already
committed), and you'll need your own Supabase project. Full steps:
[`docs/SETUP.md`](docs/SETUP.md). Short version:

```bash
flutter create . --org com.pictureThis --project-name picture_this
flutter pub get
# create a Supabase project, run supabase/migrations/0001_init.sql
cp .env.example .env   # fill in SUPABASE_URL / SUPABASE_ANON_KEY
flutter run
```

To deploy the web version: import the repo into Vercel, add
`SUPABASE_URL` / `SUPABASE_ANON_KEY` as Environment Variables, deploy —
see `docs/SETUP.md` step 7 for the full walkthrough.

## Docs

- [`docs/VISION.md`](docs/VISION.md) — the founder vision, verbatim
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — folder structure,
  state management, Postgres data model + RLS, what's not built yet
- [`docs/SETUP.md`](docs/SETUP.md) — full local setup, including seeding
  content so Discover isn't empty
