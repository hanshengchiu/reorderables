// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

//import 'basic.dart';
//import 'debug.dart';
//import 'framework.dart';
//import 'ticker_provider.dart';

/// A place in an [Overlay] that can contain a widget.
///
/// Overlay entries are inserted into an [Overlay] using the
/// [OverlayState.insert] or [OverlayState.insertAll] functions. To find the
/// closest enclosing overlay for a given [BuildContext], use the [Overlay.of]
/// function.
///
/// An overlay entry can be in at most one overlay at a time. To remove an entry
/// from its overlay, call the [remove] function on the overlay entry.
///
/// Because an [Overlay] uses a [Stack] layout, overlay entries can use
/// [Positioned] and [AnimatedPositioned] to position themselves within the
/// overlay.
///
/// For example, [Draggable] uses an [OverlayEntry] to show the drag avatar that
/// follows the user's finger across the screen after the drag begins. Using the
/// overlay to display the drag avatar lets the avatar float over the other
/// widgets in the app. As the user's finger moves, draggable calls
/// [markNeedsBuild] on the overlay entry to cause it to rebuild. It its build,
/// the entry includes a [Positioned] with its top and left property set to
/// position the drag avatar near the user's finger. When the drag is over,
/// [Draggable] removes the entry from the overlay to remove the drag avatar
/// from view.
///
/// By default, if there is an entirely [opaque] entry over this one, then this
/// one will not be included in the widget tree (in particular, stateful widgets
/// within the overlay entry will not be instantiated). To ensure that your
/// overlay entry is still built even if it is not visible, set [maintainState]
/// to true. This is more expensive, so should be done with care. In particular,
/// if widgets in an overlay entry with [maintainState] set to true repeatedly
/// call [State.setState], the user's battery will be drained unnecessarily.
///
/// See also:
///
///  * [Overlay]
///  * [OverlayState]
///  * [WidgetsApp]
///  * [MaterialApp]
class PassthroughOverlayEntry {
  /// Creates an overlay entry.
  ///
  /// To insert the entry into an [Overlay], first find the overlay using
  /// [Overlay.of] and then call [OverlayState.insert]. To remove the entry,
  /// call [remove] on the overlay entry itself.
  PassthroughOverlayEntry({
    required this.builder,
    bool opaque = false,
    bool maintainState = false,
  })  : _opaque = opaque,
        _maintainState = maintainState;

  /// This entry will include the widget built by this builder in the overlay at
  /// the entry's position.
  ///
  /// To cause this builder to be called again, call [markNeedsBuild] on this
  /// overlay entry.
  final WidgetBuilder builder;

  /// Whether this entry occludes the entire overlay.
  ///
  /// If an entry claims to be opaque, then, for efficiency, the overlay will
  /// skip building entries below that entry unless they have [maintainState]
  /// set.
  bool get opaque => _opaque;
  bool _opaque;

  set opaque(bool value) {
    if (_opaque == value) return;
    _opaque = value;
    assert(_overlay != null);
    _overlay!._didChangeEntryOpacity();
  }

  /// Whether this entry must be included in the tree even if there is a fully
  /// [opaque] entry above it.
  ///
  /// By default, if there is an entirely [opaque] entry over this one, then this
  /// one will not be included in the widget tree (in particular, stateful widgets
  /// within the overlay entry will not be instantiated). To ensure that your
  /// overlay entry is still built even if it is not visible, set [maintainState]
  /// to true. This is more expensive, so should be done with care. In particular,
  /// if widgets in an overlay entry with [maintainState] set to true repeatedly
  /// call [State.setState], the user's battery will be drained unnecessarily.
  ///
  /// This is used by the [Navigator] and [Route] objects to ensure that routes
  /// are kept around even when in the background, so that [Future]s promised
  /// from subsequent routes will be handled properly when they complete.
  bool get maintainState => _maintainState;
  bool _maintainState;

  set maintainState(bool value) {
    if (_maintainState == value) return;
    _maintainState = value;
    assert(_overlay != null);
    _overlay!._didChangeEntryOpacity();
  }

  PassthroughOverlayState? _overlay;
  final GlobalKey<_OverlayEntryState> _key = GlobalKey<_OverlayEntryState>();

