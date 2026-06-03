import 'package:flutter/material.dart';

class HomeEntrance extends StatelessWidget {
  const HomeEntrance({
    required this.animation,
    required this.begin,
    required this.end,
    required this.offset,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - curved.value),
              offset.dy * (1 - curved.value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
