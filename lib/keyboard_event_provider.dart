import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'keyboard/bloc/keyboard_bloc.dart';

class KeyboardEventProvider extends StatelessWidget {
  KeyboardEventProvider({Key? key, required this.child}) : super(key: key);

  final Widget child;
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    return BlocProvider(
      create: (context) => KeyboardBloc(),
      child: Builder(
        builder: (context) {
          return KeyboardListener(
            autofocus: true,
            focusNode: focusNode,
            onKeyEvent: (event) {
              final key = event.logicalKey;
              final keyboardBloc = context.read<KeyboardBloc>();

              if (event is KeyDownEvent) {
                if (key == LogicalKeyboardKey.arrowLeft ||
                    key == LogicalKeyboardKey.arrowRight ||
                    key == LogicalKeyboardKey.arrowUp ||
                    key == LogicalKeyboardKey.arrowDown) {
                  keyboardBloc.add(KeyPressedEvent(key));
                }
              } else if (event is KeyUpEvent) {
                if (key == keyboardBloc.state.latestKey) {
                  keyboardBloc.add(KeyReleasedEvent(key));
                }
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}
