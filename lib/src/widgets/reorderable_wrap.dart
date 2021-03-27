// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:reorderables/reorderables.dart';

import './passthrough_overlay.dart';
//import './transitions.dart';
import './typedefs.dart';
import './wrap.dart';
//import './transitions.dart';
import '../rendering/wrap.dart';
import 'reorderable_mixin.dart';

/// Reorderable (drag and drop) version of [Wrap], A widget that displays its
/// children in multiple horizontal or vertical runs.
///
/// In addition to [Wrap]'s parameters, this widget also adds two parameters,
/// [minMainAxisCount] and [maxMainAxisCount], that limits how many children
/// each run has at least and at most. For example, if the size of parent
/// widget allows a run to have more than [maxMainAxisCount] children, the run
/// is forced to end and will have [maxMainAxisCount] children only.
///
/// All [children] must have a key.
///
/// See also:
///
///  * [Wrap], which displays its children in multiple horizontal or vertical
///  runs.
class ReorderableWrap extends StatefulWidget {
  /// Creates a reorderable wrap.
  ReorderableWrap({
    required this.children,
    required this.onReorder,
    this.header,
    this.footer,
    this.controller,
    this.direction = Axis.horizontal,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.buildItemsContainer,
    this.buildDraggableFeedback,
    this.needsLongPressDraggable = true,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.minMainAxisCount,
    this.maxMainAxisCount,
    this.onNoReorder,
    this.onReorderStarted,
    this.reorderAnimationDuration = const Duration(milliseconds: 200),
    this.scrollAnimationDuration = const Duration(milliseconds: 200),
    this.ignorePrimaryScrollController = false,
    Key? key,
  }) :
//        assert(
//          children.every((Widget w) => w.key != null),
//          'All children of this widget must have a key.',
//        ),
        super(key: key);

  /// A non-reorderable header widget to show before the list.
  ///
  /// If null, no header will appear before the list.
  final List<Widget>? header;
  final Widget? footer;

  /// A custom scroll [controller].
  /// To control the initial scroll offset of the scroll view, provide a
  /// [controller] with its [ScrollController.initialScrollOffset] property set.
  final ScrollController? controller;

  /// The widgets to display.
  final List<Widget> children;

  /// The direction to use as the main axis.
  ///
  /// For example, if [direction] is [Axis.horizontal], the default, the
  /// children are placed adjacent to one another in a horizontal run until the
  /// available horizontal space is consumed, at which point a subsequent
  /// children are placed in a new run vertically adjacent to the previous run.
  final Axis direction;
  final Axis scrollDirection;

  /// The amount of space by which to inset the [children].
  final EdgeInsets? padding;

  /// Called when a child is dropped into a new position to shuffle the
  /// children.
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;

  /// Called when the draggable starts being dragged.
  final ReorderStartedCallback? onReorderStarted;

  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;

  /// The flag of whether needs long press to trigger dragging mode.
  /// true means it needs long press and false means no need.
  final bool needsLongPressDraggable;

  /// How the children within a run should be places in the main axis.
  ///
  /// For example, if [alignment] is [WrapAlignment.center], the children in
  /// each run are grouped together in the center of their run in the main axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  final WrapAlignment alignment;

  /// How much space to place between children in a run in the main axis.
  ///
  /// For example, if [spacing] is 10.0, the children will be spaced at least
  /// 10.0 logical pixels apart in the main axis.
  ///
  /// If there is additional free space in a run (e.g., because the wrap has a
  /// minimum size that is not filled or because some runs are longer than
  /// others), the additional free space will be allocated according to the
  /// [alignment].
  ///
  /// Defaults to 0.0.
  final double spacing;

  /// How the runs themselves should be placed in the cross axis.
  ///
  /// For example, if [runAlignment] is [WrapAlignment.center], the runs are
  /// grouped together in the center of the overall [Wrap] in the cross axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [alignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  final WrapAlignment runAlignment;

  /// How much space to place between the runs themselves in the cross axis.
  ///
  /// For example, if [runSpacing] is 10.0, the runs will be spaced at least
  /// 10.0 logical pixels apart in the cross axis.
  ///
  /// If there is additional free space in the overall [Wrap] (e.g., because
  /// the wrap has a minimum size that is not filled), the additional free space
  /// will be allocated according to the [runAlignment].
  ///
  /// Defaults to 0.0.
  final double runSpacing;

