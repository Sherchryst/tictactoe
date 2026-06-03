# Tic Tac Toe

An Elden Ring inspired Tic Tac Toe prototype built with Flutter.

The app keeps the game rules simple and local: a 3x3 duel can be played as
Human vs CPU or Human vs Human. The presentation layer is intentionally more
cinematic, with title/splash screens, menu transitions, themed audio, persisted
settings, localized copy, and score tracking.

## Features

- Local Tic Tac Toe on a 3x3 board
- Human vs CPU and Human vs Human modes
- CPU difficulties: easy, hard
- Persisted scoreboard, audio preferences, and language preference
- Localized UI copy in English, French, Spanish, and German
- English is the default app locale, independent from the system locale
- Themed title flow, loading flow, game board, settings, dialogs, splash, icons, audio, and visual effects
- Iconic visual strings stay untranslated: `Tic Tac Toe`, `YOU DIED`, `GOD SLAIN`

## Run

Generated files are reproducible local build outputs. Regenerate them before
running the app or checks from a fresh clone.

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run
```

For a real iPhone, Xcode signing must be configured with a valid Apple
Development team and provisioning profile for the app bundle identifier.

## Quality Checks

```bash
dart format --set-exit-if-changed lib test
flutter analyze
dart run import_lint
flutter test
```

When changing generated models or Riverpod providers, run:

```bash
dart run build_runner build
```

When changing translations, run:

```bash
flutter gen-l10n
```

## Localization

Flutter's official localization pipeline is configured through `l10n.yaml`.

```text
lib/l10n/
├── app_en.arb
├── app_fr.arb
├── app_es.arb
└── app_de.arb
```

Visible UI copy goes through `GameCopy.of(context)` so widgets stay decoupled
from raw generated localization classes. `GameCopy` is a thin facade over
three resolvers that handle the structured logic:

- `PlayerLabelResolver` — score, turn, and win labels per `(Player, GameMode)`
- `GameStatusResolver` — board status string per `(GameResult, Player, GameMode)`
- `SystemHelpResolver` — focus-aware help copy for the settings screen

The selected language is stored in `AppPreferences.localePreference` and can
be changed from `SYSTEM > Language`. The app deliberately starts in English by
default instead of following the device locale.

## Architecture

The project follows Clean Architecture with feature-first organization and
dependencies pointing inward. Wiring lives in `lib/app/`, shared building
blocks in `lib/core/`, and feature modules in `lib/features/`.

```text
lib/
├── app/
│   ├── di/            # Riverpod providers wiring concrete dependencies
│   └── router/        # GoRouter configuration
├── core/
│   ├── assets/        # Asset path constants
│   ├── design/        # Design tokens (spacing, radius, durations, ...)
│   ├── storage/       # KeyValueStorage abstraction + SharedPreferences impl
│   ├── theme/         # AppTheme, AppPalette
│   └── ui/            # Shared widgets (AppPressable, AppIconButton, hero tags)
├── features/
│   └── game/
│       ├── domain/
│       │   ├── entities/     # Pure data + intents (MenuSfx, MusicTrack, ...)
│       │   ├── repositories/ # Abstract repository contracts
│       │   ├── services/     # GameRules, CpuStrategy, MusicPlayer, SfxPlayer
│       │   └── usecases/     # StartGame, PlayMove, PlayCpuTurn, ...
│       ├── data/
│       │   ├── datasources/  # KeyValueStorage adapters and storage keys
│       │   ├── models/       # JSON DTOs
│       │   ├── repositories/ # Concrete repositories with mutation queues
│       │   └── services/     # JustAudio music/sfx players, asset cache, etc.
│       └── presentation/
│           ├── controllers/  # Riverpod notifiers / view-state controllers
│           ├── copy/         # Resolvers backing GameCopy
│           ├── dialogs/      # Modal flows
│           ├── pages/        # Top-level screens
│           ├── settings/     # Settings sub-feature
│           └── widgets/      # Reusable UI components
└── l10n/
```

### Domain

Pure Dart. No Flutter, Riverpod, storage, routing, or DTO imports.

It owns the business concepts (`Board`, `GameSession`, `Scoreboard`, ...), the
abstract repositories, the gameplay services (`GameRules`, CPU strategies,
`CpuStrategyResolver`), the audio service contracts (`MusicPlayer`, `SfxPlayer`,
`AudioSettingsRepository`), and the use cases:

- `StartGame`, `StartNewRound`
- `PlayMove`, `PlayCpuTurn`, `PlayHumanMove` (composed from the previous two)
- `LoadScoreboard`, `RecordGameOutcome`, `ResetScoreboard`
- `LoadPreferences`, `SavePreferences`

### Data

Implements domain repository contracts and audio service contracts. JSON
mapping goes through `json_serializable` DTOs and persistence relies on the
abstract `KeyValueStorage`. Repositories serialize concurrent writes through a
small mutation queue to avoid lost updates. Audio playback is split into:

- `JustAudioMusicPlayer` — single-track playback with cross-fade transitions
- `JustAudioSfxPlayer` — short-effect playback through a small player pool
- `AudioAssetCache` — caches asset existence checks
- `AudioSessionConfigurator` — configures the platform `AudioSession` once
- `LocalAudioSettingsRepository` — persists `GameAudioSettings`

### Presentation

Flutter UI, hooks, and Riverpod controllers. Presentation depends on use cases
through `app/di/game_dependencies.dart`, never on concrete repositories.

The splash, title, home, loading, game, and settings screens all live under
the game presentation layer. There is no separate `home` feature because it
would not own domain behavior; it would only wrap navigation.

Local animation and transient visual state stay in hooks. App state,
repositories, settings, audio orchestration, and game state are owned by
Riverpod providers/controllers.

## Design System

`lib/design_system/tokens/` exposes atomic tokens (spacing, radius, durations,
curves, alphas, shadows, gradients, typography, breakpoints, animations) and
bundles them into an `AppTokens` `ThemeExtension` registered by
`AppTheme.dark()` (`lib/design_system/theme/`). Reusable widgets live under
`lib/design_system/widgets/`. `lib/core/` keeps only framework-agnostic
infrastructure (storage abstraction, asset path constants).

Widgets read tokens through `AppPalette`, `AppShadows`, `AppTypography`, etc.
instead of hard-coding colors, durations, or shadows.

Typography uses two font families:

- `AppPalette.titleFont = 'Mantinia'` — bundled display face
- `AppPalette.serifFont = 'serif'` — system serif fallback (resolves per platform)

## State Management

The app uses `hooks_riverpod` with Riverpod code generation.

- `@riverpod` providers wire dependencies, controllers, and use cases.
- `HookConsumerWidget` is used where widgets need both providers and local hook state.
- `HookWidget` is used for purely local animated widgets.
- Domain logic remains framework-free.

## Audio Intents

Presentation never names a concrete asset or volume. UI screens dispatch
stable intents on the audio controller:

- `playMenuSfx(MenuSfx.select | activate | reset)` for menu interactions
- `playTrack(MusicTrack.menu | game)` for music transitions

In-game intents (`playMove`, `playParry`, `playVictory`, `playDeath`,
`playDeathIntro`, `playDraw`, `playRestart`) live on the same `AudioController`
interface and are consumed by `GameAudioEffects`.

## CPU Strategies

- Easy: random legal move
- Hard: minimax, deterministic and tested

`CpuStrategyResolver` maps `GameDifficulty` to a concrete strategy and is
injected through Riverpod, which keeps tests free to swap strategies.

## Architecture Guards

`import_lint` runs from `import_lint.yaml` and prevents boundary violations:

- domain cannot import data, presentation, Flutter, Riverpod, GoRouter, or SharedPreferences
- data cannot import presentation, Flutter widgets/material, or GoRouter
- presentation cannot import data implementations directly (audio controller exempted)

## Generated Code Policy

`*.freezed.dart` and `*.g.dart` are ignored by Git. They are reproducible
build outputs and must be regenerated with:

```bash
dart run build_runner build
```

Flutter localization output is regenerated with:

```bash
flutter gen-l10n
```

## Non-Regression Notes

Gameplay, audio timings, animation timings, navigation transitions, dialogs,
layout, and visual style are intentionally treated as stable behavior. Changes
to localization or settings should not alter the duel flow unless the change
is explicitly requested.
