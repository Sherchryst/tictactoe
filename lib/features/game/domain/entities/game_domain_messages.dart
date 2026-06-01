final class GameDomainMessages {
  const GameDomainMessages._();

  static const emptyCellHasNoPlayer = 'Empty cells do not belong to a player.';
  static const noMoveAvailable = 'No move available.';

  static String cellNotPlayable(int index) {
    return 'Cell $index is not playable.';
  }
}
