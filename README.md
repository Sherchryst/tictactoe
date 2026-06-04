# Tic Tac Toe

Application Flutter de Tic Tac Toe inspirée d'Elden Ring.

Le coeur reste une grille 3x3, mais l'application porte maintenant plusieurs
flows de jeu: duel local, essai guidé contre CPU et run No Mercy contre les
boss. Tout ce qui l'entoure a été travaillé comme une vraie mini-application:
écrans cinématiques, audio, préférences persistées, score, localisation,
design system et garde-fous d'architecture.

## Fonctionnalités

- Grille de jeu 3x3.
- Mode `NEW DUEL`: joueur contre joueur sur le même appareil.
- Mode `NEW GAME`: choix entre `GUIDED` et `NO MERCY`.
- Mode `GUIDED`: duel joueur contre CPU avec coup légal aléatoire.
- Mode `NO MERCY`: run contre Radahn, Mohg puis Malenia, avec patterns de boss,
  progression persistée, continue, NG+ et crédits déblocables.
- Record Tarnished persistant pour les combats No Mercy.
- Réinitialisation du score via `REST AT GRACE`, avec confirmation configurable.
- Réglages persistants: musique, effets sonores, volumes, langue et
  confirmation de reset score.
- Interface localisée en anglais, français, espagnol et allemand.
- Flux complet: splash, écran titre, home menu, loading de partie, jeu, fin de
  partie, score, crédits et système.
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
dart run build_runner build
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
dart run build_runner build
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
│   ├── preferences/                  # Préférences app partagées
│   ├── router/                       # Routes go_router et transitions
│   └── storage/                      # Abstraction KeyValueStorage
└── features/
    ├── launch/
    │   └── presentation/             # Splash et écran titre
    ├── game/
    │   ├── domain/                   # Entités, règles, CPU, use cases
    │   ├── data/                     # Scoreboard et run No Mercy locaux
    │   └── presentation/             # Home, loading, jeu, score, dialogs
    └── settings/
        └── presentation/             # Écran système, audio, langue
```

Les règles principales:

- `domain` reste pur Dart: pas de Flutter, Riverpod, router, storage concret ou DTO.
- `data` implémente les repositories et gère la sérialisation/persistance.
- `presentation` contient widgets, hooks, contrôleurs Riverpod, dialogs et animations.
- `core/di` assemble les dépendances concrètes.
- `core/design_system` reste indépendant des features.
- `core/preferences` porte les préférences partagées entre l'app et l'écran système.

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
- `PlayCpuTurn`: choisit la stratégie CPU selon le mode.
- `RandomCpuStrategy`: CPU de l'essai `GUIDED`.
- `BossPuzzleCpuStrategy`: patterns déterministes des boss No Mercy.
- `NoMercyRunProgression`: enchaînement Radahn → Mohg → Malenia et cycles NG+.
- `Scoreboard`: record Tarnished agrégé depuis les scores par boss.

Le `GameController` enregistre le score uniquement pour les combats No Mercy.
Les duels locaux et l'essai guidé ne modifient pas le scoreboard.

## Persistance

La persistance passe par `KeyValueStorage`, implémenté avec
`SharedPreferencesAsync`.

Données persistées:

- scoreboard No Mercy;
- progression No Mercy;
- préférences audio;
- langue sélectionnée;
- préférence de confirmation du reset score.

Cette abstraction permet de tester les repositories avec un storage en mémoire
sans importer `shared_preferences` dans les couches métier ou présentation.

## Audio

La présentation déclenche des intentions audio, pas des chemins d'assets.

- Menu: `MenuSfx.select`, `MenuSfx.activate`, `MenuSfx.reset`.
- Musique: `MusicTrack.menu`, `MusicTrack.recusants` et musiques de boss.
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
dart run build_runner build
```

`build.yaml` limite la génération Mockito aux fichiers de test et de support.

## Tests

```text
test/
├── core/audio/                       # Audio domain/data/infrastructure
├── core/preferences/                 # Préférences app partagées
├── features/game/                    # Domaine, data et contrôleurs du jeu
├── features/settings/                # Écran système et contrôleurs settings
├── testing/                          # Mocks, stubs, storage mémoire
└── widget_test.dart
```

Les tests suivent les couches de l'application:

- domaine: entités, règles, stratégies CPU, use cases;
- data: DTO, data sources, repositories;
- présentation: contrôleurs Riverpod, dialogs, pages, widgets et smoke tests
  layout compact/desktop.

## Garde-fous d'imports

`import_analysis_options.yaml` protège les frontières principales:

- le domaine des features ne dépend pas de Flutter, Riverpod, data ou présentation;
- la data ne dépend pas de la présentation;
- la présentation n'importe pas les implémentations data;
- `core/audio/domain` reste indépendant de l'infrastructure;
- `core/preferences/domain` reste indépendant de la data et des features;
- `core/design_system` reste indépendant des features;
- `features/settings` et `features/game` ne dépendent pas directement l'une de l'autre.

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
