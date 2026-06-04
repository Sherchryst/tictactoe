enum HomeMenuAction { continueRun, duel, solo, score, system, credits }

List<HomeMenuAction> homeMenuActionsFor({
  required bool showContinue,
  required bool showCredits,
}) {
  return [
    if (showContinue) HomeMenuAction.continueRun,
    HomeMenuAction.solo,
    HomeMenuAction.duel,
    HomeMenuAction.score,
    HomeMenuAction.system,
    if (showCredits) HomeMenuAction.credits,
  ];
}

HomeMenuAction firstHomeMenuAction({
  required bool showContinue,
  required bool showCredits,
}) {
  return homeMenuActionsFor(
    showContinue: showContinue,
    showCredits: showCredits,
  ).first;
}
