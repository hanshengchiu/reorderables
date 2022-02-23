import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

bool? _startIsTopLeft(Axis direction, TextDirection? textDirection,
    VerticalDirection verticalDirection) {
  // If the relevant value of textDirection or verticalDirection is null, this returns null too.
  return direction == Axis.horizontal
      ? (textDirection == null ? null : textDirection == TextDirection.ltr)
      : verticalDirection == VerticalDirection.down;
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

class RenderTabluarFlex extends RenderFlex {
  /// Creates a flex render object.
  ///
  /// By default, the flex layout is horizontal and children are aligned to the
  /// start of the main axis and the center of the cross axis.
  RenderTabluarFlex({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Decoration? decoration,
    ImageConfiguration configuration = ImageConfiguration.empty,
  })  : _decoration = decoration,
        _configuration = configuration,
        super(
          children: children,
          direction: direction,
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  BoxPainter? _painter;

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  Decoration? get decoration => _decoration;
  Decoration? _decoration;

  set decoration(Decoration? value) {
//    assert(value != null);
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }

  /// The settings to pass to the decoration when painting, so that it can
  /// resolve images appropriately. See [ImageProvider.resolve] and
  /// [BoxPainter.paint].
  ///
  /// The [ImageConfiguration.textDirection] field is also used by
  /// direction-sensitive [Decoration]s for painting and hit-testing.
  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;

  set configuration(ImageConfiguration value) {
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
    // Since we're disposing of our painter, we won't receive change
    // notifications. We mark ourselves as needing paint so that we will
    // resubscribe to change notifications. If we didn't do this, then, for
    // example, animated GIFs would stop animating when a DecoratedBox gets
    // moved around the tree due to GlobalKey reparenting.
    markNeedsPaint();
  }

  bool get _debugHasNecessaryDirections {
    if (firstChild != null && lastChild != firstChild) {
      // i.e. there's more than one child
      assert(
          direction == Axis.vertical || textDirection != null,
          'Horizontal $runtimeType with multiple children has a '
          'null textDirection, so the layout order is undefined.');
    }
    if (mainAxisAlignment == MainAxisAlignment.start ||
        mainAxisAlignment == MainAxisAlignment.end) {
      assert(
          direction == Axis.vertical || textDirection != null,
          'Horizontal $runtimeType with $mainAxisAlignment has a null '
          'textDirection, so the alignment cannot be resolved.');
    }
    if (crossAxisAlignment == CrossAxisAlignment.start ||
        crossAxisAlignment == CrossAxisAlignment.end) {
      assert(
          direction == Axis.horizontal || textDirection != null,
          'Vertical $runtimeType with $crossAxisAlignment has a null '
          'textDirection, so the alignment cannot be resolved.');
    }
    return true;
  }

  // Set during layout if overflow occurred on the main axis.
  double _overflow = 0;

  ///
  /// Determines whether the current overflow value is greater than zero.
  ///
  bool get _hasOverflow => _overflow > 0.0;

  final ListQueue<LayoutCallback<BoxConstraints>> layoutCallbackQueue =
      ListQueue<LayoutCallback<BoxConstraints>>();
  final ListQueue<Map<int, double>> minMainSizesQueue =
      ListQueue<Map<int, double>>();
  final Map<int, double> _maxGrandchildrenCrossSize = {};

  Map<int, double> get maxGrandchildrenCrossSize =>
      _maxGrandchildrenCrossSize; //  @override
//  void setupParentData(RenderBox child) {
//    if (child.parentData is! FlexParentData)
//      child.parentData = FlexParentData();
//  }

  double _getIntrinsicSize(
      {required Axis sizingDirection,
      required double
          extent, // the extent in the direction that isn't the sizing direction
      required _ChildSizingFunction
          childSize // a method to find the size in the sizing direction
      }) {
    if (direction == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlex = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final int flex = _getFlex(child);
        totalFlex += flex;
        if (flex > 0) {
          final double flexFraction =
              childSize(child, extent) / _getFlex(child);
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize(child, extent);
        }
        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        child = childParentData.nextSibling;
      }
      return maxFlexFractionSoFar * totalFlex + inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.
      // TODO(ianh): Support baseline alignment.

      // Get inflexible space using the max intrinsic dimensions of fixed children in the main direction.
      final double availableMainSpace = extent;
      int totalFlex = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      RenderBox? child = firstChild;
      Map<int, double> maxGrandchildCrossSize = {};
      while (child != null) {
        final int flex = _getFlex(child);
        totalFlex += flex;
        double mainSize;
        double crossSize;
        if (flex == 0) {
          switch (direction) {
            case Axis.horizontal:
              mainSize = child.getMaxIntrinsicWidth(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
            case Axis.vertical:
              mainSize = child.getMaxIntrinsicHeight(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
          }

          RenderTabluarFlex? tabluarFlexChild =
              _findTabluarFlexDescendant(child);
          if (tabluarFlexChild is RenderTabluarFlex) {
//            RenderTabluarFlex _child = child as RenderTabluarFlex;
            List<RenderBox> grandchildren =
                tabluarFlexChild.getChildrenAsList();
            for (int i = 0; i < grandchildren.length; i++) {
              double grandchildCrossSize =
                  childSize(grandchildren[i], mainSize);
              maxGrandchildCrossSize[i] =
                  math.max(maxGrandchildCrossSize[i] ?? 0, grandchildCrossSize);
            }
//          double crossSize1 = childSize(child, mainSize);
          }

          inflexibleSpace += mainSize;
          maxCrossSize = math.max(maxCrossSize, crossSize);
        }
        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        child = childParentData.nextSibling;
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're overconstrained spacePerFlex can be negative.
      final double spacePerFlex =
          math.max(0.0, (availableMainSpace - inflexibleSpace) / totalFlex);

      // Size remaining (flexible) items, find the maximum cross size.
      child = firstChild;
      while (child != null) {
        final int flex = _getFlex(child);
        if (flex > 0) {
          double mainSize = spacePerFlex * flex;
          RenderTabluarFlex? tabluarFlexChild =
              _findTabluarFlexDescendant(child);
          if (tabluarFlexChild is RenderTabluarFlex) {
            List<RenderBox> grandchildren =
                tabluarFlexChild.getChildrenAsList();
            for (int i = 0; i < grandchildren.length; i++) {
              double grandchildCrossSize =
                  childSize(grandchildren[i], mainSize);
              maxGrandchildCrossSize[i] =
                  math.max(maxGrandchildCrossSize[i] ?? 0, grandchildCrossSize);
            }
          }
//          maxCrossSize = math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
          maxCrossSize = math.max(maxCrossSize, childSize(child, mainSize));
        }
        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        child = childParentData.nextSibling;
      }

      if (maxGrandchildCrossSize.isNotEmpty) {
        maxCrossSize = math.max(
            maxCrossSize,
            maxGrandchildCrossSize.values
                .reduce((value, element) => value + element));
      }

      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (RenderBox child, double extent) =>
            child.getMinIntrinsicWidth(extent));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (RenderBox child, double extent) =>
            child.getMaxIntrinsicWidth(extent));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (RenderBox child, double extent) =>
            child.getMinIntrinsicHeight(extent));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (RenderBox child, double extent) =>
            child.getMaxIntrinsicHeight(extent));
  }

  int _getFlex(RenderBox child) {
    final FlexParentData? childParentData = child.parentData as FlexParentData;
    return childParentData?.flex ?? 0;
  }

  FlexFit _getFit(RenderBox? child) {
    final FlexParentData? childParentData = child?.parentData as FlexParentData;
    return childParentData?.fit ?? FlexFit.tight;
  }

  double _getCrossSize(RenderBox child) =>
      direction == Axis.horizontal ? child.size.height : child.size.width;

  double _getMainSize(RenderBox child) =>
      direction == Axis.horizontal ? child.size.width : child.size.height;

  RenderTabluarFlex? _findTabluarFlexDescendant(RenderBox child) {
    RenderObject? curDescendant = child;
    ListQueue<RenderObject> childrenQueue = ListQueue<RenderObject>();
    while (curDescendant != null && curDescendant is! RenderTabluarFlex) {
//      RenderObject firstChildRenderer;
      curDescendant!.visitChildren((RenderObject renderObject) {
//        firstChildRenderer ??= renderObject;
        if (curDescendant is! RenderTabluarFlex) {
          if (renderObject is RenderTabluarFlex) {
            curDescendant = renderObject;
          } else {
            childrenQueue.addLast(renderObject);
          }
        }
      });
      if (curDescendant is! RenderTabluarFlex) {
        curDescendant = childrenQueue.isNotEmpty
            ? childrenQueue.removeFirst()
            : null; //firstChildRenderer;
      }
    }

    return curDescendant == null ? null : curDescendant as RenderTabluarFlex;
  }

  @override
  void performLayout() {
    assert(_debugHasNecessaryDirections);
    // Determine used flex factor, size inflexible items, calculate free space.
    int totalFlex = 0;
    int totalChildren = 0;
    final double maxMainSize = direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final bool canFlex = maxMainSize < double.infinity;
//    debugPrint('${DateTime.now().toString().substring(5, 22)} tabluar_flex.dart(369) $this.performLayout');
    Map<int, double> maxGrandchildrenCrossSize = {};

    Map<RenderBox, RenderTabluarFlex> tabluarFlexDescendants = {};

    void _layoutChild(RenderBox child, BoxConstraints constraints) {
      RenderTabluarFlex? tabluarFlexChild = _findTabluarFlexDescendant(child);
//      debugPrint('this:$this _layoutChild: child:$child tabluarFlexChild:$tabluarFlexChild');
      if (tabluarFlexChild != null) {
        //when this is laying out its child (and descendants), this function will be called. So that we can get the grandchild's size
        bool callbackCalled = false;
        void _childLayoutCallback(BoxConstraints constraints) {
          List<RenderBox> grandchildren = tabluarFlexChild.getChildrenAsList();
//          debugPrint('${DateTime.now().toString().substring(5, 22)} tabluar_flex.dart(381) $this._childLayoutCallback: grandchildren.length:${grandchildren.length}');
          for (int i = 0; i < grandchildren.length; i++) {
            double grandchildCrossSize = _getCrossSize(grandchildren[i]);
            maxGrandchildrenCrossSize[i] = math.max(
                maxGrandchildrenCrossSize[i] ?? 0, grandchildCrossSize);
          }

          callbackCalled = true;
        }

        tabluarFlexDescendants[child] =
            tabluarFlexChild; //save this for later use

        tabluarFlexChild.layoutCallbackQueue.addLast(_childLayoutCallback);
        child.layout(constraints, parentUsesSize: true);
        if (!callbackCalled) {
          tabluarFlexChild.layout(constraints,
              parentUsesSize:
                  true); //make sure _childLayoutCallback will be called
        }
        tabluarFlexChild.layoutCallbackQueue.removeLast();
//        debugPrint('this:$this tabluarFlexChild.constraints:${tabluarFlexChild.constraints}');
      } else {
        child.layout(constraints, parentUsesSize: true);
      }
    }

    Map<int, double> minChildrenMainSize =
        minMainSizesQueue.isNotEmpty ? minMainSizesQueue.last : {};

    BoxConstraints _innerConstraints(int childIndex) {
      BoxConstraints innerConstraints;
      if (crossAxisAlignment == CrossAxisAlignment.stretch) {
        switch (direction) {
          case Axis.horizontal:
            innerConstraints = BoxConstraints(
                minHeight: constraints.maxHeight,
                maxHeight: constraints.maxHeight);
            break;
          case Axis.vertical:
            innerConstraints = BoxConstraints(
                minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth);
            break;
        }
      } else {
        switch (direction) {
          case Axis.horizontal:
            innerConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
            break;
          case Axis.vertical:
            innerConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
            break;
        }
      }

      if (childIndex < minChildrenMainSize.length) {
        switch (direction) {
          case Axis.horizontal:
            innerConstraints = innerConstraints.copyWith(
                minWidth: math.max(innerConstraints.minWidth,
                    minChildrenMainSize[childIndex]!));
            break;
          case Axis.vertical:
            innerConstraints = innerConstraints.copyWith(
                minHeight: math.max(innerConstraints.minHeight,
                    minChildrenMainSize[childIndex]!));
            break;
        }
      }

      return innerConstraints;
    }

    Map<RenderBox, BoxConstraints> childrenConstraints = {};

    double crossSize = 0.0;
    double allocatedSize =
        0.0; // Sum of the sizes of the non-flexible children.
    RenderBox? child = firstChild;
    RenderBox? lastFlexChild;
    int childIndex = 0;
    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      totalChildren++;
      final int flex = _getFlex(child);
      if (flex > 0) {
        assert(() {
          final String identity =
              direction == Axis.horizontal ? 'row' : 'column';
          final String axis =
              direction == Axis.horizontal ? 'horizontal' : 'vertical';
          final String dimension =
              direction == Axis.horizontal ? 'width' : 'height';
          String error, message;
          String addendum = '';
          if (!canFlex &&
              (mainAxisSize == MainAxisSize.max ||
                  _getFit(child) == FlexFit.tight)) {
            error =
                'RenderFlex children have non-zero flex but incoming $dimension constraints are unbounded.';
            message =
                'When a $identity is in a parent that does not provide a finite $dimension constraint, for example '
                'if it is in a $axis scrollable, it will try to shrink-wrap its children along the $axis '
                'axis. Setting a flex on a child (e.g. using Expanded) indicates that the child is to '
                'expand to fill the remaining space in the $axis direction.';
            final StringBuffer information = StringBuffer();
            RenderBox? node = this;
            switch (direction) {
              case Axis.horizontal:
                while (!node!.constraints.hasBoundedWidth &&
                    node.parent is RenderBox) node = node.parent as RenderBox;
                if (!node.constraints.hasBoundedWidth) node = null;
                break;
              case Axis.vertical:
                while (!node!.constraints.hasBoundedHeight &&
                    node.parent is RenderBox) node = node.parent as RenderBox;
                if (!node.constraints.hasBoundedHeight) node = null;
                break;
            }
            if (node != null) {
              information.writeln(
                  'The nearest ancestor providing an unbounded width constraint is:');
              information.write('  ');
              information.writeln(node.toStringShallow(joiner: '\n  '));
            }
            information.writeln('See also: https://flutter.io/layout/');
            addendum = information.toString();
          } else {
            return true;
          }
          throw FlutterError('$error\n'
              '$message\n'
              'These two directives are mutually exclusive. If a parent is to shrink-wrap its child, the child '
              'cannot simultaneously expand to fit its parent.\n'
              'Consider setting mainAxisSize to MainAxisSize.min and using FlexFit.loose fits for the flexible '
              'children (using Flexible rather than Expanded). This will allow the flexible children '
              'to size themselves to less than the infinite remaining space they would otherwise be '
              'forced to take, and then will cause the RenderFlex to shrink-wrap the children '
              'rather than expanding to fit the maximum constraints provided by the parent.\n'
              'The affected RenderFlex is:\n'
              '  $this\n'
              'The creator information is set to:\n'
              '  $debugCreator\n'
              '$addendum'
              'If this message did not help you determine the problem, consider using debugDumpRenderTree():\n'
              '  https://flutter.io/debugging/#rendering-layer\n'
              '  http://docs.flutter.io/flutter/rendering/debugDumpRenderTree.html\n'
              'If none of the above helps enough to fix this problem, please don\'t hesitate to file a bug:\n'
              '  https://github.com/flutter/flutter/issues/new?template=BUG.md');
        }());
        totalFlex += childParentData.flex!;
        lastFlexChild = child;
      } else {
        BoxConstraints innerConstraints = _innerConstraints(childIndex);

//        debugPrint('${DateTime.now().toString().substring(5, 22)} tabluar_flex.dart(515) $this.performLayout: innerConstraints:$innerConstraints');
//        child.layout(innerConstraints, parentUsesSize: true);
        _layoutChild(child, innerConstraints);
        childrenConstraints[child] = innerConstraints; //save this for later use

        allocatedSize += _getMainSize(child);
        crossSize = math.max(crossSize, _getCrossSize(child));
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
      childIndex++;
    }

    for (; childIndex < minChildrenMainSize.length; childIndex++) {
      totalChildren++;

      BoxConstraints innerConstraints = _innerConstraints(childIndex);
      switch (direction) {
        case Axis.horizontal:
          allocatedSize += innerConstraints.minWidth;
          break;
        case Axis.vertical:
          allocatedSize += innerConstraints.minHeight;
          break;
      }
    }

    // Distribute free space to flexible children, and determine baseline.
    final double freeSpace =
        math.max(0.0, (canFlex ? maxMainSize : 0.0) - allocatedSize);
    double allocatedFlexSpace = 0.0;
    double maxBaselineDistance = 0.0;
    if (totalFlex > 0 || crossAxisAlignment == CrossAxisAlignment.baseline) {
      final double spacePerFlex =
          canFlex && totalFlex > 0 ? (freeSpace / totalFlex) : double.nan;
      child = firstChild;
      childIndex = 0;
      while (child != null) {
        final int flex = _getFlex(child);
        if (flex > 0) {
          final double maxChildExtent = canFlex
              ? (child == lastFlexChild
                  ? (freeSpace - allocatedFlexSpace)
                  : spacePerFlex * flex)
              : double.infinity;
          double minChildExtent;
          switch (_getFit(child)) {
            case FlexFit.tight:
              assert(maxChildExtent < double.infinity);
              minChildExtent = maxChildExtent;
              break;
            case FlexFit.loose:
              minChildExtent = 0.0;
              break;
          }
          BoxConstraints innerConstraints;
          if (crossAxisAlignment == CrossAxisAlignment.stretch) {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = BoxConstraints(
                    minWidth: minChildExtent,
                    maxWidth: maxChildExtent,
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight);
                break;
              case Axis.vertical:
                innerConstraints = BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                    minHeight: minChildExtent,
                    maxHeight: maxChildExtent);
                break;
            }
          } else {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = BoxConstraints(
                    minWidth: minChildExtent,
                    maxWidth: maxChildExtent,
                    maxHeight: constraints.maxHeight);
                break;
              case Axis.vertical:
                innerConstraints = BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    minHeight: minChildExtent,
                    maxHeight: maxChildExtent);
                break;
            }
          }

          if (childIndex < minChildrenMainSize.length) {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = innerConstraints.copyWith(
                    minWidth: math.max(innerConstraints.minWidth,
                        minChildrenMainSize[childIndex]!));
                break;
              case Axis.vertical:
                innerConstraints = innerConstraints.copyWith(
                    minHeight: math.max(innerConstraints.minHeight,
                        minChildrenMainSize[childIndex]!));
                break;
            }
          }

//          child.layout(innerConstraints, parentUsesSize: true);
          _layoutChild(child, innerConstraints);
          childrenConstraints[child] = innerConstraints;

          final double childSize = _getMainSize(child);
          assert(childSize <= maxChildExtent);
          allocatedSize += childSize;
          allocatedFlexSpace += maxChildExtent;
          crossSize = math.max(crossSize, _getCrossSize(child));
        }
        if (crossAxisAlignment == CrossAxisAlignment.baseline) {
          assert(() {
            if (textBaseline == null)
              throw FlutterError(
                  'To use FlexAlignItems.baseline, you must also specify which baseline to use using the "baseline" argument.');
            return true;
          }());
          final double? distance =
              child.getDistanceToBaseline(textBaseline!, onlyReal: true);
          if (distance != null)
            maxBaselineDistance = math.max(maxBaselineDistance, distance);
        }
        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        child = childParentData.nextSibling;
        childIndex++;
      }
    }

