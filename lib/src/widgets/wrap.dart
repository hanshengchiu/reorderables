import 'package:flutter/widgets.dart';

import '../rendering/wrap.dart';

class WrapWithMainAxisCount extends Wrap {
  WrapWithMainAxisCount({
    Key? key,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    List<Widget> children = const <Widget>[],
    this.minMainAxisCount,
    this.maxMainAxisCount,
  }) : super(
            key: key,
            direction: direction,
            alignment: alignment,
            spacing: spacing,
            runAlignment: runAlignment,
            runSpacing: runSpacing,
            crossAxisAlignment: crossAxisAlignment,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            children: children);

  final int? minMainAxisCount;
  final int? maxMainAxisCount;

  @override
  RenderWrapWithMainAxisCount createRenderObject(BuildContext context) {
    return RenderWrapWithMainAxisCount(
        direction: direction,
        alignment: alignment,
        spacing: spacing,
        runAlignment: runAlignment,
        runSpacing: runSpacing,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection ?? Directionality.of(context),
        verticalDirection: verticalDirection,
        minMainAxisCount: minMainAxisCount,
        maxMainAxisCount: maxMainAxisCount);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderWrapWithMainAxisCount renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..minMainAxisCount = minMainAxisCount
      ..maxMainAxisCount = maxMainAxisCount;
  }
}
