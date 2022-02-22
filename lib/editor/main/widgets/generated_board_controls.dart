import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide/models/puzzle/puzzle.dart';

import 'package:slide/puzzle/puzzle.dart';
import 'package:slide/solver/solver.dart';

class GeneratedBoardControls extends StatelessWidget {
  const GeneratedBoardControls(this.mapString, {Key? key}) : super(key: key);

  final String mapString;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          message: 'Back to editor (Esc)',
          child: TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
            onPressed: () {
              context.read<LevelNavigation>().onExit();
            },
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                  text: '- name: generated\n'
                      '  map: |-\n'
                      '${mapString.split('\n').map((line) => '    $line').join('\n')}'),
            );
          },
          icon: const Icon(MdiIcons.contentCopy),
          label: const Text('YAML'),
          style: TextButton.styleFrom(
            primary: Theme.of(context).hintColor,
          ),
        ),
        Tooltip(
          message: 'Reset (R)',
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<LevelBloc>().add(const LevelReset());
            },
            label: const Text('Reset'),
          ),
        ),
        TextButton(
          child: const Text('Solve'),
          onPressed: () {
            final moves =
                PuzzleSolver(context.read<LevelBloc>().initialState.puzzle)
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
          },
        ),
        TextButton(
          onPressed: () async {
            final moves =
                PuzzleSolver(context.read<LevelBloc>().initialState.puzzle)
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
          },
          child: const Text('Play solution'),
        ),
      ],
    );
  }
}
