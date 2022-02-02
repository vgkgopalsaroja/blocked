import 'package:flutter/material.dart';

class AnimatedSelectable extends StatelessWidget {
  const AnimatedSelectable(
      {Key? key, required this.isSelected, required this.child})
      : super(key: key);

  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      foregroundDecoration: BoxDecoration(
        color:
            isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(4.0),
        // border: Border.all(
        // color: Theme.of(context).primaryColor,
        // style: isSelected ? BorderStyle.solid : BorderStyle.none,
        // width: 4.0,
        // ),
      ),
      child: child,
    );
  }
}
