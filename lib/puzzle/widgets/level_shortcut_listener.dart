import 'package:blocked/level/level.dart';
import 'package:blocked/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LevelShortcutListener extends StatelessWidget {
  LevelShortcutListener({
    Key? key,
    required this.levelBloc,
    required this.child,
  }) : super(key: key);

  final LevelBloc levelBloc;
  final Widget child;

  static const puzzleShortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.keyR): PuzzleIntent(LevelReset()),
    SingleActivator(LogicalKeyboardKey.arrowLeft):
        PuzzleIntent(MoveAttempt(MoveDirection.left)),
    SingleActivator(LogicalKeyboardKey.arrowRight):
        PuzzleIntent(MoveAttempt(MoveDirection.right)),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        PuzzleIntent(MoveAttempt(MoveDirection.up)),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        PuzzleIntent(MoveAttempt(MoveDirection.down)),
    SingleActivator(LogicalKeyboardKey.keyW):
        PuzzleIntent(MoveAttempt(MoveDirection.up)),
    SingleActivator(LogicalKeyboardKey.keyA):
        PuzzleIntent(MoveAttempt(MoveDirection.left)),
    SingleActivator(LogicalKeyboardKey.keyS):
        PuzzleIntent(MoveAttempt(MoveDirection.down)),
    SingleActivator(LogicalKeyboardKey.keyD):
        PuzzleIntent(MoveAttempt(MoveDirection.right)),
  };

  static final levelShortcuts = {
    const SingleActivator(LogicalKeyboardKey.enter):
        LevelNavigationIntent((levelNavigation) {
      levelNavigation.onNext();
    }),
    const SingleActivator(LogicalKeyboardKey.escape):
        LevelNavigationIntent((levelNavigation) {
      levelNavigation.onExit();
    }),
  };

  static final shortcuts = <ShortcutActivator, Intent>{
    ...puzzleShortcuts,
    ...levelShortcuts,
  };

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 0) {
          levelBloc.add(const MoveAttempt(MoveDirection.right));
        } else if ((details.primaryVelocity ?? 0) < 0) {
          levelBloc.add(const MoveAttempt(MoveDirection.left));
        }
      },
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 0) {
          levelBloc.add(const MoveAttempt(MoveDirection.down));
        } else if ((details.primaryVelocity ?? 0) < 0) {
          levelBloc.add(const MoveAttempt(MoveDirection.up));
        }
      },
      child: FocusableActionDetector(
        focusNode: focusNode,
        autofocus: true,
        shortcuts: shortcuts,
        actions: {
          PuzzleIntent: CallbackAction<PuzzleIntent>(onInvoke: (intent) {
            return levelBloc.add(intent.puzzleEvent);
          }),
          LevelNavigationIntent: CallbackAction<LevelNavigationIntent>(
            onInvoke: (intent) {
              return intent
                  .levelNavigationCallback(context.read<LevelNavigation>());
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class PuzzleIntent extends Intent {
  const PuzzleIntent(this.puzzleEvent);

  final LevelEvent puzzleEvent;
}

class LevelNavigationIntent extends Intent {
  const LevelNavigationIntent(this.levelNavigationCallback);

  final void Function(LevelNavigation) levelNavigationCallback;
}
