// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';

//import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

//import 'debug.dart';
//import 'material.dart';
//import 'material_localizations.dart';

import './passthrough_overlay.dart';
import './typedefs.dart';

// Examples can assume:
// class MyDataObject { }

/// The callback used by [ReorderableListView] to move an item to a new
/// position in a list.
///
/// Implementations should remove the corresponding list item at [oldIndex]
/// and reinsert it at [newIndex].
///
/// If [oldIndex] is before [newIndex], removing the item at [oldIndex] from the
/// list will reduce the list's length by one. Implementations used by
/// [ReorderableListView] will need to account for this when inserting before
/// [newIndex].
///
/// {@tool sample}
///
/// ```dart
/// final List<MyDataObject> backingList = <MyDataObject>[/* ... */];
///
/// void handleReorder(int oldIndex, int newIndex) {
///   if (oldIndex < newIndex) {
///     // removing the item at oldIndex will shorten the list by 1.
///     newIndex -= 1;
///   }
///   final MyDataObject element = backingList.removeAt(oldIndex);
///   backingList.insert(newIndex, element);
/// }
/// ```
/// {@end-tool}
//typedef ReorderCallback = void Function(int oldIndex, int newIndex);

//typedef BuildItemsContainer = Widget Function(BuildContext context, Axis direction, List<Widget> children);
//typedef BuildDraggableFeedback = Widget Function(BuildContext context, BoxConstraints constraints, Widget child);

/// A list whose items the user can interactively reorder by dragging.
///
/// This class is appropriate for views with a small number of
/// children because constructing the [List] requires doing work for every
/// child that could possibly be displayed in the list view instead of just
/// those children that are actually visible.
///
/// All [children] must have a key.
class ReorderableFlex extends StatefulWidget {

  /// Creates a reorderable list.
  ReorderableFlex({
    Key key,
    this.header,
    this.footer,
    @required this.children,
    @required this.onReorder,
    @required this.direction,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.buildItemsContainer,
    this.buildDraggableFeedback,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }): assert(direction != null),
      assert(onReorder != null),
      assert(children != null),
      assert(
      children.every((Widget w) => w.key != null),
      'All children of this widget must have a key.',
      ),
      super(key: key);

  /// A non-reorderable header widget to show before the list.
  ///
  /// If null, no header will appear before the list.
  final Widget header;
  final Widget footer;

  /// The widgets to display.
  final List<Widget> children;

  /// The [Axis] along which the list scrolls.
  ///
  /// List [children] can only drag along this [Axis].
  final Axis direction;
  final Axis scrollDirection;

  /// The amount of space by which to inset the [children].
  final EdgeInsets padding;

  /// Called when a list child is dropped into a new position to shuffle the
  /// underlying list.
  ///
  /// This [ReorderableListView] calls [onReorder] after a list child is dropped
  /// into a new position.
  final ReorderCallback onReorder;

  final BuildItemsContainer buildItemsContainer;
  final BuildDraggableFeedback buildDraggableFeedback;

  final MainAxisAlignment mainAxisAlignment;

  @override
  _ReorderableFlexState createState() => _ReorderableFlexState();
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
class _ReorderableFlexState extends State<ReorderableFlex> {
  // We use an inner overlay so that the dragging list item doesn't draw outside of the list itself.
  final GlobalKey _overlayKey = GlobalKey(debugLabel: '$ReorderableFlex overlay key');

  // This entry contains the scrolling list itself.
  PassthroughOverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = PassthroughOverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return _ReorderableFlexContent(
          header: widget.header,
          footer: widget.footer,
          children: widget.children,
          direction: widget.direction,
          scrollDirection: widget.scrollDirection,
          onReorder: widget.onReorder,
          padding: widget.padding,
          buildItemsContainer: widget.buildItemsContainer,
          buildDraggableFeedback: widget.buildDraggableFeedback,
          mainAxisAlignment: widget.mainAxisAlignment,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PassthroughOverlay(
      key: _overlayKey,
      initialEntries: <PassthroughOverlayEntry>[
        _listOverlayEntry,
      ]);
  }

}

// This widget is responsible for the inside of the Overlay in the
// ReorderableListView.
class _ReorderableFlexContent extends StatefulWidget {
  const _ReorderableFlexContent({
    this.header,
    this.footer,
    @required this.children,
    @required this.direction,
    @required this.scrollDirection,
    @required this.padding,
    @required this.onReorder,
    @required this.buildItemsContainer,
    @required this.buildDraggableFeedback,
    @required this.mainAxisAlignment,
  });

