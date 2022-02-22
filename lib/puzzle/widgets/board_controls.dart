import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide/models/puzzle/puzzle.dart';
import 'package:slide/puzzle/puzzle.dart';
import 'package:slide/solver/solver.dart';

class BoardControls extends StatelessWidget {
  const BoardControls({Key? key})
      : mapString = null,
        super(key: key);
  const BoardControls.generated(this.mapString, {Key? key}) : super(key: key);

  final String? mapString;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        context.select((LevelBloc bloc) => bloc.state.isCompleted);
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PopupMenuButton(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            tooltip: 'Hint',
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'show_steps',
                child: Text('Show steps'),
              ),
              const PopupMenuItem(
                value: 'play_solution',
                child: Text('Play solution'),
              ),
            ],
            onSelected: (String value) async {
              switch (value) {
                case 'show_steps':
                  final moves = PuzzleSolver(
                          context.read<LevelBloc>().initialState.puzzle)
                      .solve();

                  IconData directionToIcon(MoveDirection direction) {
                    switch (direction) {
                      case MoveDirection.up:
                        return Icons.arrow_upward;
                      case MoveDirection.down:
                        return Icons.arrow_downward;
                      case MoveDirection.left:
                        return Icons.arrow_back;
                      case MoveDirection.right:
                        return Icons.arrow_forward;
                    }
                  }

                  Scaffold.of(context).showBottomSheet(
                    (context) => moves != null
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Icon(
                              directionToIcon(moves[index]),
                            ),
                            itemCount: moves.length,
                          )
                        : const Text('No solution found'),
                    constraints: const BoxConstraints(
                      maxHeight: 48,
                    ),
                  );
                  break;
                case 'play_solution':
                  final moves = PuzzleSolver(
                          context.read<LevelBloc>().initialState.puzzle)
                      .solve();

                  if (moves == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No solution found')));
                    return;
                  }

                  for (var move in moves) {
                    context.read<LevelBloc>().add(MoveAttempt(move));
                    await Future.delayed(const Duration(milliseconds: 200));
                  }
                  break;
              }
            },
          ),
          const VerticalDivider(),
          Tooltip(
            message: 'Reset (R)',
            child: TextButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset'),
              onPressed: () {
                context.read<LevelBloc>().add(const LevelReset());
              },
            ),
          ),
          if (mapString != null)
            Tooltip(
              message: 'Copy as YAML',
              child: TextButton.icon(
                icon: const Icon(MdiIcons.contentCopy),
                label: const Text('YAML'),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                        text: '- name: generated\n'
                            '  map: |-\n'
                            '${mapString!.split('\n').map((line) => '    $line').join('\n')}'),
                  );
                },
              ),
            ),
          const Spacer(),
          AnimatedOpacity(
            opacity: isCompleted ? 1.0 : 0.0,
            duration: kSlideDuration,
            child: Tooltip(
              message: 'Next (Enter)',
              child: ElevatedButton.icon(
                label: const Text('Next'),
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  context.read<LevelNavigation>().onNext();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
