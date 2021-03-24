import 'package:flutter/material.dart';

import 'safe_state.dart';

/// A platonic widget that both has state and calls a closure to obtain its child widget.
///
/// See also:
///
///  * [Builder], the platonic stateless widget.
class SafeStatefulBuilder extends StatefulWidget {
  /// Creates a widget that both has state and delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const SafeStatefulBuilder({
    required this.builder,
    Key? key,
  }) : super(key: key);

  /// Called to obtain the child widget.
  ///
  /// This function is called whenever this widget is included in its parent's
  /// build and the old widget (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of widgets and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  final StatefulWidgetBuilder builder;

  @override
  _SafeStatefulBuilderState createState() => _SafeStatefulBuilderState();
}

class _SafeStatefulBuilderState extends State<SafeStatefulBuilder>
    with SafeStateMixin<SafeStatefulBuilder> {
  @override
  Widget build(BuildContext context) => widget.builder(context, setState);
}
