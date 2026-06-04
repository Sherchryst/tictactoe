import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';

enum ParticipantKind { human, cpu }

enum HumanPlayerId { playerOne, playerTwo }

sealed class GameParticipant {
  const GameParticipant({required this.mark});

  final Mark mark;

  ParticipantKind get kind;
}

final class HumanParticipant extends GameParticipant {
  const HumanParticipant({required super.mark, required this.playerId});

  final HumanPlayerId playerId;

  @override
  ParticipantKind get kind => ParticipantKind.human;
}

final class CpuParticipant extends GameParticipant {
  const CpuParticipant({required super.mark, required this.bossId});

  final CpuBossId bossId;

  @override
  ParticipantKind get kind => ParticipantKind.cpu;
}
