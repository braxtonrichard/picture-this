# Picture This

An AI lifestyle operating system for self-discovery — not another feed.
Choose a vibe, get recommendations, actually go experience them, reflect,
and let the app learn who you are over time. Full product vision:
[`docs/VISION.md`](docs/VISION.md).

This repo is the first build pass: a Flutter/Firebase skeleton with the
core loop — **Discover → Experience → Reflect** — wired end to end, plus
auth, onboarding, and a profile. It does not yet include the AI learning
engine, the "Apply this vibe" day-builder, community, or maps — see
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for exactly what's built
and what's deliberately deferred.

## Stack

- Flutter (iOS + Android from one codebase)
- Firebase Auth (Email + Google; Apple documented but not wired up),
  Firestore, Storage
- Riverpod for state, go_router for navigation
- Design system built on Fraunces + Inter, a warm editorial color
  palette, and a Pinterest-style masonry Discover feed — see
  [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#visual-system)

## Getting started

The sandbox this scaffold was written in has no Flutter SDK, so the
native `android/`/`ios`/`web` folders and the Firebase connection aren't
generated yet. Full steps: [`docs/SETUP.md`](docs/SETUP.md). Short
version:

```bash
flutter create . --org com.pictureThis --project-name picture_this
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
flutter run
```

## Docs

- [`docs/VISION.md`](docs/VISION.md) — the founder vision, verbatim
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — folder structure,
  state management, Firestore data model, security rules, what's not
  built yet
- [`docs/SETUP.md`](docs/SETUP.md) — full local setup, including seeding
  content so Discover isn't empty
