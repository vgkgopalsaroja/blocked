import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';

class PuzzleShortcutListener extends StatelessWidget {
  const PuzzleShortcutListener({
    Key? key,
    required this.puzzleBloc,
    required this.child,
  }) : super(key: key);

  final PuzzleBloc puzzleBloc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 0) {
          puzzleBloc.add(const MoveAttempt(MoveDirection.right));
        } else if ((details.primaryVelocity ?? 0) < 0) {
          puzzleBloc.add(const MoveAttempt(MoveDirection.left));
        }
      },
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 0) {
          puzzleBloc.add(const MoveAttempt(MoveDirection.down));
        } else if ((details.primaryVelocity ?? 0) < 0) {
          puzzleBloc.add(const MoveAttempt(MoveDirection.up));
        }
      },
      child: FocusableActionDetector(
        autofocus: true,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.keyR): PuzzleIntent(PuzzleReset()),
          SingleActivator(LogicalKeyboardKey.escape):
              PuzzleIntent(PuzzleExited()),
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
          SingleActivator(LogicalKeyboardKey.enter): PuzzleIntent(NextPuzzle()),
        },
        actions: {
          PuzzleIntent: CallbackAction<PuzzleIntent>(onInvoke: (intent) {
            return puzzleBloc.add(intent.puzzleEvent);
          }),
        },
        child: child,
      ),
    );
  }
}

class PuzzleIntent extends Intent {
  const PuzzleIntent(this.puzzleEvent);

  final PuzzleEvent puzzleEvent;
}
