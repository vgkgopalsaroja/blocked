import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/model/position.dart';

class WallBuilderBloc extends Bloc<WallBuilderEvent, WallBuilderState> {
  WallBuilderBloc() : super(const WallBuilderState.initial()) {
    on<PointHovered>(_onPointHovered);
    on<PointPressed>(_onPointPressed);
    on<PointReleased>(_onPointReleased);
  }

  void _onPointHovered(PointHovered event, Emitter<WallBuilderState> emit) {
    emit(state.copyWith(
      hoveredPosition: event.position,
    ));
  }

  void _onPointPressed(PointPressed event, Emitter<WallBuilderState> emit) {
    emit(state.copyWith(
      start: event.position,
      end: event.position,
    ));
  }

  void _onPointReleased(PointReleased event, Emitter<WallBuilderState> emit) {
    emit(state.copyWith(
      end: event.position,
    ));
  }
}

class WallBuilderState {
  const WallBuilderState.initial()
      : start = null,
        end = null,
        hoveredPosition = null;
  const WallBuilderState({this.start, this.end, this.hoveredPosition});

  final Position? start;
  final Position? end;
  final Position? hoveredPosition;

  WallBuilderState copyWith({
    Position? start,
    Position? end,
    Position? hoveredPosition,
  }) {
    return WallBuilderState(
      start: start ?? this.start,
      end: end ?? this.end,
      hoveredPosition: hoveredPosition ?? this.hoveredPosition,
    );
  }
}

abstract class WallBuilderEvent {}

class PointHovered extends WallBuilderEvent {
  PointHovered(this.position);

  final Position position;
}

class PointPressed extends WallBuilderEvent {
  PointPressed(this.position);

  final Position position;
}

class PointReleased extends WallBuilderEvent {
  PointReleased(this.position);

  final Position position;
}
