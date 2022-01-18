import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/level.dart';

part 'level_event.dart';

class LevelBloc extends Bloc<LevelEvent, Level?> {
  LevelBloc(Level? initialState) : super(initialState) {
    on<LevelChosen>(_onLevelChosen);
    on<LevelExited>(_onLevelExited);
    on<NextLevel>(_onNextLevel);
  }

  void _onLevelExited(LevelExited event, Emitter<Level?> emit) {
    emit(null);
  }

  void _onLevelChosen(LevelChosen event, Emitter<Level?> emit) {
    emit(event.level);
  }

  void _onNextLevel(NextLevel event, Emitter<Level?> emit) {
    if (state == null) {
      emit(Levels.levels[0]);
    } else {
      int nextIndex = Levels.levels.indexOf(state!) + 1;
      if (nextIndex < Levels.levels.length) {
        emit(Levels.levels[nextIndex]);
      } else {
        emit(null);
      }
    }
  }
}
