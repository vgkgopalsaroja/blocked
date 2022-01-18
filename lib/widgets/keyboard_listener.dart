// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:slide/bloc/keyboard/keyboard_bloc.dart';

// class KeyboardListener extends StatefulWidget {
//   const KeyboardListener({Key? key, required this.child}) : super(key: key);

//   final Widget child;

//   @override
//   State<KeyboardListener> createState() => _KeyboardListenerState();
// }

// class _KeyboardListenerState extends State<KeyboardListener> {
//   final FocusNode focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     HardwareKeyboard.instance.addHandler((event) {
//       final key = event.logicalKey;
//       final keyboardBloc = context.read<KeyboardBloc>();

//       if (key == LogicalKeyboardKey.arrowLeft) {
//         keyboardBloc.add(LeftKeyPressed());
//         return true;
//       } else if (key == LogicalKeyboardKey.arrowRight) {
//         keyboardBloc.add(RightKeyPressed());
//         return true;
//       } else if (key == LogicalKeyboardKey.arrowUp) {
//         keyboardBloc.add(UpKeyPressed());
//         return true;
//       } else if (key == LogicalKeyboardKey.arrowDown) {
//         keyboardBloc.add(DownKeyPressed());
//         return true;
//       }

//       return false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     focusNode.requestFocus();
//     return widget.child;
//   }
// }
