import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeyboardBloc extends Bloc<KeyboardEvent, KeyboardState> {
  KeyboardBloc() : super(const KeyboardState(null)) {
    on<KeyPressedEvent>(_onKeyPressed);
    on<KeyReleasedEvent>(_onKeyReleased);
  }

  void _onKeyPressed(KeyPressedEvent event, Emitter emit) {
    emit(KeyboardState(event.key));
  }

  void _onKeyReleased(KeyReleasedEvent event, Emitter emit) {
    emit(const KeyboardState(null));
  }
}

class KeyboardState {
  const KeyboardState(this.latestKey);

  final LogicalKeyboardKey? latestKey;
}

enum KeyType { up, down, left, right }

abstract class KeyboardEvent {
  const KeyboardEvent(this.key);

  final LogicalKeyboardKey key;
}

class KeyPressedEvent extends KeyboardEvent {
  const KeyPressedEvent(LogicalKeyboardKey key) : super(key);
}

class KeyReleasedEvent extends KeyboardEvent {
  const KeyReleasedEvent(LogicalKeyboardKey key) : super(key);
}
