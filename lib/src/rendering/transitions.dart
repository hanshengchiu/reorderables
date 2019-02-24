import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class RenderSizeTransitionWithIntrinsicSize extends RenderProxyBox {
  RenderSizeTransitionWithIntrinsicSize({
    this.axis = Axis.vertical,
    @required this.sizeFactor,
    RenderBox child,
  })  : assert(sizeFactor != null),
//       _axis = axis,
//       _sizeFactor = sizeFactor,
        super(child);

  Axis axis;
//  Axis get axis => _axis;
//  set axis(Axis value) {
//    _axis = value;
//  }

  Animation<double> sizeFactor;
//  Animation<double> get sizeFactor => _sizeFactor;
//  set sizeFactor(Animation<double> value) {
//    _sizeFactor = value;
//  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      double childWidth = child.getMinIntrinsicWidth(height);
      return axis == Axis.horizontal
          ? childWidth * sizeFactor.value
          : childWidth;
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      double childWidth = child.getMaxIntrinsicWidth(height);
      return axis == Axis.horizontal
          ? childWidth * sizeFactor.value
          : childWidth;
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      double childHeight = child.getMinIntrinsicHeight(width);
      return axis == Axis.vertical
          ? childHeight * sizeFactor.value
          : childHeight;
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      double childHeight = child.getMaxIntrinsicHeight(width);
      return axis == Axis.vertical
          ? childHeight * sizeFactor.value
          : childHeight;
    }
    return 0.0;
  }
}
