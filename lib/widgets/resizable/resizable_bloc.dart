part of 'resizable.dart';

class ResizableBloc extends Bloc<ResizeEvent, ResizableState> {
  ResizableBloc({
    required double top,
    required double left,
    required double width,
    required double height,
    this.snapSizeDelegate,
    this.snapOffsetDelegate,
    this.snapWhileResizing = false,
    this.snapWhileMoving = false,
  })  : assert(
          snapSizeDelegate != null || !snapWhileResizing,
          'snapSizeDelegate must be provided if snapWhileDragging is set to true.',
        ),
        assert(
          snapOffsetDelegate != null || !snapWhileMoving,
          'snapOffsetDelegate must be provided if snapWhilePanning is set to true.',
        ),
        super(ResizableState(
            top: top, left: left, bottom: top + height, right: left + width)) {
    on<Resize>(_onResize);
    on<ResizeCorner>(_onResizeCorner);
    on<Pan>(_onPan);
    on<ResizeEnd>(_onResizeEnd);
    on<PanEnd>(_onPanEnd);
  }

  final SnapSizeDelegate? snapSizeDelegate;
  final SnapOffsetDelegate? snapOffsetDelegate;
  final bool snapWhileResizing;
  final bool snapWhileMoving;

  void _onResize(Resize event, Emitter<ResizableState> emit) {
    switch (event.side) {
      case BoxSide.top:
        emit(state.copyWith(
          top: state.internalPosition.top + event.delta,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      case BoxSide.left:
        emit(state.copyWith(
          left: state.internalPosition.left + event.delta,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      case BoxSide.bottom:
        emit(state.copyWith(
          bottom: state.internalPosition.bottom + event.delta,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      case BoxSide.right:
        emit(state.copyWith(
          right: state.internalPosition.right + event.delta,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      default:
    }
  }

  void _onResizeCorner(ResizeCorner event, Emitter<ResizableState> emit) {
    switch (event.side) {
      case BoxSide.topLeft:
        emit(state.copyWith(
          top: state.internalPosition.top + event.delta.dy,
          left: state.internalPosition.left + event.delta.dx,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      case BoxSide.topRight:
        emit(state.copyWith(
          top: state.internalPosition.top + event.delta.dy,
          right: state.internalPosition.right + event.delta.dx,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      case BoxSide.bottomLeft:
        emit(state.copyWith(
          bottom: state.internalPosition.bottom + event.delta.dy,
          left: state.internalPosition.left + event.delta.dx,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
          sideToAdjust: event.side,
        ));
        break;
      case BoxSide.bottomRight:
        emit(state.copyWith(
          bottom: state.internalPosition.bottom + event.delta.dy,
          right: state.internalPosition.right + event.delta.dx,
          sideToAdjust: event.side,
          sizeSnapper: snapSizeDelegate?.sizeSnapper,
          offsetSnapper: snapOffsetDelegate?.offsetSnapper,
        ));
        break;
    }
  }

  void _onPan(Pan event, Emitter<ResizableState> emit) {
    Offset delta = event.delta;
    emit(state.copyWith(
      top: state.internalPosition.top + delta.dy,
      left: state.internalPosition.left + delta.dx,
      bottom: state.internalPosition.bottom + delta.dy,
      right: state.internalPosition.right + delta.dx,
      offsetSnapper: snapOffsetDelegate?.offsetSnapper,
      sizeSnapper: snapSizeDelegate?.sizeSnapper,
      sideToAdjust: BoxSide.bottomRight,
    ));
  }

  void _onPanEnd(PanEnd event, Emitter<ResizableState> emit) {
    if (snapOffsetDelegate != null) {
      final snapOffset = snapOffsetDelegate!.offsetSnapper(Offset(
        state.internalPosition.left,
        state.internalPosition.top,
      ));
      emit(state.copyWith(
        top: snapOffset.dy,
        left: snapOffset.dx,
        sizeSnapper: snapSizeDelegate?.sizeSnapper,
        offsetSnapper: snapOffsetDelegate?.offsetSnapper,
        sideToAdjust: BoxSide.bottomRight,
      ));
    }
  }

  void _onResizeEnd(ResizeEnd event, Emitter<ResizableState> emit) {
    if (snapSizeDelegate != null) {
      final size =
          Size(state.internalPosition.width, state.internalPosition.height);
      final snapSize = snapSizeDelegate!.sizeSnapper(size);
      emit(state.copyWith(
        right: state.internalPosition.left + snapSize.width,
        bottom: state.internalPosition.top + snapSize.height,
        sizeSnapper: snapSizeDelegate?.sizeSnapper,
        offsetSnapper: snapOffsetDelegate?.offsetSnapper,
        sideToAdjust: BoxSide.bottomRight,
      ));
    }
  }
}
