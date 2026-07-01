# CI/CD – automatisk APK-build (macOS-server)

Pipeline som bygger en ny APK varje gång något pushas till `master` (inklusive när en PR mergas).

## Flöde

```text
Push/merge till master
        │
        ▼
GitHub Actions (self-hosted runner på din Mac)
        │
        ▼
scripts/server-build.sh
        │
        ├── flutter build apk --release
        ├── sparar versionerad APK i repot (build/)
        ├── kopierar till ~/jaxpokedex-releases/
        └── laddar upp APK som GitHub-artifact
```

## 1. Förbered macOS-servern

### Installera verktyg (Homebrew)

```bash
# Homebrew (om det saknas)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Java + Android CLI-verktyg
brew install openjdk@17 android-commandlinetools

# Flutter (om det saknas)
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
```

### Miljövariabler i `~/.zshrc`

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$HOME/flutter/bin:/opt/homebrew/bin:$PATH"
```

Ladda om:

```bash
source ~/.zshrc
```

### Android SDK-komponenter (engångs)

```bash
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

### Flutter-konfiguration (engångs)

```bash
flutter config --jdk-dir="$JAVA_HOME"
flutter config --android-sdk "$ANDROID_HOME"
flutter doctor --android-licenses
flutter doctor -v
```

### Signering

Kopiera samma `debug.keystore` som på din utvecklings-Mac:

```bash
mkdir -p ~/.android
# Kopiera debug.keystore hit (samma fil på alla datorer som bygger)
```

### CI-miljöfil (rekommenderas för runner)

```bash
cd jaxpokedex
cp scripts/macos-ci-env.example.sh scripts/macos-ci-env.sh
```

`server-build.sh` läser automatiskt `scripts/macos-ci-env.sh` om den finns. Det är viktigt för self-hosted runnern, som inte alltid laddar `~/.zshrc`.

### Testa bygget manuellt

```bash
git clone https://github.com/Neerav83/jaxpokedex.git
cd jaxpokedex
cp scripts/macos-ci-env.example.sh scripts/macos-ci-env.sh
bash scripts/server-build.sh
```

## 2. Installera self-hosted GitHub Actions runner (macOS)

På server-Macen:

1. GitHub → **Settings** → **Actions** → **Runners** → **New self-hosted runner**
2. Välj **macOS** och **ARM64** (Apple Silicon) eller **x64** (Intel)
3. Följ GitHubs kommandon i en terminal

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
# Ladda ner runner enligt GitHubs instruktioner, t.ex.:
# curl -o actions-runner-osx-arm64-....tar.gz -L https://github.com/...
# tar xzf ./actions-runner-osx-arm64-....tar.gz

./config.sh --url https://github.com/Neerav83/jaxpokedex --token <TOKEN>
./svc.sh install
./svc.sh start
./svc.sh status
```

Kontrollera att runnern syns som **Idle** under **Settings → Actions → Runners**.

Tips:

- Kör runnern under samma användare som har Flutter/Java/Android SDK installerat
- Macen måste vara vaken (eller konfigurerad att inte somna) för att byggen ska köras
- `scripts/macos-ci-env.sh` i repot gör att PATH fungerar även när runnern startas som tjänst

## 3. Vad som händer vid push till master

Workflow-filen `.github/workflows/build-android.yml` körs automatiskt och:

1. Checkar ut senaste koden
2. Kör `scripts/server-build.sh`
3. Laddar upp APK som artifact i GitHub Actions (hålls i 30 dagar)

Artifacts hittar du under: **Actions** → vald körning → **Artifacts**.

Färdiga APK:er kopieras även till `~/jaxpokedex-releases/` på servern.

## 4. Alternativ: SSH-deploy (utan self-hosted runner)

Om du inte vill installera en runner kan du använda `.github/workflows/deploy-ssh.yml`.

Lägg till secrets under **Settings** → **Secrets and variables** → **Actions**:

| Secret | Exempel (macOS) |
|--------|-----------------|
| `SERVER_HOST` | `192.168.1.50` eller `mac-mini.local` |
| `SERVER_USER` | `tommierundberg` |
| `SERVER_SSH_KEY` | Privat SSH-nyckel |
| `SERVER_DEPLOY_PATH` | `/Users/tommierundberg/jaxpokedex` |

Kör workflow manuellt via **Actions** → **Deploy and build via SSH** → **Run workflow**.

## 5. Miljövariabler (valfritt)

| Variabel | Standard | Beskrivning |
|----------|----------|-------------|
| `JAXPOKEDEX_RELEASES_DIR` | `~/jaxpokedex-releases` | Var versionerade APK:er kopieras |

## 6. Manuell build

Du kan alltid trigga bygget manuellt:

**Actions** → **Build Android APK** → **Run workflow**

## Felsökning (macOS)

| Problem | Lösning |
|---------|---------|
| `Unable to locate a Java Runtime` | Sätt `JAVA_HOME` i `macos-ci-env.sh` |
| `No Android SDK found` | Kör `flutter config --android-sdk "$ANDROID_HOME"` |
| Runner köar men startar inte jobb | Kontrollera att runnern är **Idle** på GitHub |
| APK-signatur skiljer sig | Samma `~/.android/debug.keystore` på alla datorer |
