import 'package:async/async.dart';
import 'package:blocked/editor/editor.dart';
import 'package:blocked/models/puzzle/puzzle.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:blocked/routing/routing.dart';
import 'package:blocked/solver/solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BoardControls extends StatefulWidget {
  const BoardControls({Key? key})
      : mapString = null,
        super(key: key);
  const BoardControls.generated(this.mapString, {Key? key}) : super(key: key);

  final String? mapString;

  @override
  State<BoardControls> createState() => _BoardControlsState();
}

class _BoardControlsState extends State<BoardControls> {
  CancelableOperation? solutionOperation;

  @override
  void dispose() {
    solutionOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        context.select((LevelBloc bloc) => bloc.state.isCompleted);
    return MultiBlocListener(
      listeners: [
        BlocListener<PuzzleSolverBloc, PuzzleSolverState>(
          listenWhen: (previous, current) =>
              !previous.hasSolutionResult && current.hasSolutionResult,
          listener: (context, state) {
            final moves = state.solution;

            if (moves == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No solution found')));
              return;
            }

            ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                content:
                    const Text('Solution viewed. Reload level to save progress.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => ScaffoldMessenger.of(context)
                        .hideCurrentMaterialBanner(
                            reason: MaterialBannerClosedReason.hide),
                  ),
                ]));
          },
        ),
        BlocListener<PuzzleSolverBloc, PuzzleSolverState>(
          listenWhen: (previous, current) =>
              !previous.isSolutionViewed && current.isSolutionViewed,
          listener: (context, state) {
            final moves = state.solution;
            if (moves == null) {
              return;
            }
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

            final controller = Scaffold.of(context).showBottomSheet(
              (context) => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Icon(
                  directionToIcon(moves[index]),
                ),
                itemCount: moves.length,
              ),
              constraints: const BoxConstraints(
                maxHeight: 48,
              ),
            );

            controller.closed.then((_) {
              context.read<PuzzleSolverBloc>().add(SolutionHidden());
            });
          },
        ),
      ],
      child: Builder(builder: (context) {
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
                      context.read<PuzzleSolverBloc>().add(SolutionViewed());
                      break;
                    case 'play_solution':
                      context.read<PuzzleSolverBloc>().add(SolutionPlayed());
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
              const Spacer(),
              if (widget.mapString != null) ...{
                Tooltip(
                  message: 'Copy as YAML',
                  child: AdaptiveTextButton(
                    icon: const Icon(MdiIcons.contentCopy),
                    label: const Text('YAML'),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                            text: '- name: generated\n'
                                '  map: |-\n'
                                '${widget.mapString!.split('\n').map((line) => '    $line').join('\n')}'),
                      );
                    },
                  ),
                ),
                Tooltip(
                  message: 'Copy shareable link',
                  child: AdaptiveTextButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                            text:
                                'https://slide.jeffsieu.com/#/editor/generated/${encodeMapString(widget.mapString!)}'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied link to clipboard'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Copy link'),
                  ),
                ),
              },
              if (widget.mapString == null)
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
      }),
    );
  }
}