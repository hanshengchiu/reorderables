import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class _RunMetrics {
  _RunMetrics(this.mainAxisExtent, this.crossAxisExtent, this.childCount);

  final double mainAxisExtent;
  final double crossAxisExtent;
  final int childCount;
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

/// Parent data for use with [RenderWrap].
class WrapWithMainAxisCountParentData extends WrapParentData {
  int _runIndex = 0;
}

class RenderWrapWithMainAxisCount extends RenderWrap {
  RenderWrapWithMainAxisCount({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    this.minMainAxisCount,
    this.maxMainAxisCount,
  })  : assert(minMainAxisCount == null ||
            maxMainAxisCount == null ||
            maxMainAxisCount >= minMainAxisCount),
//       _minMainAxisCount = minMainAxisCount,
//       _maxMainAxisCount = maxMainAxisCount,
        super(
          children: children,
          direction: direction,
          alignment: alignment,
          spacing: spacing,
          runAlignment: runAlignment,
          runSpacing: runSpacing,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
        );

  int? minMainAxisCount;

//  int get minMainAxisCount => _minMainAxisCount;
//  set minMainAxisCount(int value) {
//    _minMainAxisCount = value;
//  }

  int? maxMainAxisCount;

//  int get maxMainAxisCount => _maxMainAxisCount;
//  set maxMainAxisCount(int value) {
//    _maxMainAxisCount = value;
//  }

  bool get _debugHasNecessaryDirections {
    if (firstChild != null && lastChild != firstChild) {
      // i.e. there's more than one child
      assert(
          direction == Axis.vertical || textDirection != null,
          'Horizontal $runtimeType with multiple children has a null '
          'textDirection, so the layout order is undefined.');
    }
    if (alignment == WrapAlignment.start || alignment == WrapAlignment.end) {
      assert(
          direction == Axis.vertical || textDirection != null,
          'Horizontal $runtimeType with alignment $alignment has a null '
          'textDirection, so the alignment cannot be resolved.');
    }
    if (runAlignment == WrapAlignment.start ||
        runAlignment == WrapAlignment.end) {
      assert(
          direction == Axis.horizontal || textDirection != null,
          'Horizontal $runtimeType with runAlignment $runAlignment has a null '
          'verticalDirection, so the alignment cannot be resolved.');
    }
    if (crossAxisAlignment == WrapCrossAlignment.start ||
        crossAxisAlignment == WrapCrossAlignment.end) {
      assert(
          direction == Axis.horizontal || textDirection != null,
          'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment '
          'has a null textDirection, so the alignment cannot be resolved.');
    }
    return true;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapWithMainAxisCountParentData)
      child.parentData = WrapWithMainAxisCountParentData();
  }

  double _computeIntrinsicHeightForWidth(double width) {
    assert(direction == Axis.horizontal);
    int runCount = 0;
    double height = 0.0;
    double runWidth = 0.0;
    double runHeight = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
    int minChildCount = minMainAxisCount ?? 1;
    int maxChildCount = maxMainAxisCount ?? -1;
    while (child != null) {
      final double childWidth = child.getMaxIntrinsicWidth(double.infinity);
      final double childHeight = child.getMaxIntrinsicHeight(childWidth);
      //the number of children per row/column (run) must be equal/larger than minChildCount and equal/smaller than maxChildCount.
      if (childCount >= minChildCount &&
          (runWidth + childWidth > width ||
              (maxChildCount >= minChildCount &&
                  childCount >= maxChildCount))) {
        height += runHeight;
        if (runCount > 0) height += runSpacing;
        runCount += 1;
        runWidth = 0.0;
        runHeight = 0.0;
        childCount = 0;
      }
      runWidth += childWidth;
      runHeight = math.max(runHeight, childHeight);
      if (childCount > 0) runWidth += spacing;
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0) height += runHeight + runSpacing;
    return height;
  }

  double _computeIntrinsicWidthForHeight(double height) {
    assert(direction == Axis.vertical);
    int runCount = 0;
    double width = 0.0;
    double runHeight = 0.0;
    double runWidth = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
    int minChildCount = minMainAxisCount ?? 1;
    int maxChildCount = maxMainAxisCount ?? -1;
    while (child != null) {
      final double childHeight = child.getMaxIntrinsicHeight(double.infinity);
      final double childWidth = child.getMaxIntrinsicWidth(childHeight);
      //the number of children per row/column (run) must be equal/larger than minChildCount and equal/smaller than maxChildCount.
      if (childCount >= minChildCount &&
          (runHeight + childHeight > height ||
              (maxChildCount >= minChildCount &&
                  childCount >= maxChildCount))) {
        width += runWidth;
        if (runCount > 0) width += runSpacing;
        runCount += 1;
        runHeight = 0.0;
        runWidth = 0.0;
        childCount = 0;
      }
      runHeight += childHeight;
      runWidth = math.max(runWidth, childWidth);
      if (childCount > 0) runHeight += spacing;
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0) width += runWidth + runSpacing;
    return width;
  }

  double _getIntrinsicSize(
      {
//    Axis sizingDirection,
//    double extent, // the extent in the direction that isn't the sizing direction
      required int childCountAlongMainAxis,
      required _ChildSizingFunction
          childSize // a method to find the size in the sizing direction
      }) {
    double runMainAxisExtent = 0.0;
    double maxRunMainAxisExtent = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
//    final List<double> runMainAxisExtents = [];
    while (child != null) {
      final double childMainAxisExtent = childSize(child, double.infinity);
      if (childCountAlongMainAxis > 0 &&
          childCount >= childCountAlongMainAxis) {
        maxRunMainAxisExtent =
            math.max(maxRunMainAxisExtent, runMainAxisExtent);
        runMainAxisExtent = 0.0;
        childCount = 0;
      }
      runMainAxisExtent += childMainAxisExtent;
      if (childCount > 0) runMainAxisExtent += spacing;
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0)
      maxRunMainAxisExtent = math.max(maxRunMainAxisExtent, runMainAxisExtent);
    return maxRunMainAxisExtent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        return _getIntrinsicSize(
            childCountAlongMainAxis: minMainAxisCount ?? 1,
            childSize: (RenderBox child, double extent) =>
                child.getMinIntrinsicWidth(extent));
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        return _getIntrinsicSize(
            childCountAlongMainAxis: maxMainAxisCount ?? -1,
            childSize: (RenderBox child, double extent) =>
                child.getMaxIntrinsicWidth(extent));
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        return _getIntrinsicSize(
            childCountAlongMainAxis: minMainAxisCount ?? 1,
            childSize: (RenderBox child, double extent) =>
                child.getMinIntrinsicHeight(extent));
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        return _getIntrinsicSize(
            childCountAlongMainAxis: maxMainAxisCount ?? -1,
            childSize: (RenderBox child, double extent) =>
                child.getMaxIntrinsicHeight(extent));
    }
  }

  double _getMainAxisExtent(RenderBox child) {
    switch (direction) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  double _getCrossAxisExtent(RenderBox child) {
    switch (direction) {
      case Axis.horizontal:
        return child.size.height;
      case Axis.vertical:
        return child.size.width;
    }
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    switch (direction) {
      case Axis.horizontal:
        return Offset(mainAxisOffset, crossAxisOffset);
      case Axis.vertical:
        return Offset(crossAxisOffset, mainAxisOffset);
    }
  }

  double _getChildCrossAxisOffset(bool flipCrossAxis, double runCrossAxisExtent,
      double childCrossAxisExtent) {
    final double freeSpace = runCrossAxisExtent - childCrossAxisExtent;
    switch (crossAxisAlignment) {
      case WrapCrossAlignment.start:
        return flipCrossAxis ? freeSpace : 0.0;
      case WrapCrossAlignment.end:
        return flipCrossAxis ? 0.0 : freeSpace;
      case WrapCrossAlignment.center:
        return freeSpace / 2.0;
    }
  }

  bool _hasVisualOverflow = false;
  late List<int> childRunIndexes;

  @override
  void performLayout() {
    assert(_debugHasNecessaryDirections);
    _hasVisualOverflow = false;
    RenderBox? child = firstChild;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    BoxConstraints childConstraints;
    double mainAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;
    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
        break;
    }
    final double spacing = this.spacing;
    final double runSpacing = this.runSpacing;
    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    int childCount = 0;
    int minChildCount = minMainAxisCount ?? 1;
    int maxChildCount = maxMainAxisCount ?? -1;
    int runIndex = 0;
    childRunIndexes = [];
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final double childMainAxisExtent = _getMainAxisExtent(child);
      final double childCrossAxisExtent = _getCrossAxisExtent(child);
      //if (childCount > 0 && runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit) {
      if (childCount >= minChildCount &&
          (runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit ||
              (maxChildCount >= minChildCount &&
                  childCount >= maxChildCount))) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
        runMetrics.add(
            _RunMetrics(runMainAxisExtent, runCrossAxisExtent, childCount));
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        childCount = 0;
        runIndex++;
      }
      runMainAxisExtent += childMainAxisExtent;
      if (childCount > 0) runMainAxisExtent += spacing;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      childCount += 1;
      final WrapWithMainAxisCountParentData childParentData =
          child.parentData! as WrapWithMainAxisCountParentData;
      childParentData._runIndex = runMetrics.length;
      child = childParentData.nextSibling;
      childRunIndexes.add(runIndex);
    }
    if (childCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
      runMetrics
          .add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, childCount));
    }

    final int runCount = runMetrics.length;
    assert(runCount > 0);

    double containerMainAxisExtent = 0.0;
    double containerCrossAxisExtent = 0.0;

    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(mainAxisExtent, crossAxisExtent));
        containerMainAxisExtent = size.width;
        containerCrossAxisExtent = size.height;
        break;
      case Axis.vertical:
        size = constraints.constrain(Size(crossAxisExtent, mainAxisExtent));
        containerMainAxisExtent = size.height;
        containerCrossAxisExtent = size.width;
        break;
    }

    _hasVisualOverflow = containerMainAxisExtent < mainAxisExtent ||
        containerCrossAxisExtent < crossAxisExtent;

    final double crossAxisFreeSpace =
        math.max(0.0, containerCrossAxisExtent - crossAxisExtent);
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;
    switch (runAlignment) {
      case WrapAlignment.start:
        break;
      case WrapAlignment.end:
        runLeadingSpace = crossAxisFreeSpace;
        break;
      case WrapAlignment.center:
        runLeadingSpace = crossAxisFreeSpace / 2.0;
        break;
      case WrapAlignment.spaceBetween:
        runBetweenSpace =
            runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
        break;
      case WrapAlignment.spaceAround:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        runLeadingSpace = runBetweenSpace / 2.0;
        break;
      case WrapAlignment.spaceEvenly:
        runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
        runLeadingSpace = runBetweenSpace;
        break;
    }

    runBetweenSpace += runSpacing;
    double crossAxisOffset = flipCrossAxis
        ? containerCrossAxisExtent - runLeadingSpace
        : runLeadingSpace;

    child = firstChild;
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final int childCount = metrics.childCount;

      final double mainAxisFreeSpace =
          math.max(0.0, containerMainAxisExtent - runMainAxisExtent);
      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      switch (alignment) {
        case WrapAlignment.start:
          break;
        case WrapAlignment.end:
          childLeadingSpace = mainAxisFreeSpace;
          break;
        case WrapAlignment.center:
          childLeadingSpace = mainAxisFreeSpace / 2.0;
          break;
        case WrapAlignment.spaceBetween:
          childBetweenSpace =
              childCount > 1 ? mainAxisFreeSpace / (childCount - 1) : 0.0;
          break;
        case WrapAlignment.spaceAround:
          childBetweenSpace = mainAxisFreeSpace / childCount;
          childLeadingSpace = childBetweenSpace / 2.0;
          break;
        case WrapAlignment.spaceEvenly:
          childBetweenSpace = mainAxisFreeSpace / (childCount + 1);
          childLeadingSpace = childBetweenSpace;
          break;
      }

      childBetweenSpace += spacing;
      double childMainPosition = flipMainAxis
          ? containerMainAxisExtent - childLeadingSpace
          : childLeadingSpace;

      if (flipCrossAxis) crossAxisOffset -= runCrossAxisExtent;

      while (child != null) {
        final WrapWithMainAxisCountParentData childParentData =
            child.parentData! as WrapWithMainAxisCountParentData;
        if (childParentData._runIndex != i) break;
        final double childMainAxisExtent = _getMainAxisExtent(child);
        final double childCrossAxisExtent = _getCrossAxisExtent(child);
        final double childCrossAxisOffset = _getChildCrossAxisOffset(
            flipCrossAxis, runCrossAxisExtent, childCrossAxisExtent);
        if (flipMainAxis) childMainPosition -= childMainAxisExtent;
        childParentData.offset = _getOffset(
            childMainPosition, crossAxisOffset + childCrossAxisOffset);
        if (flipMainAxis)
          childMainPosition -= childBetweenSpace;
        else
          childMainPosition += childMainAxisExtent + childBetweenSpace;
        child = childParentData.nextSibling;
      }

      if (flipCrossAxis)
        crossAxisOffset -= runBetweenSpace;
      else
        crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO(ianh): move the debug flex overflow paint logic somewhere common so
    // it can be reused here
    if (_hasVisualOverflow)
      context.pushClipRect(
          needsCompositing, offset, Offset.zero & size, defaultPaint);
    else
      defaultPaint(context, offset);
  }
}
