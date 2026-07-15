# Architecture

This first pass builds the **skeleton and core loop only** — Discover →
Experience → Reflect, with auth and a profile — not the AI learning
engine, social features, vibe day-builder, maps, or collections described
in `docs/VISION.md`. Those are real, deliberate scope cuts, not
oversights; see "Not built yet" at the bottom.

## Folder structure

```
lib/
  main.dart              — Firebase init, runApp
  app.dart                — MaterialApp.router, theme wiring
  firebase_options.example.dart  — template; real file is gitignored
  core/
    theme/                — colors, typography, spacing, ThemeData
    router/                — the single GoRouter (auth-aware redirects)
    widgets/                — shared design-system widgets
    models/                — plain Dart data classes (Vibe, Recommendation,
                              Experience, Reflection, UserProfile)
    services/                — AuthService, FirestoreService — the only
                                code that talks to Firebase directly
  features/
    auth/                  — welcome, sign in, sign up
    onboarding/                — first-vibe picker
    home/                — the bottom-nav shell
    discover/                — the vibe feed (Pillar 1)
    vibes/                — a single vibe's page
    experience/                — logging + listing experiments (Pillar 2)
    reflect/                — the reflection form (Pillar 3)
    profile/                — the "fun profile" + sign out
```

Each feature follows `domain/` (models specific to that feature, if any)
/ `data/` (Riverpod providers wrapping `FirestoreService`) /
`presentation/` (screens). Screens never call Firestore directly — they
watch a provider, which calls `FirestoreService`. This is the one seam
Pillar 4 (the learning engine) will plug into later: reflections already
flow through `FirestoreService.submitReflection`, so a recommendation
engine can be added as a Cloud Function or a new service without touching
any screen.

## State management

[Riverpod](https://riverpod.dev) (`flutter_riverpod`), classic (non
code-generated) API. Firestore streams are exposed as `StreamProvider`s
per feature (see `*_providers.dart` under each feature's `data/`
folder) — screens just do `ref.watch(someStreamProvider)` and get an
`AsyncValue` to pattern-match with `.when(...)`.

## Navigation

[go_router](https://pub.dev/packages/go_router), one `GoRouter` in
`core/router/app_router.dart`. It watches `authStateProvider` and
redirects unauthenticated users to `/welcome` and authenticated users away
from the auth routes — no screen re-checks auth itself.

## Data model (Firestore)

```
users/{uid}
  displayName, email, photoUrl
  favoriteVibeIds: string[]
  answers: { [questionId]: string }        — the "fun profile"

  users/{uid}/experiences/{experienceId}
    recommendationId, recommendationTitle, recommendationImageUrl
    status: planned | experienced | reflected
    createdAt, experiencedAt

  users/{uid}/reflections/{reflectionId}
    experienceId
    rating: love | like | neutral | dislike | neverAgain
    wouldRepeat, matchedVibe: bool
    moodBefore, moodAfter: int (1-5)
    journalEntry: string?
    createdAt

vibes/{vibeId}
  name, description, coverImageUrl, tags: string[]

recommendations/{recommendationId}
  title, category (see RecommendationCategory enum), imageUrl,
  description, vibeIds: string[], location?
```

`vibes` and `recommendations` are shared/global collections — there's no
authoring UI for them yet, so seed them directly in the Firestore console
(or via a script) to populate Discover and the vibe picker. Every
`recommendations` doc needs `vibeIds` to show up filtered on a vibe page.

`users/{uid}/experiences` and `.../reflections` are per-user subcollections
so Firestore security rules can scope everything to `request.auth.uid ==
uid` in one rule.

### Suggested security rules (write these before shipping any real data)

```
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
  match /experiences/{id} {
    allow read, write: if request.auth.uid == uid;
  }
  match /reflections/{id} {
    allow read, write: if request.auth.uid == uid;
  }
}
match /vibes/{id} {
  allow read: if request.auth != null;
  allow write: if false; // author these server-side/via console for now
}
match /recommendations/{id} {
  allow read: if request.auth != null;
  allow write: if false;
}
```

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
- **Apple Sign-In** — `sign_in_with_apple` is in `pubspec.yaml` but not
  wired into `AuthService` yet; it needs an Apple Developer account and
  capability configuration this environment can't do.
- **Offline sync beyond Firestore's own built-in offline cache.**
  `cloud_firestore` persists reads/writes locally and syncs automatically
  on reconnect by default on iOS/Android — no extra package needed for
  that baseline. A deliberately-designed offline-first experience (e.g.
  optimistic UI for logging an experience while offline) is not built.
- **Native platform folders** (`android/`, `ios/`, `web/`) — see
  `docs/SETUP.md`.
