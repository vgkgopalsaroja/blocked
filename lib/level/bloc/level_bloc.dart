import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/level_reader.dart';

part 'level_event.dart';

class LevelBloc extends Bloc<LevelEvent, LevelData?> {
  final List<LevelData> levels;

  LevelBloc(this.levels, LevelData? initialState) : super(initialState) {
    on<LevelChosen>(_onLevelChosen);
    on<LevelExited>(_onLevelExited);
    on<NextLevel>(_onNextLevel);
  }

  void _onLevelExited(LevelExited event, Emitter<LevelData?> emit) {
    emit(null);
  }

  void _onLevelChosen(LevelChosen event, Emitter<LevelData?> emit) {
    emit(event.level);
  }

  void _onNextLevel(NextLevel event, Emitter<LevelData?> emit) {
    if (state == null) {
      emit(levels[0]);
    } else {
      int nextIndex = levels.indexOf(state!) + 1;
      if (nextIndex < levels.length) {
        emit(levels[nextIndex]);
      } else {
        emit(null);
      }
    }
  }

  LevelData? getLevelWithId(String id) {
    Iterable<LevelData> matchingLevels =
        levels.where((level) => level.name == id);
    if (matchingLevels.length == 1) {
      return matchingLevels.first;
    } else {
      return null;
    }
  }
}