  /// How the children within a run should be aligned relative to each other in
  /// the cross axis.
  ///
  /// For example, if this is set to [WrapCrossAlignment.end], and the
  /// [direction] is [Axis.horizontal], then the children within each
  /// run will have their bottom edges aligned to the bottom edge of the run.
  ///
  /// Defaults to [WrapCrossAlignment.start].
  ///
  /// See also:
  ///
  ///  * [alignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  final WrapCrossAlignment crossAxisAlignment;

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// Defaults to the ambient [Directionality].
  ///
  /// If the [direction] is [Axis.horizontal], this controls order in which the
  /// children are positioned (left-to-right or right-to-left), and the meaning
  /// of the [alignment] property's [WrapAlignment.start] and
  /// [WrapAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [alignment] is either [WrapAlignment.start] or [WrapAlignment.end], or
  /// there's more than one child, then the [textDirection] (or the ambient
  /// [Directionality]) must not be null.
  ///
  /// If the [direction] is [Axis.vertical], this controls the order in which
  /// runs are positioned, the meaning of the [runAlignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [WrapCrossAlignment.start] and
  /// [WrapCrossAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the
  /// [runAlignment] is either [WrapAlignment.start] or [WrapAlignment.end], the
  /// [crossAxisAlignment] is either [WrapCrossAlignment.start] or
  /// [WrapCrossAlignment.end], or there's more than one child, then the
  /// [textDirection] (or the ambient [Directionality]) must not be null.
  final TextDirection? textDirection;

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// If the [direction] is [Axis.vertical], this controls which order children
  /// are painted in (down or up), the meaning of the [alignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the [alignment]
  /// is either [WrapAlignment.start] or [WrapAlignment.end], or there's
  /// more than one child, then the [verticalDirection] must not be null.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// runs are positioned, the meaning of the [runAlignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [WrapCrossAlignment.start] and
  /// [WrapCrossAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [runAlignment] is either [WrapAlignment.start] or [WrapAlignment.end], the
  /// [crossAxisAlignment] is either [WrapCrossAlignment.start] or
  /// [WrapCrossAlignment.end], or there's more than one child, then the
  /// [verticalDirection] must not be null.
  final VerticalDirection verticalDirection;

  final int? minMainAxisCount;
  final int? maxMainAxisCount;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;
  final bool ignorePrimaryScrollController;

  @override
  _ReorderableWrapState createState() => _ReorderableWrapState();
}

// This top-level state manages an Overlay that contains the list and
// also any Draggables it creates.
//
// _ReorderableListContent manages the list itself and reorder operations.
//
// The Overlay doesn't properly keep state by building new overlay entries,
// and so we cache a single OverlayEntry for use as the list layer.
// That overlay entry then builds a _ReorderableListContent which may
// insert Draggables into the Overlay above itself.
class _ReorderableWrapState extends State<ReorderableWrap> {
  // We use an inner overlay so that the dragging list item doesn't draw outside of the list itself.
  final GlobalKey _overlayKey =
      GlobalKey(debugLabel: '$ReorderableWrap overlay key');

  // This entry contains the scrolling list itself.
  late PassthroughOverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = PassthroughOverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return _ReorderableWrapContent(
          header: widget.header,
          footer: widget.footer,
          children: widget.children,
          direction: widget.direction,
          scrollDirection: widget.scrollDirection,
          onReorder: widget.onReorder,
          onNoReorder: widget.onNoReorder,
          onReorderStarted: widget.onReorderStarted,
          padding: widget.padding,
          buildItemsContainer: widget.buildItemsContainer,
          buildDraggableFeedback: widget.buildDraggableFeedback,
          needsLongPressDraggable: widget.needsLongPressDraggable,
          alignment: widget.alignment,
          spacing: widget.spacing,
          runAlignment: widget.runAlignment,
          runSpacing: widget.runSpacing,
          crossAxisAlignment: widget.crossAxisAlignment,
          textDirection: widget.textDirection,
          verticalDirection: widget.verticalDirection,
          minMainAxisCount: widget.minMainAxisCount,
          maxMainAxisCount: widget.maxMainAxisCount,
          controller: widget.controller,
          reorderAnimationDuration: widget.reorderAnimationDuration,
          scrollAnimationDuration: widget.scrollAnimationDuration,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PassthroughOverlay passthroughOverlay = PassthroughOverlay(
        key: _overlayKey,
        initialEntries: <PassthroughOverlayEntry>[
          _listOverlayEntry,
        ]);
    return widget.ignorePrimaryScrollController
        ? PrimaryScrollController.none(child: passthroughOverlay)
        : passthroughOverlay;
  }
}

// This widget is responsible for the inside of the Overlay in the
// ReorderableListView.
class _ReorderableWrapContent extends StatefulWidget {
  const _ReorderableWrapContent({
    required this.children,
    required this.direction,
    required this.scrollDirection,
    required this.padding,
    required this.onReorder,
    required this.onNoReorder,
    required this.onReorderStarted,
    required this.buildItemsContainer,
    required this.buildDraggableFeedback,
    required this.needsLongPressDraggable,
    required this.alignment,
    required this.spacing,
    required this.runAlignment,
    required this.runSpacing,
    required this.crossAxisAlignment,
    required this.textDirection,
    required this.verticalDirection,
    required this.minMainAxisCount,
    required this.maxMainAxisCount,
    this.header,
    this.footer,
    this.controller,
    this.reorderAnimationDuration = const Duration(milliseconds: 200),
    this.scrollAnimationDuration = const Duration(milliseconds: 200),
  });

  final List<Widget>? header;
  final Widget? footer;
  final ScrollController? controller;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final EdgeInsets? padding;
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final ReorderStartedCallback? onReorderStarted;
  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;
  final bool needsLongPressDraggable;

  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int? minMainAxisCount;
  final int? maxMainAxisCount;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;

  @override
  _ReorderableWrapContentState createState() => _ReorderableWrapContentState();
}

