// Copyright 2019 Hansheng Chiu <https://www.linkedin.com/in/hschiu/>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:reorderables/reorderables.dart';

import './basic.dart';
import './typedefs.dart';
import './reorderable_mixin.dart';

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

mixin _ReorderableSliverChildDelegateMixin<T extends SliverChildDelegate> {
  Widget Function(Widget toWrap, int index) _wrap;

  set wrap(Function value) {
    _wrap = value;
  }
}

/// Reorderable (drag and drop) version of [SliverChildBuilderDelegate], a
/// delegate that supplies children for slivers using a builder callback.
///
/// The widget works exactly like [SliverChildBuilderDelegate]. When using
/// [ReorderableSliverList], replace [SliverChildBuilderDelegate] with this
/// class.
///
/// See also:
///
///  * [SliverChildBuilderDelegate], for how to use SliverChildBuilderDelegate.
///  * [ReorderableSliverChildListDelegate], which is a delegate that supplies
///    children for slivers using an explicit list.
class ReorderableSliverChildBuilderDelegate extends SliverChildBuilderDelegate
    with _ReorderableSliverChildDelegateMixin {
  /// Creates a delegate that supplies children for slivers using the given
  /// builder callback.
  ///
  /// The [builder], [addAutomaticKeepAlives], [addRepaintBoundaries],
  /// [addSemanticIndexes], and [semanticIndexCallback] arguments must not be
  /// null.
  ReorderableSliverChildBuilderDelegate(
    IndexedWidgetBuilder builder, {
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback semanticIndexCallback =
        _kDefaultSemanticIndexCallback,
    int semanticIndexOffset = 0,
  }) : super(
          builder,
          childCount: childCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback,
          semanticIndexOffset: semanticIndexOffset,
        );

  @override
  bool shouldRebuild(
          covariant ReorderableSliverChildBuilderDelegate oldDelegate) =>
      true;

  // Return an ErrorWidget for the given Exception
//  ErrorWidget _createErrorWidget(dynamic exception, StackTrace stackTrace) {
//    final FlutterErrorDetails details = FlutterErrorDetails(
//      exception: exception,
//      stack: stackTrace,
//      library: 'reorderables widgets library',
//      context: DiagnosticsNode.message('building'),
//      informationCollector: null,
//    );
//    FlutterError.reportError(details);
//    return ErrorWidget.builder(details);
//  }

  @override
  Widget build(BuildContext context, int index) {
//    Widget child = super.build(context, index);
    assert(builder != null);
    if (index < 0 || (childCount != null && index >= childCount)) return null;
    Widget child = builder(context, index);
//    try {
//      child = builder(context, index);
//    } catch (exception, stackTrace) {
//      child = _createErrorWidget(exception, stackTrace);
//    }
    if (child == null) return null;
    if (addRepaintBoundaries) child = RepaintBoundary.wrap(child, index);
    if (addSemanticIndexes) {
      final int semanticIndex = semanticIndexCallback(child, index);
      if (semanticIndex != null)
        child = IndexedSemantics(
            index: semanticIndex + semanticIndexOffset, child: child);
    }
//    if (addAutomaticKeepAlives)
//      child = AutomaticKeepAlive(child: child);

//    child = KeyedSubtree(
//      key: ObjectKey(child),
//      child: child
//    );

    child = _wrap(child, index);
    if (addAutomaticKeepAlives) child = AutomaticKeepAlive(child: child);

    return child;
  }
}

