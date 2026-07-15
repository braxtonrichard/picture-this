# Setup

This scaffold was written by hand (the sandbox that generated it doesn't
have the Flutter SDK installed), so two things you'd normally get for free
from `flutter create` still need to happen on your own machine before it
runs.

## 1. Generate the native platform folders

`android/`, `ios/`, and `web/` are intentionally not committed — they're
large, toolchain-generated, and version-specific. Generate them in place:

```bash
flutter create . --org com.pictureThis --project-name picture_this
```

Run this from the repo root. It only adds the platform folders and a few
top-level files (`analysis_options.yaml`, `pubspec.yaml`, etc.) —
answer "yes" if it asks to overwrite `analysis_options.yaml`/`pubspec.yaml`
only if you want Flutter's defaults; otherwise skip those two and keep
the ones already in the repo, since they're already configured for this
project (lint rules, dependencies).

Then:

```bash
flutter pub get
```

## 2. Create a Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com) and
   create a new project (e.g. "Picture This").
2. Enable **Authentication** → Sign-in providers: **Email/Password** and
   **Google**. (Apple Sign-In needs an Apple Developer account — see
   `docs/ARCHITECTURE.md`'s "Not built yet" for why it's not wired up
   yet.)
3. Create a **Firestore** database (start in production mode, then apply
   the security rules from `docs/ARCHITECTURE.md`).
4. Enable **Storage** (default rules are fine to start; user-uploaded
   photos aren't wired into the UI yet in this pass).

## 3. Connect the Flutter app to Firebase

Install the FlutterFire CLI once, globally:

```bash
dart pub global activate flutterfire_cli
```

Then, from the repo root:

```bash
flutterfire configure
```

Pick the Firebase project you just created, and the platforms you want
(iOS/Android/Web). This generates the real `lib/firebase_options.dart`
(gitignored — it's project-specific) and the platform config files
(`google-services.json` / `GoogleService-Info.plist`, also gitignored).
`lib/firebase_options.example.dart` shows the shape of the generated file
if you want to sanity-check it.

## 4. Seed some content

Discover and the onboarding vibe picker read from the `vibes` and
`recommendations` Firestore collections, which start empty. Add a few
documents by hand in the Firestore console to see the app populated — the
exact field shape is documented in `docs/ARCHITECTURE.md`'s "Data model"
section. A minimal vibe:

```json
// vibes/{autoId}
{
  "name": "Coastal Grandmother",
  "description": "Linen, salt air, an afternoon that has nowhere to be.",
  "coverImageUrl": "https://images.unsplash.com/photo-...",
  "tags": ["coastal", "relaxed", "neutral-tones"]
}
```

```json
// recommendations/{autoId}
{
  "title": "Big Little Lies",
  "category": "tvShow",
  "imageUrl": "https://images.unsplash.com/photo-...",
  "description": "Coastal drama with exactly the right amount of linen.",
  "vibeIds": ["<the vibe doc id above>"]
}
```

## 5. Run it

```bash
flutter run
```

## Google Sign-In extra step

`google_sign_in` needs the OAuth client from the Firebase console's
Authentication → Sign-in method → Google provider (Firebase sets this up
for you when you enable the provider) — no extra manual OAuth console work
needed for Android/iOS. For web, you'll additionally need the web client
ID in `web/index.html` per the
[google_sign_in web setup docs](https://pub.dev/packages/google_sign_in)
if you build for web.
