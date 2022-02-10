import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';

class GeneratedBoardControls extends StatelessWidget {
  const GeneratedBoardControls(this.mapString, {Key? key}) : super(key: key);

  final String mapString;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        context.select((PuzzleBloc bloc) => bloc.state.isCompleted);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to editor (Esc)',
          onPressed: () {
            context.read<PuzzleBloc>().add(const PuzzleExited());
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset (R)',
          onPressed: () {
            context.read<PuzzleBloc>().add(const PuzzleReset());
          },
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
          label: const Text('Copy YAML'),
        ),
        if (isCompleted) ...{
          const Spacer(),
          ElevatedButton.icon(
            label: const Text('Next (Enter)'),
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              context.read<PuzzleBloc>().add(const NextPuzzle());
            },
          ),
        }
      ],
    );
  }
}
