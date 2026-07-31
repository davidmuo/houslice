import 'package:flutter/material.dart';

/// A scroll view whose child is stretched to at least the viewport height.
///
/// Several screens lay their content out with a [Spacer] so a button sits at
/// the bottom on a tall phone. A [Spacer] needs a bounded height, which a plain
/// [SingleChildScrollView] cannot give, and a plain [Column] overflows the
/// moment the viewport is shorter than the content — which is exactly what
/// happens in landscape.
///
/// Giving the column a minimum height of the viewport and an [IntrinsicHeight]
/// satisfies both cases: on a tall screen the [Spacer] still pushes content
/// apart as designed, and on a short one the content grows past the viewport
/// and simply scrolls instead of overflowing.
class FillViewportScroll extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FillViewportScroll({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            // Subtract the padding so the child's minimum height is the space
            // actually available to it, not the full viewport.
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight -
                  padding.vertical.clamp(0, double.infinity),
            ),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
