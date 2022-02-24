import 'package:blocked/level/level.dart';
import 'package:blocked/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'level_event.dart';
part 'level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  LevelBloc(this.initialState) : super(initialState) {
    on<MoveAttempt>(_onMove);
    on<LevelReset>(_onReset);
  }

  final LevelState initialState;

  void _onMove(MoveAttempt event, Emitter<LevelState> emit) {
    if (!state.isCompleted) {
      emit(state.withMoveAttempt(event));
    }
  }

  void _onReset(LevelReset event, Emitter<LevelState> emit) {
    emit(initialState);
  }
}
