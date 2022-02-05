import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/model/position.dart';

class EditorBuilderBloc extends Bloc<EditorBuilderEvent, EditorBuilderState> {
  EditorBuilderBloc() : super(const EditorBuilderState.initial()) {
    on<PointDown>(_onPointDown);
    on<PointUp>(_onPointUp);
    on<PointUpdate>(_onPointUpdate);
    on<PointCancelled>(_onPointCancelled);
  }


  void _onPointUpdate(PointUpdate event, Emitter<EditorBuilderState> emit) {
    emit(state.copyWith(
      hoveredPosition: event.position,
    ));
  }

  void _onPointCancelled(
      PointCancelled event, Emitter<EditorBuilderState> emit) {
    emit(state.copyWith(
      hoveredPosition: null,
      start: null,
      end: null,
    ));
  }

  void _onPointDown(PointDown event, Emitter<EditorBuilderState> emit) {
    if (state._start == null) {
      emit(state.copyWith(
        start: event.position,
      ));
    } else {
      // emit(state.copyWith(
      //   end: state._snappedHoveredPosition,
      // ));
      // emit(state.copyWith(
      //   start: null,
      //   end: null,
      // ));
    }
  }

  void _onPointUp(PointUp event, Emitter<EditorBuilderState> emit) {
    if (state._start != null) {
      emit(state.copyWith(
        end:state.hoveredPosition!,
      ));
      emit(state.copyWith(
        start: null,
        end: null,
      ));
    }
  }
}

class EditorBuilderState {
  static const _invalidPosition = Position(-1, -1);

  const EditorBuilderState.initial()
      : _start = null,
        _end = null,
        hoveredPosition = null;
  const EditorBuilderState(
      {Position? start, Position? end, this.hoveredPosition})
      : _start = start,
        _end = end;

  Position? get start => _start ?? hoveredPosition;
  Position? get end => _end ?? _snappedHoveredPosition;
  bool get isObjectPlaced => _start != null && _end != null;

  final Position? _start;
  final Position? _end;
  final Position? hoveredPosition;

  Position? get _snappedHoveredPosition {
    if (false && hoveredPosition != null && start != null) {
      Position snappedVerticalPosition = hoveredPosition!.copyWith(x: start!.x);
      Position snappedHorizontalPosition =
          hoveredPosition!.copyWith(y: start!.y);
      int verticalLength = (hoveredPosition!.y - start!.y).abs();
      int horizontalLength = (hoveredPosition!.x - start!.x).abs();
      return verticalLength > horizontalLength
          ? snappedVerticalPosition
          : snappedHorizontalPosition;
    } else {
      return hoveredPosition;
    }
  }

  EditorBuilderState copyWith({
    Position? start = _invalidPosition,
    Position? end = _invalidPosition,
    Position? hoveredPosition = _invalidPosition,
  }) {
    return EditorBuilderState(
      start: start != _invalidPosition ? start : _start,
      end: end != _invalidPosition ? end : _end,
      hoveredPosition: hoveredPosition != _invalidPosition
          ? hoveredPosition
          : this.hoveredPosition,
    );
  }
}

abstract class EditorBuilderEvent {
  const EditorBuilderEvent();
}

class PointUpdate extends EditorBuilderEvent {
  const PointUpdate(this.position);

  final Position position;
}

class PointCancelled extends EditorBuilderEvent {
  const PointCancelled();
}

class PointDown extends EditorBuilderEvent {
  const PointDown(this.position);

  final Position position;
}

class PointUp extends EditorBuilderEvent {
  const PointUp(this.position);

  final Position position;
}