  final Widget header;
  final Widget footer;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final EdgeInsets padding;
  final ReorderCallback onReorder;
  final BuildItemsContainer buildItemsContainer;
  final BuildDraggableFeedback buildDraggableFeedback;

  final MainAxisAlignment mainAxisAlignment;

  @override
  _ReorderableFlexContentState createState() => _ReorderableFlexContentState();
}

class _ReorderableFlexContentState extends State<_ReorderableFlexContent>
  with TickerProviderStateMixin<_ReorderableFlexContent>
{

  // The extent along the [widget.scrollDirection] axis to allow a child to
  // drop into when the user reorders list children.
  //
  // This value is used when the extents haven't yet been calculated from
  // the currently dragging widget, such as when it first builds.
//  static const double _defaultDropAreaExtent = 1.0;

  // The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 0.0;

  // How long an animation to reorder an element in the list takes.
  static const Duration _reorderAnimationDuration = Duration(milliseconds: 200);

  // How long an animation to scroll to an off-screen element in the
  // list takes.
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 200);

  // Controls scrolls and measures scroll progress.
  ScrollController _scrollController;

  // This controls the entrance of the dragging widget into a new place.
  AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  AnimationController _ghostController;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
  Key _dragging;
  Widget _draggingWidget;

  // The last computed size of the feedback widget being dragged.
  Size _draggingFeedbackSize;

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = -1;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostIndex = -1;

  // The index that the dragging widget currently occupies.
  int _currentIndex = -1;

  // The widget to move the dragging widget too after the current index.
  int _nextIndex = 0;

  // Whether or not we are currently scrolling this view to show a widget.
  bool _scrolling = false;

  final GlobalKey _contentKey = GlobalKey(debugLabel: '$ReorderableFlex content key');

