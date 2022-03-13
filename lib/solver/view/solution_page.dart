import 'package:blocked/level/level.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SolutionPage extends StatefulWidget {
  SolutionPage(
      {Key? key, required LevelState initialState, required this.solution})
      : super(key: key) {
    final solutionStates = [initialState];
    for (final move in solution) {
      final nextState = solutionStates.last.withMoveAttempt(MoveAttempt(move));
      solutionStates.add(nextState);
    }
    this.solutionStates = solutionStates;
  }

  final List<MoveDirection> solution;
  late final List<LevelState> solutionStates;

  @override
  State<SolutionPage> createState() => _SolutionPageState();
}

class _SolutionPageState extends State<SolutionPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => LevelBloc(widget.solutionStates.first),
        child: Column(
          children: [
            const Center(child: FittedBox(child: Puzzle())),
            Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'Solution',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final isInitialState = index == 0;
                            final isEndState =
                                index == widget.solutionStates.length - 1;
                            final state = widget.solutionStates[index];
                            final move = isInitialState
                                ? null
                                : widget.solution[index - 1];
                            return ListTile(
                              selected: selectedIndex == index,
                              leading: !isInitialState
                                  ? isEndState
                                      ? const Icon(Icons.flag)
                                      : Icon(_directionToIcon(move!))
                                  : const Icon(Icons.start),
                              title: Text(
                                isInitialState ? 'Start' : 'Move ${move!.name}',
                              ),
                              onTap: () {
                                context
                                    .read<LevelBloc>()
                                    .add(LevelStateSet(state));
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              // subtitle: Text(
                              //   '${state.moveAttempts.length} moves',
                              // ),
                            );
                          },
                          itemCount: widget.solutionStates.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _directionToIcon(MoveDirection direction) {
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