/// Reorderable (drag and drop) version of [SliverChildListDelegate], a
/// delegate supplies children for slivers using an explicit list.
///
/// The widget works exactly like [SliverChildListDelegate]. When using
/// [ReorderableSliverList], replace [SliverChildListDelegate] with this class.
///
/// See also:
///
///  * [SliverChildListDelegate], for how to use SliverChildListDelegate.
///  * [ReorderableSliverChildBuilderDelegate], which is a delegate that uses a
///    builder callback to construct the reorderable children.
class ReorderableSliverChildListDelegate extends SliverChildListDelegate
    with _ReorderableSliverChildDelegateMixin {
  /// Creates a delegate that supplies children for slivers using the given
  /// list.
  ///
  /// The [children], [addAutomaticKeepAlives], [addRepaintBoundaries],
  /// [addSemanticIndexes], and [semanticIndexCallback] arguments must not be
  /// null.
  ReorderableSliverChildListDelegate(
    List<Widget> children, {
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback semanticIndexCallback =
        _kDefaultSemanticIndexCallback,
    int semanticIndexOffset = 0,
  }) : super(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback,
          semanticIndexOffset: semanticIndexOffset,
        );

  @override
  bool shouldRebuild(
          covariant ReorderableSliverChildListDelegate oldDelegate) =>
      true;

  @override
  Widget build(BuildContext context, int index) {
//    Widget child = super.build(context, index);
    assert(children != null);
    if (index < 0 || index >= children.length) return null;
    Widget child = children[index];
//    debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(97) $this.build: index:$index child:$child');
    assert(child != null);
    if (addRepaintBoundaries) child = RepaintBoundary.wrap(child, index);
    if (addSemanticIndexes) {
      final int semanticIndex = semanticIndexCallback(child, index);
      if (semanticIndex != null)
        child = IndexedSemantics(
            index: semanticIndex + semanticIndexOffset, child: child);
    }
//    if (addAutomaticKeepAlives)
//      child = AutomaticKeepAlive(child: child);
//    return child;

//    child = KeyedSubtree(
//      key: ObjectKey(child),
//      child: child
//    );

    child = _wrap(child, index);
    if (addAutomaticKeepAlives) child = AutomaticKeepAlive(child: child);

    return child;
  }
}

/// Reorderable (drag and drop) version of [SliverList], a widget that places
/// multiple box draggable children in a linear array along the main axis.
///
/// A ScrollController must be explicitly provided to CustomScrollView when
/// wrapping the widget with a CustomScrollView.
///
/// {@tool sample}
///
/// This sample shows how to create a reorderable sliver list with a sliver app
/// bar.
///
/// ```dart
/// CustomScrollView(
///  // a ScrollController must be included in CustomScrollView, otherwise
///  // ReorderableSliverList won't work
///  controller: _scrollController,
///  slivers: <Widget>[
///    SliverAppBar(
///      expandedHeight: 210.0,
///      flexibleSpace: FlexibleSpaceBar(
///        title: Text('ReorderableSliverList'),
///        background: Image.network(
///          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Yushan'
///            '_main_east_peak%2BHuang_Chung_Yu%E9%BB%83%E4%B8%AD%E4%BD%91%2B'
///            '9030.png/640px-Yushan_main_east_peak%2BHuang_Chung_Yu%E9%BB%83'
///            '%E4%B8%AD%E4%BD%91%2B9030.png'),
///      ),
///    ),
///    ReorderableSliverList(
///      delegate: ReorderableSliverChildListDelegate(_rows),
///      // or use ReorderableSliverChildBuilderDelegate if needed
///      //delegate: ReorderableSliverChildBuilderDelegate(
///      //  (BuildContext context, int index) => _rows[index],
///      //  childCount: _rows.length
///      //),
///      onReorder: _onReorder,
///    )
///  ],
///)
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [SliverList], for how to use SliverList.
///  * [ReorderableSliverChildBuilderDelegate], for the reorderable version of
///    [SliverChildBuilderDelegate].
///  * [ReorderableSliverChildListDelegate], for the reorderable version of
///    [SliverChildListDelegate].
class ReorderableSliverList extends StatefulWidget {
  /// Creates a reorderable list.
  ReorderableSliverList({
    Key key,
    @required this.delegate,
    @required this.onReorder,
    this.buildItemsContainer,
    this.buildDraggableFeedback,
    this.onNoReorder,
    this.onReorderStarted,
    this.enabled = true,
  }): assert(onReorder != null && delegate != null),
      super(key: key);
  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this widget to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [ReorderableSliverChildBuilderDelegate] and [ReorderableSliverChildListDelegate],
  ///    which are commonly used subclasses of [SliverChildDelegate] that use a
  ///    builder callback and an explicit child list, respectively.
  final SliverChildDelegate delegate;

  /// Called when a child is dropped into a new position to shuffle the
  /// children.
  final ReorderCallback onReorder;
  final NoReorderCallback onNoReorder;

  /// Called when the draggable starts being dragged.
  final ReorderStartedCallback onReorderStarted;

  final BuildItemsContainer buildItemsContainer;
  final BuildDraggableFeedback buildDraggableFeedback;

  /// Sets whether the children are reorderable or not
  final bool enabled;

  @override
  _ReorderableSliverListState createState() => _ReorderableSliverListState();
}

