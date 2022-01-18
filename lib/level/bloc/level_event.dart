part of 'level_bloc.dart';

abstract class LevelEvent {
  const LevelEvent();
}

class LevelExited extends LevelEvent {
  const LevelExited();
}

class LevelChosen extends LevelEvent {
  const LevelChosen(this.level);
  final LevelData level;
}

class NextLevel extends LevelEvent {
  const NextLevel();
}