class _ReorderableWrapContentState extends State<_ReorderableWrapContent>
    with TickerProviderStateMixin<_ReorderableWrapContent>, ReorderableMixin {
  // The extent along the [widget.scrollDirection] axis to allow a child to
  // drop into when the user reorders list children.
  //
  // This value is used when the extents haven't yet been calculated from
  // the currently dragging widget, such as when it first builds.
//  static const double _defaultDropAreaExtent = 1.0;

  // The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 0.0;

  // How long an animation to reorder an element in the list takes.
  late Duration _reorderAnimationDuration;

  // How long an animation to scroll to an off-screen element in the
  // list takes.
  late Duration _scrollAnimationDuration;

  // Controls scrolls and measures scroll progress.
  late ScrollController _scrollController;

  // This controls the entrance of the dragging widget into a new place.
  late AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  late AnimationController _ghostController;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
//  int _dragging;
  Widget? _draggingWidget;

  // The last computed size of the feedback widget being dragged.
  Size? _draggingFeedbackSize;

//  List<GlobalObjectKey> _childKeys;
  late List<BuildContext?> _childContexts;
  late List<Size> _childSizes;
  late List<int> _childIndexToDisplayIndex;
  late List<int> _childDisplayIndexToIndex;

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = -1;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostDisplayIndex = -1;

  // The index that the dragging widget currently occupies.
  int _currentDisplayIndex = -1;

  // The widget to move the dragging widget too after the current index.
  int _nextDisplayIndex = -1;

  // Whether or not we are currently scrolling this view to show a widget.
  bool _scrolling = false;

  final GlobalKey _wrapKey = GlobalKey(debugLabel: '$ReorderableWrap wrap key');
  late List<int> _wrapChildRunIndexes;
  late List<int> _childRunIndexes;
  late List<int> _nextChildRunIndexes;
  late List<Widget?> _wrapChildren;

  Size get _dropAreaSize {
    if (_draggingFeedbackSize == null) {
      return Size(0, 0);
    }
    return _draggingFeedbackSize! + Offset(_dropAreaMargin, _dropAreaMargin);
//    double dropAreaWithoutMargin;
//    switch (widget.direction) {
//      case Axis.horizontal:
//        dropAreaWithoutMargin = _draggingFeedbackSize.width;
//        break;
//      case Axis.vertical:
//      default:
//        dropAreaWithoutMargin = _draggingFeedbackSize.height;
//        break;
//    }
//    return dropAreaWithoutMargin + _dropAreaMargin;
  }

  @override
  void initState() {
    super.initState();
    _reorderAnimationDuration = widget.reorderAnimationDuration;
    _scrollAnimationDuration = widget.scrollAnimationDuration;
    _entranceController = AnimationController(
        value: 1.0, vsync: this, duration: _reorderAnimationDuration);
    _ghostController = AnimationController(
        value: 0, vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
//    _childKeys = List.filled(widget.children.length, null);
    _childContexts = List.filled(widget.children.length, null);
    _childSizes = List.filled(widget.children.length, Size(0, 0));
//    _childIndexToDisplayIndex =
//        List.generate(widget.children.length, (int index) => index);
//    _childDisplayIndexToIndex =
//        List.generate(widget.children.length, (int index) => index);
    _wrapChildRunIndexes = List.filled(widget.children.length, -1);
    _childRunIndexes = List.filled(widget.children.length, -1);
    _nextChildRunIndexes = List.filled(widget.children.length, -1);
    _wrapChildren = List.filled(widget.children.length, null);
  }

  @override
  void didChangeDependencies() {
    _scrollController = widget.controller ??
        PrimaryScrollController.of(context) ??
        ScrollController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex({bool isAcceptingNewTarget = false}) {
//    debugPrint('_requestAnimationToNextIndex _dragStartIndex:$_dragStartIndex _ghostDisplayIndex:$_ghostDisplayIndex _currentDisplayIndex:$_currentDisplayIndex _nextDisplayIndex:$_nextDisplayIndex isAcceptingNewTarget:$isAcceptingNewTarget isCompleted:${_entranceController.isCompleted}');
    if (_entranceController.isCompleted) {
      _ghostDisplayIndex = _currentDisplayIndex;
      if (!isAcceptingNewTarget && _nextDisplayIndex == _currentDisplayIndex) {
        // && _dragStartIndex == _ghostIndex
        return;
      }

      _currentDisplayIndex = _nextDisplayIndex;
      _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  // Requests animation to the latest next index if it changes during an animation.
  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  // Scrolls to a target context if that context is not on the screen.
  void _scrollTo(BuildContext context) {
    if (_scrolling) return;
    final RenderObject contextObject = context.findRenderObject()!;
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(contextObject)!;
    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
    final double margin = widget.direction == Axis.horizontal
        ? _dropAreaSize.width
        : _dropAreaSize.height;
    final double scrollOffset = _scrollController.offset;
    final double topOffset = max(
      _scrollController.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final double bottomOffset = min(
      _scrollController.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    final bool onScreen =
        scrollOffset <= topOffset && scrollOffset >= bottomOffset;
    // If the context is off screen, then we request a scroll to make it visible.
    if (!onScreen) {
      _scrolling = true;
      _scrollController.position
          .animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      )
          .then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    }
  }

  // Wraps children in Row or Column, so that the children flow in
  // the widget's scrollDirection.
  Widget _buildContainerForMainAxis({required List<Widget> children}) {
//    MainAxisSize mainAxisSize = MainAxisSize.min;
//    CrossAxisAlignment crossAxisAlignment;
    WrapAlignment runAlignment;
    switch (widget.crossAxisAlignment) {
      case WrapCrossAlignment.start:
//        crossAxisAlignment = CrossAxisAlignment.start;
        runAlignment = WrapAlignment.start;
        break;
      case WrapCrossAlignment.end:
//        crossAxisAlignment = CrossAxisAlignment.end;
        runAlignment = WrapAlignment.end;
        break;
      case WrapCrossAlignment.center:
      default:
//        crossAxisAlignment = CrossAxisAlignment.center;
        runAlignment = WrapAlignment.center;
        break;
    }
    return Wrap(
      direction: widget.direction,
      runAlignment: runAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: children,
    );
//    switch (widget.direction) {
//      case Axis.horizontal:
//        return Row(
//          mainAxisSize: mainAxisSize,
//          crossAxisAlignment: crossAxisAlignment,
//          children: children
//        );
//        break;
//      case Axis.vertical:
//      default:
//        return Column(
//          mainAxisSize: mainAxisSize,
//          crossAxisAlignment: crossAxisAlignment,
//          children: children
//        );
//        break;
//    }
  }

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _wrap(Widget toWrap, int index) {
//    assert(toWrap.key != null);
//    final GlobalKey keyIndexGlobalKey = GlobalObjectKey(toWrap.key);
//    _childKeys[index] = keyIndexGlobalKey;
//    toWrap = KeyedSubtree(key: ValueKey(index), child: toWrap);
    _wrapChildren[index] = toWrap;
    int displayIndex = _childIndexToDisplayIndex[index];
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.

    // Starts dragging toWrap.
    void onDragStarted() {
      setState(() {
        _draggingWidget = toWrap;
//        _dragging = index;//toWrap.key;
        _dragStartIndex = index;
        _ghostDisplayIndex = displayIndex;
        _currentDisplayIndex = displayIndex;
        _nextDisplayIndex = displayIndex;
//        debugPrint('_entranceController:${_entranceController.value} ${_entranceController.status}');
        _entranceController.value = 1.0;
//        _draggingFeedbackSize = keyIndexGlobalKey.currentContext.size;
//        for (int i = 0; i < widget.children.length; i++) {
//          _childSizes[i] = _childKeys[i].currentContext.size;
//        }
        _draggingFeedbackSize = _childContexts[index]!.size;
        for (int i = 0; i < widget.children.length; i++) {
          _childSizes[i] = _childContexts[i]!.size!;
        }

        if (_wrapKey.currentContext != null) {
          RenderWrapWithMainAxisCount wrapRenderObject =
              _wrapKey.currentContext!.findRenderObject()
                  as RenderWrapWithMainAxisCount;
          _wrapChildRunIndexes = wrapRenderObject.childRunIndexes;
          for (int i = 0; i < _childRunIndexes.length; i++) {
            _nextChildRunIndexes[i] =
                _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
          }
        } else {
          if (widget.minMainAxisCount != null &&
              widget.maxMainAxisCount != null &&
              widget.minMainAxisCount == widget.maxMainAxisCount) {
            _wrapChildRunIndexes = List.generate(widget.children.length,
                (int index) => index ~/ widget.minMainAxisCount!);
            for (int i = 0; i < _childRunIndexes.length; i++) {
              _nextChildRunIndexes[i] =
                  _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
            }
          }
        }

//        debugPrint('onDragStarted: index:$index _ghostDisplayIndex:$_ghostDisplayIndex _currentDisplayIndex:$_currentDisplayIndex _dragStartIndex:$_dragStartIndex');
        widget.onReorderStarted?.call(index);
      });
    }

    // Places the value from startIndex one space before the element at endIndex.
    void _reorder(int startIndex, int endIndex) {
//      debugPrint('_reorder: startIndex:$startIndex endIndex:$endIndex');
      if (startIndex != endIndex)
        widget.onReorder(startIndex, endIndex);
      else if (widget.onNoReorder != null) widget.onNoReorder!(startIndex);
      // Animates leftover space in the drop area closed.
      // TODO(djshuckerow): bring the animation in line with the Material
      // specifications.
      _ghostController.reverse(from: 0.1);
      _entranceController.reverse(from: 0);

//      _dragging = null;
      _dragStartIndex = -1;
    }

    void reorder(int startIndex, int endIndex) {
//      debugPrint('reorder: startIndex:$startIndex endIndex:$endIndex');
      setState(() {
        _reorder(startIndex, endIndex);
      });
    }

    // Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
//      reorder(_dragStartIndex, _currentIndex);
      setState(() {
        _reorder(_dragStartIndex, _currentDisplayIndex);
        _dragStartIndex = -1;
        _ghostDisplayIndex = -1;
        _currentDisplayIndex = -1;
        _nextDisplayIndex = -1;
        _draggingWidget = null;
      });
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
          <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length - 1);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final MaterialLocalizations localizations =
          MaterialLocalizations.of(context);

      if (index > 0) {
        semanticsActions[CustomSemanticsAction(
            label: localizations.reorderItemToStart)] = moveToStart;
        String reorderItemBefore = localizations.reorderItemUp;
        if (widget.direction == Axis.horizontal) {
          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemLeft
              : localizations.reorderItemRight;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
            moveBefore;
      }

      // If the item can move to after its current position in the list.
      if (index < widget.children.length - 1) {
        String reorderItemAfter = localizations.reorderItemDown;
        if (widget.direction == Axis.horizontal) {
          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemRight
              : localizations.reorderItemLeft;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
            moveAfter;
        semanticsActions[
                CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
            moveToEnd;
      }

      // We pass toWrap with a GlobalKey into the Draggable so that when a list
      // item gets dragged, the accessibility framework can preserve the selected
      // state of the dragging item.
      //
      // We also apply the relevant custom accessibility actions for moving the item
      // up, down, to the start, and to the end of the list.
      return MergeSemantics(
        child: Semantics(
          customSemanticsActions: semanticsActions,
          child: toWrap,
        ),
      );
//      return KeyedSubtree(
//        key: keyIndexGlobalKey,
//        child: MergeSemantics(
//          child: Semantics(
//            customSemanticsActions: semanticsActions,
//            child: toWrap,
//          ),
//        ),
//      );
    }

    Widget _makeAppearingWidget(Widget child) {
      return makeAppearingWidget(
        child,
        _entranceController,
        null,
        widget.direction,
      );
    }

    Widget _makeDisappearingWidget(Widget child) {
      return makeDisappearingWidget(
        child,
        _ghostController,
        null,
        widget.direction,
      );
    }

    //Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates, List<dynamic> rejectedCandidates) {
    Widget buildDraggable() {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      Widget feedbackBuilder = Builder(builder: (BuildContext context) {
//          RenderRepaintBoundary renderObject = _contentKey.currentContext.findRenderObject();
//          BoxConstraints contentSizeConstraints = BoxConstraints.loose(renderObject.size);
        BoxConstraints contentSizeConstraints = BoxConstraints.loose(
            _draggingFeedbackSize!); //renderObject.constraints
//          debugPrint('feedbackBuilder: contentConstraints:$contentSizeConstraints');
        return (widget.buildDraggableFeedback ?? defaultBuildDraggableFeedback)(
            context, contentSizeConstraints, toWrap);
      });

      bool isReorderable = true;
      if (toWrap is ReorderableItem) {
        isReorderable = toWrap.reorderable;
      }

      Widget child;
      if (!isReorderable) {
        child = toWrapWithSemantics;
      } else {
        // We build the draggable inside of a layout builder so that we can
        // constrain the size of the feedback dragging widget.
        child = this.widget.needsLongPressDraggable
            ? LongPressDraggable<int>(
                maxSimultaneousDrags: 1,
                data: index,
                //toWrap.key,
                ignoringFeedbackSemantics: false,
                feedback: feedbackBuilder,
                // Wrap toWrapWithSemantics with a widget that supports HitTestBehavior
                // to make sure the whole toWrapWithSemantics responds to pointer events, i.e. dragging
                child: MetaData(
                    child: toWrapWithSemantics,
                    behavior: HitTestBehavior.opaque),
                //toWrapWithSemantics,//_dragging == toWrap.key ? const SizedBox() : toWrapWithSemantics,
                childWhenDragging: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                        opacity: 0.2,
                        //child: toWrap,//Container(width: 0, height: 0, child: toWrap)
                        child: _makeAppearingWidget(toWrap))),
                //ConstrainedBox(constraints: contentConstraints),//SizedBox(),
                dragAnchor: DragAnchor.child,
                onDragStarted: onDragStarted,
                // When the drag ends inside a DragTarget widget, the drag
                // succeeds, and we reorder the widget into position appropriately.
                onDragCompleted: onDragEnded,
                // When the drag does not end inside a DragTarget widget, the
                // drag fails, but we still reorder the widget to the last position it
                // had been dragged to.
                onDraggableCanceled: (Velocity velocity, Offset offset) =>
                    onDragEnded(),
              )
            : Draggable<int>(
                maxSimultaneousDrags: 1,
                data: index,
                //toWrap.key,
                ignoringFeedbackSemantics: false,
                feedback: feedbackBuilder,
                child: MetaData(
                    child: toWrapWithSemantics,
                    behavior: HitTestBehavior.opaque),
                childWhenDragging: IgnorePointer(
                  ignoring: true,
                  child: Opacity(
                    opacity: 0.2,
                    child: _makeAppearingWidget(toWrap),
                  ),
                ),
                dragAnchor: DragAnchor.child,
                onDragStarted: onDragStarted,
                onDragCompleted: onDragEnded,
                onDraggableCanceled: (Velocity velocity, Offset offset) =>
                    onDragEnded(),
              );
      }

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= widget.children.length) {
        child = toWrap;
      }

      return child;
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    var builder = Builder(builder: (BuildContext context) {
      Widget draggable = buildDraggable(); //buildDragTarget(null, null, null);
//      _childContexts[index] = context;
//      var containedDraggable = draggable;
//      draggable = KeyedSubtree(key: keyIndexGlobalKey, child: draggable);
      var containedDraggable = Builder(builder: (BuildContext context) {
        _childContexts[index] = context;
//        return KeyedSubtree(key: keyIndexGlobalKey, child: draggable);
//        return KeyedSubtree(key: ValueKey(index), child: draggable);
        return draggable;
      });
//      debugPrint('index:$index displayIndex:$displayIndex _nextDisplayIndex:$_nextDisplayIndex _currentDisplayIndex:$_currentDisplayIndex _ghostDisplayIndex:$_ghostDisplayIndex _dragStartIndex:$_dragStartIndex');
//      debugPrint(' _childRunIndexes:$_childRunIndexes _nextChildRunIndexes:$_nextChildRunIndexes _wrapChildRunIndexes:$_wrapChildRunIndexes');

      List<Widget> _includeMovedAdjacentChildIfNeeded(
          Widget child, int childDisplayIndex) {
//        debugPrint(' checking ${_childDisplayIndexToIndex[childDisplayIndex]}($childDisplayIndex)');
        int checkingTargetDisplayIndex = -1;
        if (_ghostDisplayIndex < _currentDisplayIndex &&
            childDisplayIndex > _ghostDisplayIndex) {
          checkingTargetDisplayIndex = childDisplayIndex - 1;
        } else if (_ghostDisplayIndex > _currentDisplayIndex &&
            childDisplayIndex < _ghostDisplayIndex) {
          checkingTargetDisplayIndex = childDisplayIndex + 1;
        }
        if (checkingTargetDisplayIndex == -1) {
          return [child];
        }
        int checkingTargetIndex =
            _childDisplayIndexToIndex[checkingTargetDisplayIndex];
        if (checkingTargetIndex == _dragStartIndex) {
          return [child];
        }
        if (_childRunIndexes[checkingTargetIndex] == -1 ||
            _childRunIndexes[checkingTargetIndex] ==
                _wrapChildRunIndexes[checkingTargetDisplayIndex]) {
          return [child];
        }
//        debugPrint(' make $checkingTargetIndex($checkingTargetDisplayIndex) disappearing around $index');
        Widget disappearingPreChild =
            _makeDisappearingWidget(_wrapChildren[checkingTargetIndex]!);
//        return _buildContainerForMainAxis(
//          children: _ghostDisplayIndex < _currentDisplayIndex
//            ? [disappearingPreChild, child]
//            : [child, disappearingPreChild]
//        );
//        debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_wrap.dart(874) $this._includeMovedAdjacentChildIfNeeded: ${_ghostDisplayIndex < _currentDisplayIndex}');
        return _ghostDisplayIndex < _currentDisplayIndex
            ? [disappearingPreChild, child]
            : [child, disappearingPreChild];
      }

      _nextChildRunIndexes[index] = _wrapChildRunIndexes[displayIndex];

      if (_currentDisplayIndex == -1 || displayIndex == _currentDisplayIndex) {
        //we still wrap dragTarget with a container so that widget's depths are the same and it prevents layout alignment issue
        return _buildContainerForMainAxis(
            children: _includeMovedAdjacentChildIfNeeded(
                containedDraggable, displayIndex));
      }

      bool _onWillAccept(int? toAccept, bool isPre) {
        int nextDisplayIndex;
        if (_currentDisplayIndex < displayIndex) {
          nextDisplayIndex = isPre ? displayIndex - 1 : displayIndex;
        } else {
          nextDisplayIndex = !isPre ? displayIndex + 1 : displayIndex;
        }

        bool movingToAdjacentChild =
            nextDisplayIndex <= _currentDisplayIndex + 1 &&
                nextDisplayIndex >= _currentDisplayIndex - 1;
        bool willAccept = _dragStartIndex == toAccept &&
//          toAccept != toWrap.key &&
            toAccept != index &&
            (_entranceController.isCompleted || !movingToAdjacentChild) &&
            _currentDisplayIndex != nextDisplayIndex;
//        debugPrint('_onWillAccept: index:$index displayIndex:$displayIndex toAccept:$toAccept return:$willAccept isPre:$isPre '
//          '_currentDisplayIndex:$_currentDisplayIndex nextDisplayIndex:$nextDisplayIndex _dragStartIndex:$_dragStartIndex');

        if (!willAccept) {
          return false;
        }
        if (!(_childDisplayIndexToIndex[_currentDisplayIndex] != index &&
            _currentDisplayIndex != displayIndex)) {
          return false;
        }

        if (_wrapKey.currentContext != null) {
          RenderWrapWithMainAxisCount wrapRenderObject =
              _wrapKey.currentContext!.findRenderObject()
                  as RenderWrapWithMainAxisCount;
          _wrapChildRunIndexes = wrapRenderObject.childRunIndexes;
//          for (int i=0; i<_childRunIndexes.length; i++) {
//            _childRunIndexes[i] = _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
//          }
        } else {
          if (widget.minMainAxisCount != null &&
              widget.maxMainAxisCount != null &&
              widget.minMainAxisCount == widget.maxMainAxisCount) {
            _wrapChildRunIndexes = List.generate(widget.children.length,
                (int index) => index ~/ widget.minMainAxisCount!);
//            for (int i=0; i<_childRunIndexes.length; i++) {
//              _childRunIndexes[i] = _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
//            }
          }
        }

        setState(() {
          _nextDisplayIndex = nextDisplayIndex;

          _requestAnimationToNextIndex(isAcceptingNewTarget: true);
        });
        _scrollTo(context);
        // If the target is not the original starting point, then we will accept the drop.
        return willAccept; //_dragging == toAccept && toAccept != toWrap.key;
      }

      Widget preDragTarget = DragTarget<int>(
        builder: (BuildContext context, List<int?> acceptedCandidates,
                List<dynamic> rejectedCandidates) =>
            SizedBox(),
        onWillAccept: (int? toAccept) => _onWillAccept(toAccept, true),
        onAccept: (int accepted) {},
        onLeave: (Object? leaving) {},
      );
      Widget nextDragTarget = DragTarget<int>(
        builder: (BuildContext context, List<int?> acceptedCandidates,
                List<dynamic> rejectedCandidates) =>
            SizedBox(),
        onWillAccept: (int? toAccept) => _onWillAccept(toAccept, false),
        onAccept: (int accepted) {},
        onLeave: (Object? leaving) {},
      );

      Widget dragTarget = Stack(
//        key: keyIndexGlobalKey,
//        fit: StackFit.passthrough,
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          containedDraggable,
          Positioned(
              left: 0,
              top: 0,
              width: widget.direction == Axis.horizontal
                  ? _childSizes[index].width / 2
                  : _childSizes[index].width,
              height: widget.direction == Axis.vertical
                  ? _childSizes[index].height / 2
                  : _childSizes[index].height,
              child: preDragTarget),
          Positioned(
              right: 0,
              bottom: 0,
              width: widget.direction == Axis.horizontal
                  ? _childSizes[index].width / 2
                  : _childSizes[index].width,
              height: widget.direction == Axis.vertical
                  ? _childSizes[index].height / 2
                  : _childSizes[index].height,
              child: nextDragTarget),
        ],
      );
//      return dragTarget;
//      Widget dragTarget = DragTarget<Key>(
//        builder: buildDragTarget,
//        onWillAccept: (Key toAccept) {
//          bool willAccept = _dragging == toAccept && toAccept != toWrap.key && !_entranceController.isAnimating;
//          debugPrint('onWillAccept: toAccept:$toAccept return:$willAccept _nextIndex:$_nextIndex index:$index _currentIndex:$_currentIndex _dragStartIndex:$_dragStartIndex');
//
//          if (!willAccept) {
//            return false;
//          }
//
//          setState(() {
//            if (willAccept) {
//              int shiftedIndex = index;
//              if (index == _dragStartIndex) {
//                shiftedIndex = _ghostIndex;
//              } else if (index > _dragStartIndex && index <= _ghostIndex) {
//                shiftedIndex--;
//              } else if (index < _dragStartIndex && index >= _ghostIndex) {
//                shiftedIndex++;
//              }
//              _nextIndex = shiftedIndex;
//            } else {
//              _nextIndex = index;
//            }
//
//            _requestAnimationToNextIndex(isAcceptingNewTarget: true);
//          });
//          _scrollTo(context);
//          // If the target is not the original starting point, then we will accept the drop.
//          return willAccept;//_dragging == toAccept && toAccept != toWrap.key;
//        },
//        onAccept: (Key accepted) {},
//        onLeave: (Object leaving) {},
//      );

//      dragTarget = KeyedSubtree(
//        key: keyIndexGlobalKey,
//        child: dragTarget
//      );

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = _draggingWidget == null
          ? SizedBox.fromSize(size: _dropAreaSize)
          : Opacity(opacity: 0.2, child: _draggingWidget);
//      Widget spacing = SizedBox.fromSize(size: _dropAreaSize, child: Container(color: Colors.red));

      if (_childRunIndexes[index] != -1 &&
          _childRunIndexes[index] != _wrapChildRunIndexes[displayIndex]) {
        dragTarget = _makeAppearingWidget(dragTarget);
      }

      if (displayIndex == _ghostDisplayIndex) {
        Widget ghostSpacing = _makeDisappearingWidget(spacing);
        if (_ghostDisplayIndex < _currentDisplayIndex) {
          //ghost is on the left of current, so shift it to the right
          return _buildContainerForMainAxis(
              children: [ghostSpacing] +
                  _includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex));
        } else if (_ghostDisplayIndex > _currentDisplayIndex) {
          return _buildContainerForMainAxis(
              children:
                  _includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex) +
                      [ghostSpacing]);
        }
      }

      //we still wrap dragTarget with a container so that widget's depths are the same and it prevent's layout alignment issue
      return _buildContainerForMainAxis(
          children:
              _includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex));

//      if (shiftedIndex == _currentDisplayIndex) {
//        Widget entranceSpacing = SizeTransitionWithIntrinsicSize(
//          sizeFactor: _entranceController,
//          axis: widget.direction,
//          child: spacing,//Column(children: [spacing, Text('eeeeee $index')])
//        );
//
//        Widget ghostSpacing = SizeTransitionWithIntrinsicSize(
//          sizeFactor: _ghostController,
//          axis: widget.direction,
//          child: spacing,//Column(children: [spacing, Text('gggggg $index')]),
//        );
//
//        if (_dragStartIndex == -1) {
//          return _buildContainerForMainAxis(children: [dragTarget]);
//        } else if (_currentDisplayIndex > _ghostDisplayIndex) {
//          //the ghost is moving down, i.e. the tile below the ghost is moving up
////          debugPrint('index:$index item moving up / ghost moving down');
//          return _buildContainerForMainAxis(children: [ghostSpacing, dragTarget, entranceSpacing]);
//        } else if (_currentDisplayIndex < _ghostDisplayIndex) {
//          //the ghost is moving up, i.e. the tile above the ghost is moving down
////          debugPrint('index:$index item moving down / ghost moving up');
//          return _buildContainerForMainAxis(children: [entranceSpacing, dragTarget, ghostSpacing]);
//        } else {
////          debugPrint('index:$index using _entranceController: spacing on top:${!(_dragStartIndex < _currentIndex)}');
//          return _buildContainerForMainAxis(children: _dragStartIndex < _currentDisplayIndex ? [dragTarget, entranceSpacing] : [entranceSpacing, dragTarget]);
//        }
//      }
//
//      return dragTarget;
    });
    return KeyedSubtree(key: ValueKey(index), child: builder);
  }

  @override
  Widget build(BuildContext context) {
//    assert(debugCheckHasMaterialLocalizations(context));
    // We use the layout builder to constrain the cross-axis size of dragging child widgets.
//    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
//    debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_wrap.dart(1084) $this.build: ');
//    _childKeys = List.filled(widget.children.length, null);
//    _childSizes = List.filled(widget.children.length, Size(0, 0));
    List<E> _resizeListMember<E>(List<E> listVar, E initValue) {
      if (listVar.length < widget.children.length) {
        return listVar +
            List.filled(widget.children.length - listVar.length, initValue);
      } else if (listVar.length > widget.children.length) {
        return listVar.sublist(0, widget.children.length);
      }
      return listVar;
    }

//    _childKeys = _resizeListMember(_childKeys, null);
    _childContexts = _resizeListMember(_childContexts, null);
    _childSizes = _resizeListMember(_childSizes, Size(0, 0));

    _childDisplayIndexToIndex =
        List.generate(widget.children.length, (int index) => index);
    _childIndexToDisplayIndex =
        List.generate(widget.children.length, (int index) => index);
    if (_dragStartIndex >= 0 &&
        _currentDisplayIndex >= 0 &&
        _dragStartIndex != _currentDisplayIndex) {
      _childDisplayIndexToIndex.insert(_currentDisplayIndex,
          _childDisplayIndexToIndex.removeAt(_dragStartIndex));
    }
    int index = 0;
    _childDisplayIndexToIndex.forEach((int element) {
      _childIndexToDisplayIndex[element] = index++;
    });

    _wrapChildRunIndexes = _resizeListMember(_wrapChildRunIndexes, -1);
    _childRunIndexes = _resizeListMember(_childRunIndexes, -1);
    _nextChildRunIndexes = _resizeListMember(_nextChildRunIndexes, -1);
    _wrapChildren = _resizeListMember(_wrapChildren, null);
//    debugPrint('build called! _currentIndex:$_currentDisplayIndex _dragStartIndex:$_dragStartIndex '
//      '_childIndexToDisplayIndex:$_childIndexToDisplayIndex _childDisplayIndexToIndex:$_childDisplayIndexToIndex _childRunIndexes:$_childRunIndexes _nextChildRunIndexes:$_nextChildRunIndexes');

    _childRunIndexes = _nextChildRunIndexes.toList();

    final List<Widget> wrappedChildren = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      wrappedChildren.add(_wrap(widget.children[i], i));
    }
    if (_dragStartIndex >= 0 &&
        _currentDisplayIndex >= 0 &&
        _dragStartIndex != _currentDisplayIndex) {
      //we are dragging an widget
      wrappedChildren.insert(
          _currentDisplayIndex, wrappedChildren.removeAt(_dragStartIndex));
    }
    if (widget.header != null) {
      wrappedChildren.insertAll(0, widget.header!);
    }
    if (widget.footer != null) {
      wrappedChildren.add(widget.footer!);
    }

    if (widget.controller != null &&
        PrimaryScrollController.of(context) == null) {
      return (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
          context, widget.direction, wrappedChildren);
    } else {
      return SingleChildScrollView(
//      key: _contentKey,
        scrollDirection: widget.scrollDirection,
        child: (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
            context, widget.direction, wrappedChildren),
        padding: widget.padding,
        controller: _scrollController,
      );
    }
//    });
  }

  Widget defaultBuildItemsContainer(
      BuildContext context, Axis direction, List<Widget> children) {
    return WrapWithMainAxisCount(
      key: _wrapKey,
      direction: direction,
      alignment: widget.alignment,
      spacing: widget.spacing,
      runAlignment: widget.runAlignment,
      runSpacing: widget.runSpacing,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      children: children,
      minMainAxisCount: widget.minMainAxisCount,
      maxMainAxisCount: widget.maxMainAxisCount,
    );
  }

  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: new Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
        child:
            Card(child: ConstrainedBox(constraints: constraints, child: child)),
        elevation: 6.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
