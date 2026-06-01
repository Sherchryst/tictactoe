import 'cell.dart';

enum Player {
  human,
  cpu;

  Cell get cell {
    return switch (this) {
      Player.human => Cell.human,
      Player.cpu => Cell.cpu,
    };
  }

  Player get opponent {
    return switch (this) {
      Player.human => Player.cpu,
      Player.cpu => Player.human,
    };
  }
}
