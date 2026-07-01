# Kopiera till macos-ci-env.sh på build-servern (macOS):
#   cp scripts/macos-ci-env.example.sh scripts/macos-ci-env.sh
#
# macos-ci-env.sh bör INTE committas om den innehåller hemliga sökvägar.
# Lägg gärna samma rader i ~/.zshrc på servern också.

export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$HOME/flutter/bin:/opt/homebrew/bin:$PATH"

# Valfritt: annan mapp för färdiga APK:er
# export JAXPOKEDEX_RELEASES_DIR="$HOME/jaxpokedex-releases"

# Webserver – APK kopieras hit efter varje build
export JAXPOKEDEX_WEB_DEPLOY_DIR="/Users/tommierundberg/webserver/localserver/jaxpokedex"
