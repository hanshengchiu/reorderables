import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import '../rendering/transitions.dart';

class SizeTransitionWithIntrinsicSize extends SingleChildRenderObjectWidget {
  /// Creates a size transition with its intrinsic width/height taking [sizeFactor] into account.
  ///
  /// The [axis], [sizeFactor], and [axisAlignment] arguments must not be null.
  /// The [axis] argument defaults to [Axis.vertical]. The [axisAlignment]
  /// defaults to 0.0, which centers the child along the main axis during the
  /// transition.
  SizeTransitionWithIntrinsicSize({
    this.axis = Axis.vertical,
    required this.sizeFactor,
    double axisAlignment = 0.0,
    Widget? child,
    Key? key,
  }) : super(
            key: key,
            child: SizeTransition(
              axis: axis,
              sizeFactor: sizeFactor,
              axisAlignment: axisAlignment,
              child: child,
            ));

  final Axis axis;
  final Animation<double> sizeFactor;

  @override
  RenderSizeTransitionWithIntrinsicSize createRenderObject(
      BuildContext context) {
    return RenderSizeTransitionWithIntrinsicSize(
      axis: axis,
      sizeFactor: sizeFactor,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      RenderSizeTransitionWithIntrinsicSize renderObject) {
    renderObject
      ..axis = axis
      ..sizeFactor = sizeFactor;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Axis>('axis', axis));
    properties
        .add(DiagnosticsProperty<Animation<double>>('sizeFactor', sizeFactor));
  }
}
