import 'package:slide/puzzle/level_reader.dart';
import 'package:collection/collection.dart';

part 'level_event.dart';

class LevelList {
  final List<LevelData> levels;

  LevelList(this.levels);

  LevelData? getLevelWithId(String id) {
    return levels.where((level) => level.name == id).firstOrNull;
  }

  LevelData? getLevelAfterId(String id) {
    return levels.skipWhile((level) => level.name != id).skip(1).firstOrNull;
  }
}

// class LevelBloc extends Bloc<LevelEvent, LevelData?> {
//   final LevelList levelList;

//   LevelBloc(List<Level>, LevelData? initialState) : super(initialState) {
//     on<LevelChosen>(_onLevelChosen);
//     on<LevelExited>(_onLevelExited);
//     on<NextLevel>(_onNextLevel);
//   }

//   void _onLevelExited(LevelExited event, Emitter<LevelData?> emit) {
//     emit(null);
//   }

//   void _onLevelChosen(LevelChosen event, Emitter<LevelData?> emit) {
//     emit(event.level);
//   }

//   void _onNextLevel(NextLevel event, Emitter<LevelData?> emit) {
//     if (state == null) {
//       emit(levels[0]);
//     } else {
//       int nextIndex = levels.indexOf(state!) + 1;
//       if (nextIndex < levels.length) {
//         emit(levels[nextIndex]);
//       } else {
//         emit(null);
//       }
//     }
//   }

// }
