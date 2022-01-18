part of 'level_bloc.dart';

abstract class LevelEvent {
  const LevelEvent();
}

class LevelExited extends LevelEvent {
  const LevelExited();
}

class LevelChosen extends LevelEvent {
  const LevelChosen(this.level);
  final Level level;
}

class NextLevel extends LevelEvent {
  const NextLevel();
}
