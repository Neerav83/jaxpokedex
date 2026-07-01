# JaxPokédex

En Flutter-app för att bläddra bland Pokémon, markera vilka du äger och hålla koll på din samling per generation.

**Version:** 1.2.0+3  
**Paketnamn:** `jax_pokedex`  
**Android applicationId:** `se.tommie.jax_pokedex`

## Funktioner

- **Hem** – Bläddra bland Pokémon filtrerat per generation (Gen I–IX)
- **Pokédex** – Se dina ägda Pokémon grupperade per generation med framsteg (`ägda/totalt`)
- **Sök** – Sök bland alla Pokémon via namn eller nummer
- **Inställningar** – Mörkt läge, rensa ägd data
- **Lokal lagring** – Dina ägda Pokémon sparas på enheten med `shared_preferences`

## Skärmar

| Flik | Beskrivning |
|------|-------------|
| Hem | Generation-chips + rutnät med alla Pokémon i vald generation |
| Pokédex | Hopfällbara generationer med dina ägda Pokémon |
| Search | Sök i hela Pokédexen (alla generationer) |
| Inställningar | Dark mode och rensning av sparad data |

## Teknik

- [Flutter](https://flutter.dev) / Dart
- [Provider](https://pub.dev/packages/provider) – state management
- [PokeAPI](https://pokeapi.co/) – Pokémon-data
- [Google Fonts](https://pub.dev/packages/google_fonts) – Plus Jakarta Sans
- [Shared Preferences](https://pub.dev/packages/shared_preferences) – lokal lagring
- [HTTP](https://pub.dev/packages/http) – API-anrop

## Kom igång

### Krav

- Flutter SDK (3.11+)
- För Android: Android SDK + JDK 17
- För iOS: Xcode (macOS)

### Installation

```bash
git clone https://github.com/Neerav83/jaxpokedex.git
cd jaxpokedex
flutter pub get
```

### Kör appen

```bash
# Välj enhet först
flutter devices

# Kör på vald enhet
flutter run
```

### Bygg APK (Android)

```bash
flutter build apk --release
```

APK-filen hamnar i:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Bygg iOS

```bash
flutter build ios --release
```

## Projektstruktur

```
lib/
├── main.dart                 # App-start och tema
├── models/
│   └── pokemon.dart          # Pokémon-modell
├── providers/
│   └── pokemon_provider.dart # State, API och lokal lagring
├── screens/
│   ├── main_screen.dart      # Bottom navigation
│   ├── home_screen.dart      # Hem med generation-filter
│   ├── pokedex_screen.dart   # Ägda Pokémon per generation
│   ├── search_screen.dart    # Sök
│   └── settings_screen.dart  # Inställningar
├── services/
│   └── api_service.dart      # PokeAPI-integration
└── widgets/
    └── pokemon_card.dart     # Pokémon-kort med gilla-knapp
```

## Data & API

Appen hämtar Pokémon från [PokeAPI](https://pokeapi.co/api/v2/pokemon) och stödjer **1025 Pokémon** (Gen I–IX). Bilder kommer från PokeAPI:s officiella artwork-sprites.

Generationerna definieras i `lib/services/api_service.dart`:

| Generation | Antal |
|------------|-------|
| Gen I | 151 |
| Gen II | 100 |
| Gen III | 135 |
| Gen IV | 107 |
| Gen V | 156 |
| Gen VI | 72 |
| Gen VII | 88 |
| Gen VIII | 96 |
| Gen IX | 120 |

## CI/CD (automatisk APK-build, macOS-server)

Vid push eller merge till `master` bygger GitHub Actions en ny APK på din Mac (self-hosted runner).

Se [docs/ci-setup.md](docs/ci-setup.md) för macOS-setup.

```bash
cp scripts/macos-ci-env.example.sh scripts/macos-ci-env.sh
bash scripts/server-build.sh
```

## Licens

Detta är ett personligt projekt. Pokémon och relaterade tillgångar tillhör Nintendo/Game Freak/The Pokémon Company.
