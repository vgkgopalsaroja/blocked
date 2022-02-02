import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/puzzle/model/move_direction.dart';

class LevelShortcutListener extends StatelessWidget {
  const LevelShortcutListener({
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
        // manager: LoggingShortcutManager(),
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
        },
        actions: {
          PuzzleIntent: CallbackAction<PuzzleIntent>(onInvoke: (intent) {
            puzzleBloc.add(intent.puzzleEvent);
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

class LevelIntent extends Intent {
  const LevelIntent(this.levelEvent);

  final LevelEvent levelEvent;
}