  Size get _dropAreaSize {
    if (_draggingFeedbackSize == null) {
      return Size(0, 0);
    }
    return _draggingFeedbackSize + Offset(_dropAreaMargin, _dropAreaMargin);
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
    _entranceController = AnimationController(value: 1.0, vsync: this, duration: _reorderAnimationDuration);
    _ghostController = AnimationController(value: 0, vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
  }

  @override
  void didChangeDependencies() {
    _scrollController = PrimaryScrollController.of(context) ?? ScrollController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex({bool isAcceptingNewTarget=false}) {
//    debugPrint('_requestAnimationToNextIndex _dragStartIndex:$_dragStartIndex _ghostIndex:$_ghostIndex _currentIndex:$_currentIndex _nextIndex:$_nextIndex isAcceptingNewTarget:$isAcceptingNewTarget isCompleted:${_entranceController.isCompleted}');
    if (_entranceController.isCompleted) {
      _ghostIndex = _currentIndex;
      if (!isAcceptingNewTarget && _nextIndex == _currentIndex) {// && _dragStartIndex == _ghostIndex
        return;
      }

      _currentIndex = _nextIndex;
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
    if (_scrolling)
      return;
    final RenderObject contextObject = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(contextObject);
    assert(viewport != null);
    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
    final double margin = widget.direction == Axis.horizontal ? _dropAreaSize.width : _dropAreaSize.height;
    final double scrollOffset = _scrollController.offset;
    final double topOffset = max(
      _scrollController.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final double bottomOffset = min(
      _scrollController.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    final bool onScreen = scrollOffset <= topOffset && scrollOffset >= bottomOffset;

    // If the context is off screen, then we request a scroll to make it visible.
    if (!onScreen) {
      _scrolling = true;
      _scrollController.position.animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      ).then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    }
  }

  // Wraps children in Row or Column, so that the children flow in
  // the widget's scrollDirection.
  Widget _buildContainerForMainAxis({List<Widget> children}) {
    switch (widget.direction) {
      case Axis.horizontal:
        return Row(mainAxisSize: MainAxisSize.min, children: children, mainAxisAlignment: widget.mainAxisAlignment);
      case Axis.vertical:
      default:
        return Column(mainAxisSize: MainAxisSize.min, children: children, mainAxisAlignment: widget.mainAxisAlignment);
    }
  }

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _wrap(Widget toWrap, int index) {
    assert(toWrap.key != null);
    final GlobalObjectKey keyIndexGlobalKey = GlobalObjectKey(toWrap.key);
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.

    // Starts dragging toWrap.
    void onDragStarted() {
      setState(() {
        _draggingWidget = toWrap;
        _dragging = toWrap.key;
        _dragStartIndex = index;
        _ghostIndex = index;
        _currentIndex = index;
        _entranceController.value = 1.0;
        _draggingFeedbackSize = keyIndexGlobalKey.currentContext.size;
      });
    }

    // Places the value from startIndex one space before the element at endIndex.
    void _reorder(int startIndex, int endIndex) {
//      debugPrint('startIndex:$startIndex endIndex:$endIndex');
      if (startIndex != endIndex)
        widget.onReorder(startIndex, endIndex);
      // Animates leftover space in the drop area closed.
      // TODO(djshuckerow): bring the animation in line with the Material
      // specifications.
      _ghostController.reverse(from: 0.1);
      _entranceController.reverse(from: 0);

      _dragging = null;
    }
    void reorder(int startIndex, int endIndex) {
//      debugPrint('startIndex:$startIndex endIndex:$endIndex');
      setState(() {
        _reorder(startIndex, endIndex);
      });
    }

    // Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
//      reorder(_dragStartIndex, _currentIndex);
      setState(() {
        _reorder(_dragStartIndex, _currentIndex);
        _dragStartIndex = -1;
        _ghostIndex = -1;
        _currentIndex = -1;
        _draggingWidget = null;
      });
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions = <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final MaterialLocalizations localizations = MaterialLocalizations.of(context);

      // If the item can move to before its current position in the list.
      if (index > 0) {
        semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToStart)] = moveToStart;
        String reorderItemBefore = localizations.reorderItemUp;
        if (widget.direction == Axis.horizontal) {
          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemLeft
            : localizations.reorderItemRight;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] = moveBefore;
      }

      // If the item can move to after its current position in the list.
      if (index < widget.children.length - 1) {
        String reorderItemAfter = localizations.reorderItemDown;
        if (widget.direction == Axis.horizontal) {
          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemRight
            : localizations.reorderItemLeft;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] = moveAfter;
        semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToEnd)] = moveToEnd;
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
      var transition = SizeTransition(
        sizeFactor: _entranceController,
        axis: widget.direction,
        child: FadeTransition(
          opacity: _entranceController,
          child: child
        ),//Column(children: [spacing, Text('eeeeee $index')])
      );

      BoxConstraints contentSizeConstraints = BoxConstraints.loose(_draggingFeedbackSize);
      return ConstrainedBox(constraints: contentSizeConstraints, child: transition);
    }
    Widget _makeDisappearingWidget(Widget child) {
      var transition = SizeTransition(
        sizeFactor: _ghostController,
        axis: widget.direction,
        child: FadeTransition(
          opacity: _ghostController,
          child: child
        ),
      );

      BoxConstraints contentSizeConstraints = BoxConstraints.loose(_draggingFeedbackSize);
      return ConstrainedBox(constraints: contentSizeConstraints, child: transition);
    }

    Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates, List<dynamic> rejectedCandidates) {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      Widget feedbackBuilder = Builder(
        builder: (BuildContext context) {
//          RenderRepaintBoundary renderObject = _contentKey.currentContext.findRenderObject();
//          BoxConstraints contentSizeConstraints = BoxConstraints.loose(renderObject.size);
          BoxConstraints contentSizeConstraints = BoxConstraints.loose(_draggingFeedbackSize);//renderObject.constraints
//          debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_flex.dart(515) $this.buildDragTarget: contentConstraints:$contentSizeConstraints _draggingFeedbackSize:$_draggingFeedbackSize');
          return (widget.buildDraggableFeedback ?? defaultBuildDraggableFeedback)(context, contentSizeConstraints, toWrap);
        }
      );

      // We build the draggable inside of a layout builder so that we can
      // constrain the size of the feedback dragging widget.
      Widget child = LongPressDraggable<Key>(
        maxSimultaneousDrags: 1,
        axis: widget.direction,
        data: toWrap.key,
        ignoringFeedbackSemantics: false,
//        feedback: Container(
//          alignment: Alignment.topLeft,
//          // These constraints will limit the cross axis of the drawn widget.
//          constraints: constraints,
//          child: Material(
//            elevation: 6.0,
//            child: IntrinsicWidth(child: toWrapWithSemantics),
//          ),
//        ),
        feedback: feedbackBuilder,
//        feedback: Transform(
//          transform: new Matrix4.rotationZ(0),
//          alignment: FractionalOffset.topLeft,
//          child: Material(
//            child: Card(child: ConstrainedBox(constraints: BoxConstraints.tightFor(width: 100), child: toWrapWithSemantics)),
//            elevation: 6.0,
//            color: Colors.transparent,
//            borderRadius: BorderRadius.zero,
//          ),
//        ),
        // Wrap toWrapWithSemantics with a widget that supports HitTestBehavior
        // to make sure the whole toWrapWithSemantics responds to pointer events, i.e. dragging
        child: MetaData(child: toWrapWithSemantics, behavior: HitTestBehavior.opaque),//toWrapWithSemantics,//_dragging == toWrap.key ? const SizedBox() : toWrapWithSemantics,
        childWhenDragging: IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0,
            child: Container(width: 0, height: 0, child: toWrap)
          )
        ),//ConstrainedBox(constraints: contentConstraints),//SizedBox(),
        dragAnchor: DragAnchor.child,
        onDragStarted: onDragStarted,
        // When the drag ends inside a DragTarget widget, the drag
        // succeeds, and we reorder the widget into position appropriately.
        onDragCompleted: onDragEnded,
        // When the drag does not end inside a DragTarget widget, the
        // drag fails, but we still reorder the widget to the last position it
        // had been dragged to.
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          onDragEnded();
        },
      );

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= widget.children.length) {
        child = toWrap;
      }

