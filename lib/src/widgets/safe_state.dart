import 'package:flutter/widgets.dart';

mixin SafeStateMixin<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    //can't call setState() if the stateful widget is not mounted, i.e. removed from the tree.
    if (this.mounted) {
      super.setState(fn);
    }
  }
}
