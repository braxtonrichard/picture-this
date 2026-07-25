# Setup

This scaffold was written by hand (the sandbox that generated it doesn't
have the Flutter SDK installed), so one thing you'd normally get for free
from `flutter create` still needs to happen on your own machine before it
runs.

## 1. Generate the native platform folders

`android/`, `ios/`, and `web/` are intentionally not committed — they're
large, toolchain-generated, and version-specific. Generate them in place:

```bash
flutter create . --org com.pictureThis --project-name picture_this
```

If it asks to overwrite `pubspec.yaml` or `analysis_options.yaml`, say
**no** — those are already configured for this project (dependencies,
lint rules).

Then:

```bash
flutter pub get
```

## 2. Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and create a new project.
2. **SQL Editor** → paste and run `supabase/migrations/0001_init.sql`.
   This creates `profiles`, `vibes`, `recommendations`, `experiences`,
   `reflections` — all with Row Level Security enabled and policies
   scoping user data to `auth.uid()` — plus the `handle_new_user` trigger
   and `submit_reflection` function. (If you use the Supabase CLI instead,
   `supabase db push` works the same way.)
3. **Authentication → Providers** → enable **Email** and **Google**.
   - For Google, see step 4 below — it needs one extra piece of config
     beyond just flipping the provider on.
   - Apple Sign-In isn't wired into the app yet (see
     `docs/ARCHITECTURE.md`), so skip it for now.
4. **Important for testing right away:** Authentication → Sign In / Providers
   (or Auth settings, depending on your Supabase dashboard version) →
   turn **off** "Confirm email". With it on, a new sign-up won't have an
   active session until the user clicks a confirmation link, and this
   pass doesn't have a verify-email screen yet — sign-up will look like it
   silently failed. Turn it back on (and build a verify screen) before
   shipping to real users.

## 3. Google sign-in setup

The app uses Google's native sign-in SDK and exchanges the resulting ID
token for a Supabase session (`signInWithIdToken`) — this needs one OAuth
**Web** client shared between Google Cloud and Supabase:

1. [Google Cloud Console](https://console.cloud.google.com) → APIs &
   Services → Credentials → create an **OAuth 2.0 Client ID** of type
   **Web application** (even though the app is mobile — this is the
   client ID Supabase verifies the ID token against).
2. Copy that Web client ID into:
   - Supabase Dashboard → Authentication → Providers → Google → **Client
     IDs** field.
   - `GOOGLE_WEB_CLIENT_ID` in your `.env` (step 5 below).
3. You'll also need a separate Android/iOS OAuth client ID per platform
   for `google_sign_in` itself to work natively — see the
   [google_sign_in package docs](https://pub.dev/packages/google_sign_in)
   for the platform-specific setup (SHA-1 fingerprint for Android,
   URL scheme for iOS).

This is genuinely the fiddliest part of setup. Skipping it is fine —
email/password sign-up still works without it.

## 4. Seed some content

Discover and the onboarding vibe picker read from the empty `vibes` and
`recommendations` tables. Add a few rows via the Supabase dashboard's
Table Editor, or the SQL editor:

```sql
insert into public.vibes (name, description, cover_image_url, tags)
values (
  'Coastal Grandmother',
  'Linen, salt air, an afternoon that has nowhere to be.',
  'https://images.unsplash.com/photo-...',
  array['coastal', 'relaxed', 'neutral-tones']
);

insert into public.recommendations (title, category, image_url, description, vibe_ids)
values (
  'Big Little Lies',
  'tvShow',
  'https://images.unsplash.com/photo-...',
  'Coastal drama with exactly the right amount of linen.',
  array[(select id from public.vibes where name = 'Coastal Grandmother')]
);
```

## 5. Configure the app's environment

Copy the example env file and fill in your project's URL and key
(Supabase Dashboard → Project Settings → API):

```bash
cp .env.example .env
```

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-or-publishable-key
GOOGLE_WEB_CLIENT_ID=your-google-oauth-web-client-id   # optional, see step 3
```

`.env` is gitignored — never commit real credentials.

## 6. Run it

```bash
flutter run
```

Pick a simulator/device when prompted.