  /// Remove this entry from the overlay.
  ///
  /// This should only be called once.
  ///
  /// If this method is called while the [SchedulerBinding.schedulerPhase] is
  /// [SchedulerPhase.persistentCallbacks], i.e. during the build, layout, or
  /// paint phases (see [WidgetsBinding.drawFrame]), then the removal is
  /// delayed until the post-frame callbacks phase. Otherwise the removal is
  /// done synchronously. This means that it is safe to call during builds, but
  /// also that if you do call this during a build, the UI will not update until
  /// the next frame (i.e. many milliseconds later).
  void remove() {
    assert(_overlay != null);
    final PassthroughOverlayState overlay = _overlay!;
    _overlay = null;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
        overlay._remove(this);
      });
    } else {
      overlay._remove(this);
    }
  }

  /// Cause this entry to rebuild during the next pipeline flush.
  ///
  /// You need to call this function if the output of [builder] has changed.
  void markNeedsBuild() {
    _key.currentState?._markNeedsBuild();
  }

  @override
  String toString() =>
      '${describeIdentity(this)}(opaque: $opaque; maintainState: $maintainState)';
}

class _OverlayEntry extends StatefulWidget {
  _OverlayEntry(this.entry) : super(key: entry._key);

  final PassthroughOverlayEntry entry;

  @override
  _OverlayEntryState createState() => _OverlayEntryState();
}

class _OverlayEntryState extends State<_OverlayEntry> {
  @override
  Widget build(BuildContext context) {
    return widget.entry.builder(context);
  }

  void _markNeedsBuild() {
    setState(() {
      /* the state that changed is in the builder */
    });
  }
}

/// A [Stack] of entries that can be managed independently.
///
/// Overlays let independent child widgets "float" visual elements on top of
/// other widgets by inserting them into the overlay's [Stack]. The overlay lets
/// each of these widgets manage their participation in the overlay using
/// [OverlayEntry] objects.
///
/// Although you can create an [Overlay] directly, it's most common to use the
/// overlay created by the [Navigator] in a [WidgetsApp] or a [MaterialApp]. The
/// navigator uses its overlay to manage the visual appearance of its routes.
///
/// See also:
///
///  * [OverlayEntry].
///  * [OverlayState].
///  * [WidgetsApp].
///  * [MaterialApp].
class PassthroughOverlay extends StatefulWidget {
  /// Creates an overlay.
  ///
  /// The initial entries will be inserted into the overlay when its associated
  /// [OverlayState] is initialized.
  ///
  /// Rather than creating an overlay, consider using the overlay that is
  /// created by the [WidgetsApp] or the [MaterialApp] for the application.
  const PassthroughOverlay({
    this.initialEntries = const <PassthroughOverlayEntry>[],
    Key? key,
  }) : super(key: key);

  /// The entries to include in the overlay initially.
  ///
  /// These entries are only used when the [OverlayState] is initialized. If you
  /// are providing a new [Overlay] description for an overlay that's already in
  /// the tree, then the new entries are ignored.
  ///
  /// To add entries to an [Overlay] that is already in the tree, use
  /// [Overlay.of] to obtain the [OverlayState] (or assign a [GlobalKey] to the
  /// [Overlay] widget and obtain the [OverlayState] via
  /// [GlobalKey.currentState]), and then use [OverlayState.insert] or
  /// [OverlayState.insertAll].
  ///
  /// To remove an entry from an [Overlay], use [OverlayEntry.remove].
  final List<PassthroughOverlayEntry> initialEntries;

  /// The state from the closest instance of this class that encloses the given context.
  ///
  /// In checked mode, if the [debugRequiredFor] argument is provided then this
  /// function will assert that an overlay was found and will throw an exception
  /// if not. The exception attempts to explain that the calling [Widget] (the
  /// one given by the [debugRequiredFor] argument) needs an [Overlay] to be
  /// present to function.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// OverlayState overlay = Overlay.of(context);
  /// ```
  static PassthroughOverlayState of(BuildContext context,
      {Widget? debugRequiredFor}) {
    final PassthroughOverlayState? result =
        context.findAncestorStateOfType<PassthroughOverlayState>();
    assert(() {
      if (debugRequiredFor != null && result == null) {
        final String additional = context.widget != debugRequiredFor
            ? '\nThe context from which that widget was searching for an overlay was:\n  $context'
            : '';
        throw FlutterError('No Overlay widget found.\n'
            '${debugRequiredFor.runtimeType} widgets require an Overlay widget ancestor for correct operation.\n'
            'The most common way to add an Overlay to an application is to include a MaterialApp or Navigator widget in the runApp() call.\n'
            'The specific widget that failed to find an overlay was:\n'
            '  $debugRequiredFor'
            '$additional');
      }
      return true;
    }());
    return result!;
  }

  @override
  PassthroughOverlayState createState() => PassthroughOverlayState();
}