//    double minCrossSize = maxGrandchildrenCrossSize.isNotEmpty ? maxGrandchildrenCrossSize.values.reduce((value, element) => value + element) : 0;
//    debugPrint('this:$this crossSize:$crossSize minChildrenMainSize:$minChildrenMainSize maxGrandchildrenCrossSize:$maxGrandchildrenCrossSize tabluarFlexDescendants:$tabluarFlexDescendants');
    if (maxGrandchildrenCrossSize.isNotEmpty) {
      double minCrossSize = maxGrandchildrenCrossSize.values
          .reduce((value, element) => value + element);
//      debugPrint('${DateTime.now().toString().substring(5, 22)} tabluar_flex.dart(624) $this.performLayout: '
//        'minCrossSize:$minCrossSize crossSize:$crossSize minChildrenMainSize:$minChildrenMainSize maxGrandchildrenCrossSize:$maxGrandchildrenCrossSize');

      child = firstChild;
      while (child != null) {
//          debugPrint('this:$this relayout child:$child');
        BoxConstraints innerConstraints = childrenConstraints[child]!;
        switch (direction) {
          case Axis.horizontal:
            innerConstraints = innerConstraints.copyWith(
                minHeight: math.max(innerConstraints.minHeight, minCrossSize));
            break;
          case Axis.vertical:
            innerConstraints = innerConstraints.copyWith(
                minWidth: math.max(innerConstraints.minWidth, minCrossSize));
            break;
        }
//        debugPrint('childrenConstraints[child]:${childrenConstraints[child]} innerConstraints:$innerConstraints');

        if (tabluarFlexDescendants.containsKey(child)) {
          bool callbackCalled = false;
          void _childLayoutCallback(BoxConstraints constraints) {
            callbackCalled = true;
          }

          RenderTabluarFlex tabluarFlexChild = tabluarFlexDescendants[child]!;
          tabluarFlexChild.layoutCallbackQueue.addLast(_childLayoutCallback);
          tabluarFlexChild.minMainSizesQueue.addLast(maxGrandchildrenCrossSize);
          tabluarFlexChild.layout(innerConstraints, parentUsesSize: true);
          child.layout(innerConstraints, parentUsesSize: true);
          if (!callbackCalled) {
            tabluarFlexChild.layout(innerConstraints, parentUsesSize: true);
          }
          tabluarFlexChild.minMainSizesQueue.removeLast();
          tabluarFlexChild.layoutCallbackQueue.removeLast();
        } else {
          child.layout(innerConstraints, parentUsesSize: true);
        }
        crossSize = math.max(crossSize, _getCrossSize(child));

        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        child = childParentData.nextSibling;
      }
//    debugPrint('this:$this updated crossSize:$crossSize');
    }

    // Align items along the main axis.
    final double idealSize = canFlex && mainAxisSize == MainAxisSize.max
        ? maxMainSize
        : allocatedSize;
    double actualSize;
    double actualSizeDelta;
    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(idealSize, crossSize));
        actualSize = size.width;
        crossSize = size.height;
        break;
      case Axis.vertical:
        size = constraints.constrain(Size(crossSize, idealSize));
        actualSize = size.height;
        crossSize = size.width;
        break;
    }
    actualSizeDelta = actualSize - allocatedSize;
    _overflow = math.max(0.0, -actualSizeDelta);

    final double remainingSpace = math.max(0.0, actualSizeDelta);
    double leadingSpace;
    double betweenSpace;
    // flipMainAxis is used to decide whether to lay out left-to-right/top-to-bottom (false), or
    // right-to-left/bottom-to-top (true). The _startIsTopLeft will return null if there's only
    // one child and the relevant direction is null, in which case we arbitrarily decide not to
    // flip, but that doesn't have any detectable effect.
    final bool flipMainAxis =
        !(_startIsTopLeft(direction, textDirection, verticalDirection) ?? true);
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.end:
        leadingSpace = remainingSpace;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.center:
        leadingSpace = remainingSpace / 2.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.spaceBetween:
        leadingSpace = 0.0;
        betweenSpace =
            totalChildren > 1 ? remainingSpace / (totalChildren - 1) : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        betweenSpace = totalChildren > 0 ? remainingSpace / totalChildren : 0.0;
        leadingSpace = betweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        betweenSpace =
            totalChildren > 0 ? remainingSpace / (totalChildren + 1) : 0.0;
        leadingSpace = betweenSpace;
        break;
    }

    // Position elements
    double childMainPosition =
        flipMainAxis ? actualSize - leadingSpace : leadingSpace;
    child = firstChild;
    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      double childCrossPosition;
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
        case CrossAxisAlignment.end:
          childCrossPosition = _startIsTopLeft(
                      flipAxis(direction), textDirection, verticalDirection) ==
                  (crossAxisAlignment == CrossAxisAlignment.start)
              ? 0.0
              : crossSize - _getCrossSize(child);
          break;
        case CrossAxisAlignment.center:
          childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
          break;
        case CrossAxisAlignment.stretch:
          childCrossPosition = 0.0;
          break;
        case CrossAxisAlignment.baseline:
          childCrossPosition = 0.0;
          if (direction == Axis.horizontal) {
            assert(textBaseline != null);
            final double? distance =
                child.getDistanceToBaseline(textBaseline!, onlyReal: true);
            if (distance != null)
              childCrossPosition = maxBaselineDistance - distance;
          }
          break;
      }
      if (flipMainAxis) childMainPosition -= _getMainSize(child);
      switch (direction) {
        case Axis.horizontal:
          childParentData.offset =
              Offset(childMainPosition, childCrossPosition);
          break;
        case Axis.vertical:
          childParentData.offset =
              Offset(childCrossPosition, childMainPosition);
          break;
      }
      if (flipMainAxis) {
        childMainPosition -= betweenSpace;
      } else {
        childMainPosition += _getMainSize(child) + betweenSpace;
      }
      child = childParentData.nextSibling;
    }

    this._maxGrandchildrenCrossSize.clear();
    this._maxGrandchildrenCrossSize.addAll(maxGrandchildrenCrossSize);

    //we can only call this callback when we've done this object's layout. So that size will be valid for the callbackee.
    if (this.layoutCallbackQueue.isNotEmpty) {
      this
          .layoutCallbackQueue
          .forEach((LayoutCallback<BoxConstraints> callback) {
        invokeLayoutCallback(callback);
      });
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
      return;
    }

    // There's no point in drawing the children if we're empty.
    if (size.isEmpty) return;

    if (_decoration != null) {
      _painter ??= _decoration!.createBoxPainter(markNeedsPaint);
      final ImageConfiguration filledConfiguration =
          configuration.copyWith(size: size);
      _painter!.paint(context.canvas, offset, filledConfiguration);
    }

    // We have overflow. Clip it.
    context.pushClipRect(
        needsCompositing, offset, Offset.zero & size, defaultPaint);

