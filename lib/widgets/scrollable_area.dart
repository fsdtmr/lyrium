import 'package:flutter/material.dart';

class ScrollableArea extends StatelessWidget {
  final Widget child;
  const ScrollableArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width + 500,
          child: child,
        ),
      ),
    );
  }
}