/// The current state of an [Overlay].
///
/// Used to insert [OverlayEntry]s into the overlay using the [insert] and
/// [insertAll] functions.
class PassthroughOverlayState extends State<PassthroughOverlay>
    with TickerProviderStateMixin {
  final List<PassthroughOverlayEntry> _entries = <PassthroughOverlayEntry>[];

  @override
  void initState() {
    super.initState();
    insertAll(widget.initialEntries);
  }

  /// Insert the given entry into the overlay.
  ///
  /// If [above] is non-null, the entry is inserted just above [above].
  /// Otherwise, the entry is inserted on top.
  void insert(PassthroughOverlayEntry entry, {PassthroughOverlayEntry? above}) {
    assert(entry._overlay == null);
    assert(
        above == null || (above._overlay == this && _entries.contains(above)));
    entry._overlay = this;
    setState(() {
      final int index =
          above == null ? _entries.length : _entries.indexOf(above) + 1;
      _entries.insert(index, entry);
    });
  }

  /// Insert all the entries in the given iterable.
  ///
  /// If [above] is non-null, the entries are inserted just above [above].
  /// Otherwise, the entries are inserted on top.
  void insertAll(Iterable<PassthroughOverlayEntry> entries,
      {PassthroughOverlayEntry? above}) {
    assert(
        above == null || (above._overlay == this && _entries.contains(above)));
    if (entries.isEmpty) return;
    for (PassthroughOverlayEntry entry in entries) {
      assert(entry._overlay == null);
      entry._overlay = this;
    }
    setState(() {
      final int index =
          above == null ? _entries.length : _entries.indexOf(above) + 1;
      _entries.insertAll(index, entries);
    });
  }

  void _remove(PassthroughOverlayEntry entry) {
    if (mounted) {
      _entries.remove(entry);
      setState(() {
        /* entry was removed */
      });
    }
  }

  /// (DEBUG ONLY) Check whether a given entry is visible (i.e., not behind an
  /// opaque entry).
  ///
  /// This is an O(N) algorithm, and should not be necessary except for debug
  /// asserts. To avoid people depending on it, this function is implemented
  /// only in checked mode.
  bool debugIsVisible(PassthroughOverlayEntry entry) {
    bool result = false;
    assert(_entries.contains(entry));
    assert(() {
      for (int i = _entries.length - 1; i > 0; i -= 1) {
        final PassthroughOverlayEntry candidate = _entries[i];
        if (candidate == entry) {
          result = true;
          break;
        }
        if (candidate.opaque) break;
      }
      return true;
    }());
    return result;
  }

  void _didChangeEntryOpacity() {
    setState(() {
      // We use the opacity of the entry in our build function, which means we
      // our state has changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    // These lists are filled backwards. For the offstage children that
    // does not matter since they aren't rendered, but for the onstage
    // children we reverse the list below before adding it to the tree.
    final List<Widget> onstageChildren = <Widget>[];
    final List<Widget> offstageChildren = <Widget>[];
    bool onstage = true;
    for (int i = _entries.length - 1; i >= 0; i -= 1) {
      final PassthroughOverlayEntry entry = _entries[i];
      if (onstage) {
        onstageChildren.add(_OverlayEntry(entry));
        if (entry.opaque) onstage = false;
      } else if (entry.maintainState) {
        offstageChildren
            .add(TickerMode(enabled: false, child: _OverlayEntry(entry)));
      }
    }
    return _Theatre(
      onstage: Stack(
        fit: StackFit.passthrough,
        //HanSheng changed it to passthrough so that this widget doesn't change layout constraints
        children: onstageChildren.reversed.toList(growable: false),
      ),
      offstage: offstageChildren,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // TODO(jacobr): use IterableProperty instead as that would
    // provide a slightly more consistent string summary of the List.
    properties.add(DiagnosticsProperty<List<PassthroughOverlayEntry>>(
        'entries', _entries));
  }
}

/// A widget that has one [onstage] child which is visible, and one or more
/// [offstage] widgets which are kept alive, and are built, but are not laid out
/// or painted.
///
/// The onstage widget must be a Stack.
///
/// For convenience, it is legal to use [Positioned] widgets around the offstage
/// widgets.
class _Theatre extends RenderObjectWidget {
  _Theatre({
    required this.offstage,
    this.onstage,
  });

  final Stack? onstage;

  final List<Widget> offstage;

  @override
  _TheatreElement createElement() => _TheatreElement(this);

  @override
  _RenderTheatre createRenderObject(BuildContext context) => _RenderTheatre();
}

class _TheatreElement extends RenderObjectElement {
  _TheatreElement(_Theatre widget)
      : assert(!debugChildrenHaveDuplicateKeys(widget, widget.offstage)),
        super(widget);

  @override
  _Theatre get widget => super.widget as _Theatre;

  @override
  _RenderTheatre get renderObject => super.renderObject as _RenderTheatre;

  Element? _onstage;
  static final Object _onstageSlot = Object();

  late List<Element> _offstage;
  final Set<Element> _forgottenOffstageChildren = HashSet<Element>();

  @override
  void insertRenderObjectChild(RenderBox child, dynamic slot) {
    assert(renderObject.debugValidateChild(child));
    if (slot == _onstageSlot) {
      assert(child is RenderStack);
      renderObject.child = child as RenderStack?;
    } else {
      assert(slot == null || slot is Element);
      renderObject.insert(child, after: slot?.renderObject);
    }
  }

  @override
  void moveRenderObjectChild(RenderBox child, dynamic oldSlot, dynamic slot) {
    if (slot == _onstageSlot) {
      renderObject.remove(child);
      assert(child is RenderStack);
      renderObject.child = child as RenderStack?;
    } else {
      assert(slot == null || slot is Element);
      if (renderObject.child == child) {
        renderObject.child = null;
        renderObject.insert(child, after: slot?.renderObject);
      } else {
        renderObject.move(child, after: slot?.renderObject);
      }
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, dynamic slot) {
    if (renderObject.child == child) {
      renderObject.child = null;
    } else {
      renderObject.remove(child);
    }
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_onstage != null) visitor(_onstage!);
    for (Element child in _offstage) {
      if (!_forgottenOffstageChildren.contains(child)) visitor(child);
    }
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    if (_onstage != null) visitor(_onstage!);
  }

  @override
  void forgetChild(Element child) {
    if (child == _onstage) {
      _onstage = null;
    } else {
      assert(_offstage.contains(child));
      assert(!_forgottenOffstageChildren.contains(child));
      _forgottenOffstageChildren.add(child);
    }
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _onstage = updateChild(_onstage, widget.onstage, _onstageSlot);
    _offstage = [];
    Element? previousChild;
    for (int i = 0; i < _offstage.length; i += 1) {
      final Element newChild = inflateWidget(widget.offstage[i], previousChild);
      _offstage[i] = newChild;
      previousChild = newChild;
    }
  }

  @override
  void update(_Theatre newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _onstage = updateChild(_onstage, widget.onstage, _onstageSlot);
    _offstage = updateChildren(_offstage, widget.offstage,
        forgottenChildren: _forgottenOffstageChildren);
    _forgottenOffstageChildren.clear();
  }
}

// A render object which lays out and paints one subtree while keeping a list
// of other subtrees alive but not laid out or painted (the "zombie" children).
//
// The subtree that is laid out and painted must be a [RenderStack].
//
// This class uses [StackParentData] objects for its parent data so that the
// children of its primary subtree's stack can be moved to this object's list
// of zombie children without changing their parent data objects.
class _RenderTheatre extends RenderBox
    with
        RenderObjectWithChildMixin<RenderStack>,
        RenderProxyBoxMixin<RenderStack>,
        ContainerRenderObjectMixin<RenderBox, StackParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! StackParentData)
      child.parentData = StackParentData();
  }

  // Because both RenderObjectWithChildMixin and ContainerRenderObjectMixin
  // define redepthChildren, visitChildren and debugDescribeChildren and don't
  // call super, we have to define them again here to make sure the work of both
  // is done.
  //
  // We chose to put ContainerRenderObjectMixin last in the inheritance chain so
  // that we can call super to hit its more complex definitions of
  // redepthChildren and visitChildren, and then duplicate the more trivial
  // definition from RenderObjectWithChildMixin inline in our version here.
  //
  // This code duplication is suboptimal.
  // TODO(ianh): Replace this with a better solution once https://github.com/dart-lang/sdk/issues/27100 is fixed
  //
  // For debugDescribeChildren we just roll our own because otherwise the line
  // drawings won't really work as well.

  @override
  void redepthChildren() {
    if (child != null) redepthChild(child!);
    super.redepthChildren();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (child != null) visitor(child!);
    super.visitChildren(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];

    if (child != null) children.add(child!.toDiagnosticsNode(name: 'onstage'));

    if (firstChild != null) {
      RenderBox child = firstChild!;

      int count = 1;
      while (true) {
        children.add(
          child.toDiagnosticsNode(
            name: 'offstage $count',
            style: DiagnosticsTreeStyle.offstage,
          ),
        );
        if (child == lastChild) break;
        final StackParentData childParentData =
            child.parentData! as StackParentData;
        child = childParentData.nextSibling!;
        count += 1;
      }
    } else {
      children.add(
        DiagnosticsNode.message(
          'no offstage children',
          style: DiagnosticsTreeStyle.offstage,
        ),
      );
    }
    return children;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null) visitor(child!);
  }
}
