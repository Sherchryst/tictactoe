# Tic Tac Toe

Application Flutter de Tic Tac Toe inspirée d'Elden Ring.

Le jeu reste volontairement simple: un duel local sur une grille 3x3. Tout ce
qui l'entoure a en revanche été travaillé comme une vraie mini-application:
écrans cinématiques, audio, préférences persistées, score, localisation,
design system et garde-fous d'architecture.

## Fonctionnalités

- Duel local en 3x3.
- Mode `NEW DUEL`: joueur contre joueur sur le même appareil.
- Mode `NEW GAME`: joueur contre CPU.
- Difficultés CPU:
  - `Guided`: coup légal aléatoire.
  - `No Mercy`: stratégie minimax déterministe.
- Score persistant pour les parties joueur contre CPU.
- Réinitialisation du score via `Rest at Grace`.
- Réglages persistants: musique, effets sonores, volumes et langue.
- Interface localisée en anglais, français, espagnol et allemand.
- Flux complet: splash, écran titre, menu, loading, partie, fin de partie,
  score et système.
- Audio via `just_audio`: musique en boucle, transitions, SFX préchauffés et
  volume de sortie plafonné.
- Build web compatible Firebase Hosting.

## Stack

- Flutter / Dart
- `hooks_riverpod` + génération Riverpod
- `go_router`
- `freezed`
- `json_serializable`
- `shared_preferences`
- `just_audio`
- `flutter_localizations`
- `mockito`
- `import_lint`

Le projet cible le SDK Dart `^3.11.4`. L'environnement actuel a été vérifié
avec Flutter `3.41.6` et Dart `3.11.4`.

## Installation

Depuis un clone propre:

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Exemples de cibles:

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d ios
```

Pour lancer sur un vrai iPhone, la signature Xcode doit être configurée avec
une équipe Apple Development et un provisioning profile valides.

## Commandes qualité

```bash
dart format --set-exit-if-changed lib test
flutter analyze
dart run import_lint
flutter test
```

Après modification de providers, modèles Freezed, DTO JSON ou mocks:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Après modification des fichiers `.arb`:

```bash
flutter gen-l10n
```

## Architecture

Le projet suit une architecture par features, avec des dépendances orientées
vers le domaine.

```text
lib/
├── main.dart                         # Point d'entrée Flutter
├── app.dart                          # MaterialApp, thème, locale, router
├── l10n/                             # Sources de traduction ARB
│   ├── app_en.arb
│   ├── app_fr.arb
│   ├── app_es.arb
│   └── app_de.arb
├── core/
│   ├── audio/
│   │   ├── domain/                   # Préférences, intents, contrats audio
│   │   ├── data/                     # Repository local des préférences audio
│   │   └── infrastructure/           # just_audio, cache, session audio
│   ├── design_system/
│   │   ├── theme/                    # AppTheme, AppPalette
│   │   ├── tokens/                   # Assets, spacing, durées, typo, etc.
│   │   └── widgets/                  # Widgets UI partagés
│   ├── di/                           # Providers Riverpod transverses
│   ├── router/                       # Routes go_router et transitions
│   └── storage/                      # Abstraction KeyValueStorage
└── features/
    ├── shell/
    │   └── presentation/             # Splash, title, home, loading
    ├── game/
    │   ├── domain/                   # Entités, règles, CPU, use cases
    │   ├── data/                     # Scoreboard local
    │   └── presentation/             # Page de jeu, board, dialogs, contrôleurs
    └── settings/
        ├── domain/                   # AppPreferences, use cases
        ├── data/                     # Persistance locale des préférences
        └── presentation/             # Écran système, audio, langue
```

Les règles principales:

- `domain` reste pur Dart: pas de Flutter, Riverpod, router, storage concret ou DTO.
- `data` implémente les repositories et gère la sérialisation/persistance.
- `presentation` contient widgets, hooks, contrôleurs Riverpod, dialogs et animations.
- `core/di` assemble les dépendances concrètes.
- `core/design_system` reste indépendant des features.

Les routes principales:

```text
/ → /title → /home → /game/loading → /game
              └──→ /settings