class _ReorderableSliverListState extends State<ReorderableSliverList>
  with TickerProviderStateMixin<ReorderableSliverList>, ReorderableMixin
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
  ScrollPosition _attachedScrollPosition;

  // This controls the entrance of the dragging widget into a new place.
  AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  AnimationController _ghostController;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
//  Key _dragging;
  Widget _draggingWidget;

  // The last computed size of the feedback widget being dragged.
  Size _draggingFeedbackSize;

//  BuildContext _draggingContext;

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

//  final GlobalKey _contentKey = GlobalKey(debugLabel: '$ReorderableSliverList content key');

  int _childCount;

  final Map<int, StateSetter> _setStateMap = <int, StateSetter>{};
  final List<int> _spacedIndexes = <int>[];

  Size get _dropAreaSize {
    if (_draggingFeedbackSize == null) {
      return Size(0, 0);
    }
    return _draggingFeedbackSize + Offset(_dropAreaMargin, _dropAreaMargin);
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
        value: 1.0, vsync: this, duration: _reorderAnimationDuration);
    _ghostController = AnimationController(
        value: 0, vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);

//    if (widget.delegate is ReorderableSliverChildBuilderDelegate) {
//      _childCount = (widget.delegate as ReorderableSliverChildBuilderDelegate).childCount;
//    } else if (widget.delegate is ReorderableSliverChildListDelegate) {
//      _childCount = (widget.delegate as ReorderableSliverChildListDelegate).children.length;
//    }
  }

  @override
  void didChangeDependencies() {
    if (_scrollController != null && _attachedScrollPosition != null) {
      _scrollController.detach(_attachedScrollPosition);
      _attachedScrollPosition = null;
    }

    _scrollController =
        PrimaryScrollController.of(context) ?? ScrollController();

    if (!_scrollController.hasClients) {
      ScrollableState scrollableState = Scrollable.of(context);
      _attachedScrollPosition = scrollableState?.position;
    } else {
      _attachedScrollPosition = null;
    }

    if (_attachedScrollPosition != null) {
      _scrollController.attach(_attachedScrollPosition);
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_scrollController != null && _attachedScrollPosition != null) {
      _scrollController.detach(_attachedScrollPosition);
      _attachedScrollPosition = null;
    }
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  int _shiftIndex(int index, int currentIndex, int ghostIndex) {
    int shiftedIndex = index;
    if (currentIndex != ghostIndex) {
      if (index == _dragStartIndex) {
        shiftedIndex = ghostIndex;
      } else if (index > _dragStartIndex && index <= ghostIndex) {
        shiftedIndex--;
      } else if (index < _dragStartIndex && index >= ghostIndex) {
        shiftedIndex++;
      }
    }
    return shiftedIndex;
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex(
      {bool isAcceptingNewTarget = false, int updatingIndex}) {
//    debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(345) $this._requestAnimationToNextIndex: '
//      '_dragStartIndex:$_dragStartIndex _ghostIndex:$_ghostIndex _currentIndex:$_currentIndex _nextIndex:$_nextIndex isAcceptingNewTarget:$isAcceptingNewTarget isCompleted:${_entranceController.isCompleted}');

    if (_entranceController.isCompleted) {
      void _update() {
        _ghostIndex = _currentIndex;
        if (!isAcceptingNewTarget && _nextIndex == _currentIndex) {
          // && _dragStartIndex == _ghostIndex
          return;
        }

        _currentIndex = _nextIndex;
        _ghostController.reverse(from: 1.0);
        _entranceController.forward(from: 0.0);
      }

      Set<int> updateIndexSet = Set<int>();
      while (_spacedIndexes.isNotEmpty) {
        updateIndexSet.add(_spacedIndexes.removeLast());
      }

      if (_nextIndex != -1) {
        int index = _nextIndex;
        int shiftedIndex = _shiftIndex(index, _nextIndex, _currentIndex);
        if (shiftedIndex != _nextIndex) {
          index = (_nextIndex + 1) % _setStateMap.length;
          shiftedIndex = _shiftIndex(index, _nextIndex, _currentIndex);
          if (shiftedIndex != _nextIndex) {
            index =
                (_nextIndex - 1 + _setStateMap.length) % _setStateMap.length;
            shiftedIndex = _shiftIndex(index, _nextIndex, _currentIndex);
            assert(shiftedIndex == _nextIndex);
          }
        }

        updateIndexSet.add(index);
      }
      if (_currentIndex != -1) {
        updateIndexSet.add(_currentIndex);
      }

      var updateIndexes = updateIndexSet.toList();

      void _setState() {
        if (updateIndexes.length > 0) {
          int index = updateIndexes.removeLast();
          if (_setStateMap[index] == null) {
//            debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(394) $this._setState: index:$index _setStateMap:$_setStateMap');
          }
          _setStateMap[index](_setState);
        } else {
          _update();
        }
      }

      _setState();
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
    final RenderObject contextObject = context.findRenderObject();
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(contextObject);
    assert(viewport != null);

//    if (_scrollController.positions.isEmpty) {
//      debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(537) $this._scrollTo: empty pos');
//      ScrollableState scrollableState = Scrollable.of(context);
//      _scrollController.attach(scrollableState.position);
////      _scrollController.createScrollPosition(physics, scrollableState.position, oldPosition)
//    }

    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
//    final double margin = widget.direction == Axis.horizontal ? _dropAreaSize.width : _dropAreaSize.height;
    final double margin = _dropAreaSize.height / 2;

    assert(
        _scrollController.hasClients,
        'An attached scroll controller is needed. '
        'You probably forgot to attach one to the parent scroll view that contains this reorderable list.');

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
//    debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(520) $this._scrollTo: scrollOffset:$scrollOffset topOffset:$topOffset bottomOffset:$bottomOffset onScreen:$onScreen');
    // If the context is off screen, then we request a scroll to make it visible.
    if (!onScreen) {
      _scrolling = true;
      _scrollController.position
          .animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
//        _scrollController.position.maxScrollExtent,
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
  Widget _buildContainerForMainAxis({List<Widget> children}) {
    var column = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children);
    return column;
//    return SingleChildScrollView(
//      child:column,
//      primary: false,
//    );

//    return Column(mainAxisSize: MainAxisSize.min, children: children, mainAxisAlignment: widget.mainAxisAlignment);
  }

  Widget _wrap(Widget toWrap, int index) {
    return SafeStatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      _setStateMap[index] = setState;
      return _statefulWrap(toWrap, index, setState);
    });
  }

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _statefulWrap(Widget toWrap, int index, StateSetter setState) {
//    assert(toWrap.key != null);
//    final GlobalObjectKey keyIndexGlobalKey = GlobalObjectKey(toWrap.key);
    BuildContext draggableContext;
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.

    // Starts dragging toWrap.
    void onDragStarted() {
//      debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(419) $this.onDragStarted: index:$index');
      setState(() {
        _draggingWidget = toWrap;
//        _dragging = toWrap.key;
        _dragStartIndex = index;
        _ghostIndex = index;
        _currentIndex = index;
        _entranceController.value = 1.0;
        _draggingFeedbackSize =
            draggableContext.size; //keyIndexGlobalKey.currentContext.size;
//        _draggingContext = draggableContext;
      });
      if (widget.onReorderStarted != null) {
        widget.onReorderStarted(index);
      }
    }

    // Places the value from startIndex one space before the element at endIndex.
    void _reorder(int startIndex, int endIndex) {
//      debugPrint('startIndex:$startIndex endIndex:$endIndex');
      if (startIndex != endIndex)
        widget.onReorder(startIndex, endIndex);
      else if (widget.onNoReorder != null) widget.onNoReorder(startIndex);
      // Animates leftover space in the drop area closed.
      // TODO(djshuckerow): bring the animation in line with the Material
      // specifications.
      _ghostController.reverse(from: 0.1);
      _entranceController.reverse(from: 0);

//      _dragging = null;
      _dragStartIndex = -1;
//      _draggingContext = null;
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
      this.setState(() {
        void _update() {
          _reorder(_dragStartIndex, _currentIndex);
          _dragStartIndex = -1;
          _ghostIndex = -1;
          _currentIndex = -1;
          _draggingWidget = null;
        }

        Set<int> updateIndexSet = Set<int>();
        while (_spacedIndexes.isNotEmpty) {
          updateIndexSet.add(_spacedIndexes.removeLast());
        }
        var updateIndexes = updateIndexSet.toList();

        void _setState() {
          if (updateIndexes.length > 0) {
            int index = updateIndexes.removeLast();
            _setStateMap[index](_setState);
          } else {
            _update();
          }
        }

        _setState();
      });
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
          <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, _childCount - 1);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final MaterialLocalizations localizations =
          MaterialLocalizations.of(context);

      if (localizations != null) {
        // If the item can move to before its current position in the list.
        if (index > 0) {
          semanticsActions[CustomSemanticsAction(
              label: localizations.reorderItemToStart)] = moveToStart;
          String reorderItemBefore = localizations.reorderItemUp;
//        if (widget.direction == Axis.horizontal) {
//          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
//            ? localizations.reorderItemLeft
//            : localizations.reorderItemRight;
//        }
          semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
              moveBefore;
        }

        // If the item can move to after its current position in the list.
        if (index < _childCount - 1) {
          String reorderItemAfter = localizations.reorderItemDown;
//        if (widget.direction == Axis.horizontal) {
//          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
//            ? localizations.reorderItemRight
//            : localizations.reorderItemLeft;
//        }
          semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
              moveAfter;
          semanticsActions[CustomSemanticsAction(
              label: localizations.reorderItemToEnd)] = moveToEnd;
        }
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
      return makeAppearingWidget(child, _entranceController, _draggingFeedbackSize, Axis.vertical,);
    }

    Widget _makeDisappearingWidget(Widget child) {
      return makeDisappearingWidget(child, _ghostController, _draggingFeedbackSize, Axis.vertical,);
    }

    Widget buildDragTarget(BuildContext context, List<int> acceptedCandidates,
        List<dynamic> rejectedCandidates) {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      Widget feedbackBuilder = Builder(builder: (BuildContext context) {
//          RenderRepaintBoundary renderObject = _contentKey.currentContext.findRenderObject();
//          BoxConstraints contentSizeConstraints = BoxConstraints.loose(renderObject.size);
        BoxConstraints contentSizeConstraints = BoxConstraints.loose(
            _draggingFeedbackSize); //renderObject.constraints
//          debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_flex.dart(515) $this.buildDragTarget: contentConstraints:$contentSizeConstraints _draggingFeedbackSize:$_draggingFeedbackSize');
        return (widget.buildDraggableFeedback ?? defaultBuildDraggableFeedback)(
            context, contentSizeConstraints, toWrap);
      });

      bool isReorderable = true;
      if (toWrap is ReorderableWidget) {
        isReorderable = toWrap.reorderable;
      }

      Widget child;
      if (!isReorderable) {
        child = toWrapWithSemantics;
      } else {
        // We build the draggable inside of a layout builder so that we can
        // constrain the size of the feedback dragging widget.
        child = LongPressDraggable<int>(
          maxSimultaneousDrags: widget.enabled?1:0,
          axis: Axis.vertical,
          //widget.direction,
          data: index,
          //toWrap.key,
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
          child: MetaData(
              child: toWrapWithSemantics, behavior: HitTestBehavior.opaque),
          //toWrapWithSemantics,//_dragging == toWrap.key ? const SizedBox() : toWrapWithSemantics,
          childWhenDragging: IgnorePointer(
            ignoring: true,
            child: SizedBox(
              // Small values (<50) cause an error when used with ListTile.
              width: double.infinity,
              child: Opacity(
                  opacity: 0,
//              child: _makeAppearingWidget(toWrap)
                  child: Container(width: 0, height: 0, child: toWrap)
              )
            )
          ),
          //ConstrainedBox(constraints: contentConstraints),//SizedBox(),
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
      }

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= _childCount) {
        child = toWrap;
      }

      var containedDraggable = Builder(builder: (BuildContext context) {
        draggableContext = context;
        return child;
      });
      return containedDraggable;
//      return Listener(
//        onPointerMove: (PointerMoveEvent event) {
//          final RenderBox box = _draggingContext.findRenderObject();
//          final Offset localOffset = box.globalToLocal(event.position);
//          debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(796) ${this.toStringShort()}.buildDragTarget: e:${event.position} localOffset:$localOffset');
//        },
//        child: containedDraggable,
//      );
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    return Builder(builder: (BuildContext context) {
      Widget dragTarget = DragTarget<int>(
        builder: buildDragTarget,
        onWillAccept: (int toAccept) {
          bool willAccept = _dragStartIndex == toAccept && toAccept != index;
//          debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_sliver.dart(679) $this._statefulWrap: '
//            'onWillAccept: toAccept:$toAccept return:$willAccept _nextIndex:$_nextIndex index:$index _currentIndex:$_currentIndex _dragStartIndex:$_dragStartIndex');

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

            _requestAnimationToNextIndex(
                isAcceptingNewTarget: true, updatingIndex: index);
          });
          if (willAccept) {
            _scrollTo(context);
          }
          // If the target is not the original starting point, then we will accept the drop.
          return willAccept; //_dragging == toAccept && toAccept != toWrap.key;
        },
        onAccept: (int accepted) {},
        onLeave: (Object leaving) {},
      );

//      dragTarget = KeyedSubtree(
//        key: keyIndexGlobalKey,
//        child: dragTarget
//      );
      dragTarget = KeyedSubtree(key: ValueKey(index), child: dragTarget);

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = _draggingWidget == null
          ? SizedBox.fromSize(size: _dropAreaSize)
          : Opacity(opacity: 0.2, child: _draggingWidget);
//      Widget spacing = SizedBox.fromSize(
//        size: _dropAreaSize,
//        child: _draggingWidget != null ? Opacity(opacity: 0.2, child: _draggingWidget) : null,
//      );
      // We open up a space under where the dragging widget currently is to
      // show it can be dropped.
      int shiftedIndex = _shiftIndex(index, _currentIndex, _ghostIndex);

      if (shiftedIndex == _currentIndex || index == _ghostIndex) {
        Widget entranceSpacing = _makeAppearingWidget(spacing);
        Widget ghostSpacing = _makeDisappearingWidget(spacing);

        if (_dragStartIndex == -1) {
          return _buildContainerForMainAxis(children: [dragTarget]);
        } else if (_currentIndex > _ghostIndex) {
          //the ghost is moving down, i.e. the tile below the ghost is moving up
//          debugPrint('index:$index item moving up / ghost moving down');
          _spacedIndexes.insert(0, index);
          if (shiftedIndex == _currentIndex && index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: [ghostSpacing, dragTarget, entranceSpacing]);
          } else if (shiftedIndex == _currentIndex) {
            return _buildContainerForMainAxis(
                children: [dragTarget, entranceSpacing]);
          } else if (index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: shiftedIndex <= index
                    ? [dragTarget, ghostSpacing]
                    : [ghostSpacing, dragTarget]);
          }
        } else if (_currentIndex < _ghostIndex) {
          //the ghost is moving up, i.e. the tile above the ghost is moving down
//          debugPrint('index:$index item moving down / ghost moving up');
          _spacedIndexes.insert(0, index);
          if (shiftedIndex == _currentIndex && index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: [entranceSpacing, dragTarget, ghostSpacing]);
          } else if (shiftedIndex == _currentIndex) {
            return _buildContainerForMainAxis(
                children: [entranceSpacing, dragTarget]);
          } else if (index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: shiftedIndex >= index
                    ? [ghostSpacing, dragTarget]
                    : [dragTarget, ghostSpacing]);
          }
        } else {
//          debugPrint('index:$index using _entranceController: spacing on top:${!(_dragStartIndex < _currentIndex)}');
          _spacedIndexes.insert(0, index);
          return _buildContainerForMainAxis(
              children: _dragStartIndex < _currentIndex
                  ? [dragTarget, entranceSpacing]
                  : [entranceSpacing, dragTarget]);
        }
      }

      //we still wrap dragTarget with a container so that widget's depths are the same and it prevent's layout alignment issue
      return _buildContainerForMainAxis(children: [dragTarget]);
    });
  }

  @override
  Widget build(BuildContext context) {
//    assert(debugCheckHasMaterialLocalizations(context));
    assert(widget.delegate is _ReorderableSliverChildDelegateMixin);

    if (widget.delegate is ReorderableSliverChildBuilderDelegate) {
      _childCount =
          (widget.delegate as ReorderableSliverChildBuilderDelegate).childCount;
    } else if (widget.delegate is ReorderableSliverChildListDelegate) {
      _childCount = (widget.delegate as ReorderableSliverChildListDelegate)
          .children
          .length;
    }

    _ReorderableSliverChildDelegateMixin reorderableDelegate =
        widget.delegate as _ReorderableSliverChildDelegateMixin;
    reorderableDelegate.wrap = _wrap;

//    return CustomScrollView(
//      controller: _scrollController,
//      slivers: <Widget>[
//        SliverList(
//          delegate: widget.delegate
//        )
//      ],
//    );

    return SliverList(delegate: widget.delegate);
//    return SliverFixedExtentList(
//      delegate: widget.delegate,
//      itemExtent: 33
//    );
  }

//  Widget defaultBuildItemsContainer(BuildContext context, Axis direction, List<Widget> children) {
//    switch (direction) {
//      case Axis.horizontal:
//        return Row(children: children);
//      case Axis.vertical:
//      default:
//        return Column(children: children);
//    }
//  }

  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: Matrix4.rotationZ(0),
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
