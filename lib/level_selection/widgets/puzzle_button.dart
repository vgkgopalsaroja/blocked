import 'package:flutter/material.dart';

class LabeledPuzzleButton extends StatelessWidget {
  const LabeledPuzzleButton({
    Key? key,
    required this.label,
    required this.puzzle,
    this.onPressed,
  }) : super(key: key);

  final Widget label;
  final Widget puzzle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: FittedBox(
                  child: puzzle,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: label,
            ),
          ),
        ],
      ),
    );
  }
}