```

## Domaine du jeu

Le domaine du jeu se trouve dans `lib/features/game/domain`.

- `Board`: grille immuable de neuf cellules.
- `GameRules`: détection des victoires, égalités et parties en cours.
- `PlayMove`: applique un coup valide.
- `PlayHumanMove`: joue le coup humain puis déclenche le CPU si nécessaire.
- `PlayCpuTurn`: choisit la stratégie CPU selon la difficulté.
- `RandomCpuStrategy`: difficulté `Guided`.
- `MinimaxCpuStrategy`: difficulté `No Mercy`.
- `Scoreboard`: compteur des victoires, défaites, égalités et parties jouées.

Le `GameController` enregistre le score uniquement en mode joueur contre CPU.
Les duels joueur contre joueur ne modifient pas le scoreboard.

## Persistance

La persistance passe par `KeyValueStorage`, implémenté avec
`SharedPreferencesAsync`.

Données persistées:

- scoreboard solo;
- préférences audio;
- langue sélectionnée.

Cette abstraction permet de tester les repositories avec un storage en mémoire
sans importer `shared_preferences` dans les couches métier ou présentation.

## Audio

La présentation déclenche des intentions audio, pas des chemins d'assets.

- Menu: `MenuSfx.select`, `MenuSfx.activate`, `MenuSfx.reset`.
- Musique: `MusicTrack.menu`, `MusicTrack.game`.
- Partie: coup joué, parry, victoire, mort, égalité, redémarrage.

`AppAudioController` mappe ces intentions vers `AppAssets`. La musique passe
par un player en boucle avec fade. Les SFX utilisent un petit pool de players
pour permettre les sons courts rapprochés.

## Localisation

La configuration Flutter se trouve dans `l10n.yaml`.

```text
lib/l10n/
├── app_en.arb
├── app_fr.arb
├── app_es.arb
└── app_de.arb
```

Les fichiers générés `app_localizations*.dart` ne sont pas versionnés. Ils se
regénèrent avec:

```bash
flutter gen-l10n
```

La langue par défaut est l'anglais, même si la langue système est différente.
Le choix utilisateur est stocké dans `AppPreferences.localePreference`.

## Code généré

Ces fichiers sont ignorés par Git:

- `*.freezed.dart`
- `*.g.dart`
- `lib/l10n/app_localizations*.dart`
- sorties de build Flutter

Commande de régénération complète:

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

`build.yaml` limite la génération Mockito aux fichiers de test et de support.

## Tests

```text
test/
├── core/audio/                       # Audio domain/data/infrastructure
├── features/game/                    # Domaine, data et contrôleurs du jeu
├── features/settings/                # Préférences et contrôleurs settings
├── testing/                          # Mocks, stubs, storage mémoire
└── widget_test.dart
```

Les tests suivent les couches de l'application:

- domaine: entités, règles, stratégies CPU, use cases;
- data: DTO, data sources, repositories;
- présentation: contrôleurs Riverpod et états exposés.

## Garde-fous d'imports

`import_lint.yaml` protège les frontières principales:

- le domaine des features ne dépend pas de Flutter, Riverpod, data ou présentation;
- la data ne dépend pas de la présentation;
- la présentation n'importe pas les implémentations data;
- `core/audio/domain` reste indépendant de l'infrastructure;
- `core/design_system` reste indépendant des features;
- `features/settings` ne dépend pas de `features/game`.

À lancer avec:

```bash
dart run import_lint
```

## Web et Firebase

Firebase Hosting sert le build web depuis `build/web` et redirige toutes les
routes vers `index.html`, ce qui permet aux routes `go_router` de fonctionner
au refresh.

```bash
flutter build web --release
firebase deploy --only hosting
```

## Assets

Les assets exposés à l'application sont centralisés dans `AppAssets`. Les
fichiers sources vivent dans `assets/elden_ring/` et sont déclarés dans
`pubspec.yaml`.
