#!/usr/bin/env bash
# Vercel's build image doesn't have Flutter, so this fetches a pinned SDK
# build, then does what `flutter run` normally does for you locally:
# fetch packages, write the .env asset flutter_dotenv reads at startup
# (from Vercel Environment Variables, not a committed file), and build
# the web release. See vercel.json for how this gets wired up, and
# docs/SETUP.md for which env vars to set in the Vercel project.
set -euo pipefail

FLUTTER_VERSION="3.27.1"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  curl -sSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -o /tmp/flutter.tar.xz
  tar xf /tmp/flutter.tar.xz -C "$HOME"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics
flutter pub get

{
  echo "SUPABASE_URL=${SUPABASE_URL:-}"
  echo "SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}"
  echo "GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID:-}"
} > .env

flutter build web --release
