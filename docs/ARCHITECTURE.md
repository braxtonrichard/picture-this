# Architecture

This first pass builds the **skeleton and core loop only** — Discover →
Experience → Reflect, with auth and a profile — not the AI learning
engine, social features, vibe day-builder, maps, or collections described
in `docs/VISION.md`. Those are real, deliberate scope cuts, not
oversights; see "Not built yet" at the bottom.

## Folder structure

```
lib/
  main.dart              — loads .env, initializes Supabase, runApp
  app.dart                — MaterialApp.router, theme wiring
  core/
    theme/                — colors, typography, spacing, ThemeData
    router/                — the single GoRouter (auth-aware redirects)
    widgets/                — shared design-system widgets
    models/                — plain Dart data classes (Vibe, Recommendation,
                              Experience, Reflection, UserProfile)
    services/                — AuthService, SupabaseService — the only
                                code that talks to Supabase directly
  features/
    auth/                  — welcome, sign in, sign up
    onboarding/                — first-vibe picker
    home/                — the bottom-nav shell
    discover/                — the vibe feed (Pillar 1)
    vibes/                — a single vibe's page
    experience/                — logging + listing experiments (Pillar 2)
    reflect/                — the reflection form (Pillar 3)
    profile/                — the "fun profile" + sign out
supabase/
  migrations/                — SQL migrations, same convention as the
                                other project (numbered, RLS from the start)
```

Each feature follows `domain/` (models specific to that feature, if any)
/ `data/` (Riverpod providers wrapping `SupabaseService`) /
`presentation/` (screens). Screens never call Supabase directly — they
watch a provider, which calls `SupabaseService`. This is the one seam
Pillar 4 (the learning engine) will plug into later: reflections already
flow through `SupabaseService.submitReflection` (a Postgres RPC), so a
recommendation engine can be added as a database function or an edge
function without touching any screen.

## State management

[Riverpod](https://riverpod.dev) (`flutter_riverpod`), classic (non
code-generated) API. Supabase's realtime queries are exposed as
`StreamProvider`s per feature (see `*_providers.dart` under each
feature's `data/` folder) — screens just do
`ref.watch(someStreamProvider)` and get an `AsyncValue` to pattern-match
with `.when(...)`.

## Navigation

[go_router](https://pub.dev/packages/go_router), one `GoRouter` in
`core/router/app_router.dart`. It watches `authStateProvider` and
redirects unauthenticated users to `/welcome` and authenticated users away
from the auth routes — no screen re-checks auth itself.

## Data model (Postgres / Supabase)

Full schema with types, constraints, indexes, and RLS policies is in
`supabase/migrations/0001_init.sql`. Summary:

```
profiles                          (id = auth.users.id, RLS: own row only)
  email, display_name, photo_url
  favorite_vibe_ids: uuid[]
  answers: jsonb                  — the "fun profile"

experiences                       (RLS: own rows only, via user_id)
  user_id, recommendation_id
  recommendation_title, recommendation_image_url   — denormalized
  status: planned | experienced | reflected
  created_at, experienced_at

reflections                       (RLS: own rows only, via user_id)
  user_id, experience_id
  rating: love | like | neutral | dislike | neverAgain
  would_repeat, matched_vibe: boolean
  mood_before, mood_after: smallint (1-5)
  journal_entry: text?
  created_at

vibes                              (RLS: read-only for authenticated users)
  name, description, cover_image_url, tags: text[]

recommendations                    (RLS: read-only for authenticated users)
  title, category (see RecommendationCategory enum), image_url,
  description, vibe_ids: uuid[], location?
```

A `handle_new_user` trigger creates the `profiles` row automatically when
someone signs up (mirrors `auth.users`), so `AuthService` never writes to
`profiles` directly on sign-up.

`vibes` and `recommendations` are shared/global tables — there's no
authoring UI for them yet, so seed rows directly via the Supabase
dashboard's Table Editor or SQL editor (or a script) to populate Discover
and the vibe picker. Every `recommendations` row needs `vibe_ids` to show
up filtered on a vibe page.

Row Level Security is enabled on every table from the start, same
convention as the other project: `profiles`/`experiences`/`reflections`
are scoped to `auth.uid()`, `vibes`/`recommendations` are read-only
reference data.

Reflection submission goes through a `submit_reflection` Postgres
function (also in the migration) instead of two separate client calls, so
the reflection insert and the experience's status flip to `'reflected'`
happen in one transaction.

## Visual system

`core/theme/` is the whole design system in four files:
- `app_colors.dart` — a warm, editorial light/dark palette plus a curated
  8-color "vibe palette" used to give each vibe a distinct accent
  deterministically (hashed from its name), without users picking colors.
- `app_typography.dart` — Fraunces (serif, warm, editorial) for anything
  that should feel considered, paired with Inter for everything
  functional. This pairing does most of the work of making the app feel
  intentional rather than another feed.
- `app_spacing.dart` — a 4pt spacing scale and the corner-radius scale
  (generously rounded, matching the soft/warm visual language).
- `app_theme.dart` — builds `ThemeData` from the above; exposes the extra
  semantic colors Material's `ColorScheme` doesn't have (`surfaceMuted`,
  `textSecondary`, `accentSoft`) via a `ThemeExtension`, reached with
  `context.appColors`.

`core/widgets/` has the handful of primitives everything else is built
from: `PictureCard` (the masonry tile — full-bleed photo, gradient scrim,
title), `VibeChip`, `GlassNavBar` (the one deliberate, sparing use of
glassmorphism — a frosted bottom nav), `EmptyState`, `PtButton`.

## Not built yet

Deliberately out of scope for this pass — each is a real feature, not a
stub:

- **The AI learning/recommendation engine** (Pillar 4). Reflections are
  captured and stored; nothing reads them back into ranking yet.
  Recommendations are hand-seeded, not generated or personalized.
- **"Apply this vibe" day-builder.** The button currently just filters
  Discover to that vibe — generating a full day (breakfast → night
  routine) needs the recommendation engine first.
- **Daily AI suggestions**, **AI Companion insights** ("You've become more
  adventurous"), **AI memory**.
- **Community** (sharing, following, voting on others' content), **Maps**,
  **Timeline/"searchable life"**, **Collections**.
- **Apple Sign-In** — not wired into `AuthService` yet; it needs an Apple
  Developer account and capability configuration this environment can't
  do. Supabase supports it as an OAuth provider once that exists.
- **Email confirmation UI.** If your Supabase project has "Confirm email"
  enabled (the default), a new sign-up won't have an active session until
  the user clicks the confirmation link, but there's no in-app screen for
  that yet (unlike the other project's `/verify` OTP flow) — the app will
  just look like sign-up silently did nothing. Simplest fix for now:
  disable "Confirm email" in Supabase Auth settings while building; add a
  verify screen before shipping.
- **Offline sync beyond Supabase's own local cache.** `supabase_flutter`
  does not persist queries offline the way Firestore does automatically —
  a deliberately-designed offline-first experience (local cache, optimistic
  UI while offline) is not built.
- **Native platform folders** (`android/`, `ios/`, `web/`) — see
  `docs/SETUP.md`.
