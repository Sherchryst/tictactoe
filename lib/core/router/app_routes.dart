final class AppRoutes {
  const AppRoutes._();

  static const splashPath = '/';
  static const titlePath = '/title';
  static const homePath = '/home';
  static const settingsPath = '/settings';
  static const gameLoadingPath = '/game/loading';
  static const gamePath = '/game';

  static const splashLocation = splashPath;
  static const titleLocation = titlePath;
  static const titleFromCreditsLocation = '$titlePath?fromCredits=1';
  static const homeLocation = homePath;
  static const settingsLocation = settingsPath;
  static const gameLoadingLocation = gameLoadingPath;
  static const gameLocation = gamePath;
}
