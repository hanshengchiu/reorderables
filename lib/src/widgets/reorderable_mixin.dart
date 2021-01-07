import 'package:flutter/widgets.dart';

import 'transitions.dart';

mixin ReorderableMixin {
  @protected
  Widget makeAppearingWidget(
    Widget child,
    AnimationController entranceController,
    Size? draggingFeedbackSize,
    Axis direction,
  ) {
    if (null == draggingFeedbackSize) {
      return SizeTransitionWithIntrinsicSize(
        sizeFactor: entranceController,
        axis: direction,
        child: FadeTransition(
          opacity: entranceController,
          child: child,
        ),
      );
    } else {
      var transition = SizeTransition(
        sizeFactor: entranceController,
        axis: direction,
        child: FadeTransition(opacity: entranceController, child: child),
      );

      BoxConstraints contentSizeConstraints = BoxConstraints.loose(draggingFeedbackSize);
      return ConstrainedBox(constraints: contentSizeConstraints, child: transition);
    }
  }

  @protected
  Widget makeDisappearingWidget(
      Widget child,
      AnimationController ghostController,
      Size? draggingFeedbackSize,
      Axis direction,
      ) {
    if (null == draggingFeedbackSize) {
      return SizeTransitionWithIntrinsicSize(
        sizeFactor: ghostController,
        axis: direction,
        child: FadeTransition(
          opacity: ghostController,
          child: child,
        ),
      );
    } else {
      var transition = SizeTransition(
        sizeFactor: ghostController,
        axis: direction,
        child: FadeTransition(opacity: ghostController, child: child),
      );

      BoxConstraints contentSizeConstraints =
      BoxConstraints.loose(draggingFeedbackSize);
      return ConstrainedBox(
          constraints: contentSizeConstraints, child: transition);
    }
  }
}
