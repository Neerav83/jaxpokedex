#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/scripts/macos-ci-env.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/scripts/macos-ci-env.sh"
elif [[ -f "$ROOT_DIR/scripts/macos-ci-env.example.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/scripts/macos-ci-env.example.sh"
fi

log() {
  printf '[server-build] %s\n' "$*"
}

setup_java() {
  if command -v java >/dev/null 2>&1; then
    return
  fi

  if [[ "$(uname -s)" == "Darwin" ]] && [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
    return
  fi

  if [[ -n "${JAVA_HOME:-}" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
    export PATH="$JAVA_HOME/bin:$PATH"
    return
  fi

  log "Java hittades inte. Installera JDK 17 och sätt JAVA_HOME."
  exit 1
}

setup_android_sdk() {
  if [[ -n "${ANDROID_HOME:-}" ]]; then
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    return
  fi

  if [[ "$(uname -s)" == "Darwin" ]] && [[ -d /opt/homebrew/share/android-commandlinetools ]]; then
    export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    return
  fi

  if [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    return
  fi

  log "Android SDK hittades inte. Sätt ANDROID_HOME."
  exit 1
}

read_version() {
  grep '^version:' pubspec.yaml | sed 's/version:[[:space:]]*//'
}

log "Projekt: $ROOT_DIR"
setup_java
setup_android_sdk

if ! command -v flutter >/dev/null 2>&1; then
  log "Flutter hittades inte i PATH."
  exit 1
fi

log "Flutter: $(flutter --version | head -n 1)"
log "Java: $(java -version 2>&1 | head -n 1)"
log "ANDROID_HOME: $ANDROID_HOME"

flutter pub get
flutter build apk --release

VERSION="$(read_version)"
OUTPUT_DIR="$ROOT_DIR/build/app/outputs/flutter-apk"
VERSIONED_APK="$OUTPUT_DIR/jaxpokedex-${VERSION}.apk"
cp "$OUTPUT_DIR/app-release.apk" "$VERSIONED_APK"

RELEASES_DIR="${JAXPOKEDEX_RELEASES_DIR:-$HOME/jaxpokedex-releases}"
mkdir -p "$RELEASES_DIR"
cp "$VERSIONED_APK" "$RELEASES_DIR/"

WEB_DEPLOY_DIR="${JAXPOKEDEX_WEB_DEPLOY_DIR:-}"
if [[ -n "$WEB_DEPLOY_DIR" ]]; then
  mkdir -p "$WEB_DEPLOY_DIR"
  cp "$VERSIONED_APK" "$WEB_DEPLOY_DIR/jaxpokedex-${VERSION}.apk"
  cp "$VERSIONED_APK" "$WEB_DEPLOY_DIR/jaxpokedex.apk"
  log "Webdeploy: $WEB_DEPLOY_DIR/jaxpokedex.apk"
  log "Webdeploy (versionerad): $WEB_DEPLOY_DIR/jaxpokedex-${VERSION}.apk"
else
  log "Ingen webdeploy (sätt JAXPOKEDEX_WEB_DEPLOY_DIR i macos-ci-env.sh)."
fi

log "Klar."
log "APK: $OUTPUT_DIR/app-release.apk"
log "Versionerad kopia: $VERSIONED_APK"
log "Publicerad kopia: $RELEASES_DIR/$(basename "$VERSIONED_APK")"
