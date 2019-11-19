import 'package:flutter/widgets.dart';

class ReorderableWidget extends StatelessWidget implements ReorderableItem {
  final Widget child;
  final bool reorderable;

  ReorderableWidget(
      {@required this.child, @required this.reorderable, @required Key key})
      : assert(reorderable != null && reorderable is bool),
        assert(key != null, 'A key is mandatory for each Widget'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

abstract class ReorderableItem extends Widget {
  final bool reorderable;

  ReorderableItem({@required this.reorderable});
}