//      // Determine the size of the drop area to show under the dragging widget.
//      Widget spacing;
//      switch (widget.direction) {
//        case Axis.horizontal:
//          spacing = SizedBox(width: _dropAreaExtent);
//          break;
//        case Axis.vertical:
//        default:
//          spacing = SizedBox(height: _dropAreaExtent);
//          break;
//      }

//      // We open up a space under where the dragging widget currently is to
//      // show it can be dropped.
//      if (_currentIndex == index) {
//        Widget entranceSpacing = SizeTransition(
//          sizeFactor: _entranceController,
//          axis: widget.direction,
//          child: Row(children: [spacing, Text('eeeeeeeeeeeee $index')])
//        );
//
//        return _buildContainerForScrollDirection(children: _currentIndex > _ghostIndex ? [child, entranceSpacing] : [entranceSpacing, child]);
//      }
//      // We close up the space under where the dragging widget previously was
//      // with the ghostController animation.
//      if (_ghostIndex == index) {
//        Widget ghostSpacing = SizeTransition(
//          sizeFactor: _ghostController,
//          axis: widget.direction,
//          child: Row(children: [spacing, Text('gggggggg $index')]),
//        );
//        return _buildContainerForScrollDirection(children: _currentIndex > _ghostIndex ? [child, ghostSpacing] : [ghostSpacing, child]);
//      }
      return child;
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    return Builder(builder: (BuildContext context) {
      Widget dragTarget = DragTarget<Key>(
        builder: buildDragTarget,
        onWillAccept: (Key toAccept) {
          bool willAccept = _dragging == toAccept && toAccept != toWrap.key;
//          debugPrint('onWillAccept: toAccept:$toAccept return:$willAccept _nextIndex:$_nextIndex index:$index _currentIndex:$_currentIndex _dragStartIndex:$_dragStartIndex');

          setState(() {
            if (willAccept) {
              int shiftedIndex = index;
              if (index == _dragStartIndex) {
                shiftedIndex = _ghostIndex;
              } else if (index > _dragStartIndex && index <= _ghostIndex) {
                shiftedIndex--;
              } else if (index < _dragStartIndex && index >= _ghostIndex) {
                shiftedIndex++;
              }
              _nextIndex = shiftedIndex;
            } else {
              _nextIndex = index;
            }

            _requestAnimationToNextIndex(isAcceptingNewTarget: true);
          });
          _scrollTo(context);
          // If the target is not the original starting point, then we will accept the drop.
          return willAccept;//_dragging == toAccept && toAccept != toWrap.key;
        },
        onAccept: (Key accepted) {},
        onLeave: (Key leaving) {},
      );

      dragTarget = KeyedSubtree(
        key: keyIndexGlobalKey,
        child: dragTarget
      );

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = _draggingWidget == null ? SizedBox.fromSize(size: _dropAreaSize): Opacity(opacity: 0.2, child: _draggingWidget);
//      Widget spacing = SizedBox.fromSize(
//        size: _dropAreaSize,
//        child: _draggingWidget != null ? Opacity(opacity: 0.2, child: _draggingWidget) : null,
//      );
      // We open up a space under where the dragging widget currently is to
      // show it can be dropped.
      int shiftedIndex = index;
      if (_currentIndex != _ghostIndex) {
        if (index == _dragStartIndex) {
          shiftedIndex = _ghostIndex;
        } else if (index > _dragStartIndex && index <= _ghostIndex) {
          shiftedIndex--;
        } else if (index < _dragStartIndex && index >= _ghostIndex) {
          shiftedIndex++;
        }
      }
//      debugPrint('index:$index shiftedIndex:$shiftedIndex _nextIndex:$_nextIndex _currentIndex:$_currentIndex _ghostIndex:$_ghostIndex _dragStartIndex:$_dragStartIndex');
      if (shiftedIndex == _currentIndex) {
        Widget entranceSpacing = _makeAppearingWidget(spacing);
        Widget ghostSpacing = _makeDisappearingWidget(spacing);

        if (_dragStartIndex == -1) {
          return _buildContainerForMainAxis(children: [dragTarget]);
        } else if (_currentIndex > _ghostIndex) {
          //the ghost is moving down, i.e. the tile below the ghost is moving up
//          debugPrint('index:$index item moving up / ghost moving down');
          return _buildContainerForMainAxis(children: [ghostSpacing, dragTarget, entranceSpacing]);
        } else if (_currentIndex < _ghostIndex) {
          //the ghost is moving up, i.e. the tile above the ghost is moving down
//          debugPrint('index:$index item moving down / ghost moving up');
          return _buildContainerForMainAxis(children: [entranceSpacing, dragTarget, ghostSpacing]);
        } else {
//          debugPrint('index:$index using _entranceController: spacing on top:${!(_dragStartIndex < _currentIndex)}');
          return _buildContainerForMainAxis(children: _dragStartIndex < _currentIndex ? [dragTarget, entranceSpacing] : [entranceSpacing, dragTarget]);
        }
      }

      //we still wrap dragTarget with a container so that widget's depths are the same and it prevent's layout alignment issue
      return _buildContainerForMainAxis(children: [dragTarget]);
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    // We use the layout builder to constrain the cross-axis size of dragging child widgets.
//    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
    final List<Widget> wrappedChildren = <Widget>[];
    if (widget.header != null) {
      wrappedChildren.add(widget.header);
    }
    for (int i = 0; i < widget.children.length; i += 1) {
      wrappedChildren.add(_wrap(widget.children[i], i));
    }
    if (widget.footer != null) {
      wrappedChildren.add(widget.footer);
    }
//      const Key endWidgetKey = Key('DraggableList - End Widget');
//      Widget finalDropArea;
//      switch (widget.direction) {
//        case Axis.horizontal:
//          finalDropArea = SizedBox(
//            key: endWidgetKey,
//            width: _defaultDropAreaExtent,
//            height: double.infinity,//constraints.maxHeight,
//          );
//          break;
//        case Axis.vertical:
//        default:
//          finalDropArea = SizedBox(
//            key: endWidgetKey,
//            height: _defaultDropAreaExtent,
//            width: double.infinity,//constraints.maxWidth,
//          );
//          break;
//      }
//      wrappedChildren.add(_wrap(
//        finalDropArea,
//        widget.children.length,
//        constraints),
//      );

//      return _buildContainerForScrollDirection(children: wrappedChildren);

//      return SingleChildScrollView(
//        scrollDirection: widget.direction,
//        child: _buildContainerForScrollDirection(children: wrappedChildren),
//        padding: widget.padding,
//        controller: _scrollController,
//      );

    return SingleChildScrollView(
      key: _contentKey,
      scrollDirection: widget.scrollDirection,
      child: (widget.buildItemsContainer ?? defaultBuildItemsContainer)(context, widget.direction, wrappedChildren),
      padding: widget.padding,
      controller: _scrollController,
    );
//    });
  }

//  @override
//  void afterFirstLayout(BuildContext context) {
//    // Calling the same function "after layout" to resolve the issue.
////    showHelloWorld();
//    debugPrint('size:' + context.size.toString());
//    debugPrint('constraints:' + context.findRenderObject().constraints.toString());
//    context.visitChildElements((Element element) {
//      debugPrint('element $element size:' + element.size.toString());
//      debugPrint('element $element constraints:' + element.findRenderObject().constraints.toString());
//    });
////    if (widget.header != null) {
////      Row headerRow = widget.header;
////      headerRow.
////    }
//  }
  Widget defaultBuildItemsContainer(BuildContext context, Axis direction, List<Widget> children) {
    switch (direction) {
      case Axis.horizontal:
        return Row(children: children);
      case Axis.vertical:
      default:
        return Column(children: children);
    }
  }

  Widget defaultBuildDraggableFeedback(BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
        child: Card(child: ConstrainedBox(constraints: constraints, child: child)),
        elevation: 6.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

class ReorderableRow extends ReorderableFlex {
  ReorderableRow({
    Key key,
    Widget header,
    Widget footer,
    ReorderCallback onReorder,
    EdgeInsets padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    List<Widget> children = const <Widget>[],
    BuildDraggableFeedback buildDraggableFeedback
  }) : super(
    key: key,
    header: header,
    footer: footer,
    children: children,
    onReorder: onReorder,
    direction: Axis.horizontal,
    padding: padding,

    buildItemsContainer: (BuildContext context, Axis direction, List<Widget> children) {
      return Flex(
        direction: direction,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children
      );
    },
    buildDraggableFeedback: buildDraggableFeedback,
    mainAxisAlignment: mainAxisAlignment,
  );
}

class ReorderableColumn extends ReorderableFlex {
  ReorderableColumn({
    Key key,
    Widget header,
    Widget footer,
    ReorderCallback onReorder,
    EdgeInsets padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    List<Widget> children = const <Widget>[],
    BuildDraggableFeedback buildDraggableFeedback
  }) : super(
    key: key,
    header: header,
    footer: footer,
    children: children,
    onReorder: onReorder,
    direction: Axis.vertical,
    padding: padding,

    buildItemsContainer: (BuildContext context, Axis direction, List<Widget> children) {
      return Flex(
        direction: direction,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children
      );
    },
    buildDraggableFeedback: buildDraggableFeedback,
    mainAxisAlignment: mainAxisAlignment,
  );
}
