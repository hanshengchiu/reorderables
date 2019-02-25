import 'package:flutter/widgets.dart';

typedef BuildItemsContainer = Widget Function(
    BuildContext context, Axis direction, List<Widget> children);
typedef BuildDraggableFeedback = Widget Function(
    BuildContext context, BoxConstraints constraints, Widget child);