//    assert(() {
//      // Only set this if it's null to save work. It gets reset to null if the
//      // _direction changes.
//      final List<DiagnosticsNode> debugOverflowHints = <DiagnosticsNode>[];
//      debugOverflowHints.add(ErrorDescription(
//          'The overflowing $runtimeType has an orientation of $direction.\n'
//          'The edge of the $runtimeType that is overflowing has been marked '
//          'in the rendering with a yellow and black striped pattern. This is '
//          'usually caused by the contents being too big for the $runtimeType. '
//          'Consider applying a flex factor (e.g. using an Expanded widget) to '
//          'force the children of the $runtimeType to fit within the available '
//          'space instead of being sized to their natural size.\n'
//      ));
//      debugOverflowHints.add(ErrorHint(
//          'This is considered an error condition because it indicates that there '
//          'is content that cannot be seen. If the content is legitimately bigger '
//          'than the available space, consider clipping it with a ClipRect widget '
//          'before putting it in the flex, or using a scrollable container rather '
//          'than a Flex, like a ListView.'
//      ));
//
//      // Simulate a child rect that overflows by the right amount. This child
//      // rect is never used for drawing, just for determining the overflow
//      // location and amount.
//      Rect overflowChildRect;
//      switch (direction) {
//        case Axis.horizontal:
//          overflowChildRect =
//              Rect.fromLTWH(0.0, 0.0, size.width + _overflow, 0.0);
//          break;
//        case Axis.vertical:
//          overflowChildRect =
//              Rect.fromLTWH(0.0, 0.0, 0.0, size.height + _overflow);
//          break;
//      }
//      paintOverflowIndicator(
//          context, offset, Offset.zero & size, overflowChildRect,
//          overflowHints: debugOverflowHints);
//      return true;
//    }());
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _hasOverflow ? Offset.zero & size : null;

  @override
  String toStringShort() {
    String header = super.toStringShort();
    if (_hasOverflow) header += ' OVERFLOWING';
    return header;
  }
}
