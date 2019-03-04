import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class SliverExample extends StatefulWidget {
  @override
  _SliverExampleState createState() => _SliverExampleState();
}

class _SliverExampleState extends State<SliverExample> {
  List<Widget> _rows;

  @override
  void initState() {
    super.initState();
    _rows = List<Widget>.generate(50,
        (int index) => Text('This is sliver child $index', key: ValueKey(index), textScaleFactor: 2)
    );
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = _rows.removeAt(oldIndex);
        _rows.insert(newIndex, row);
      });
    }
    ScrollController _scrollController = PrimaryScrollController.of(context) ?? ScrollController();

    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 150.0,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text('ReorderableSliverList'),
            background: Icon(Icons.filter),
          ),
        ),
        ReorderableSliverList(
          delegate: ReorderableSliverChildListDelegate(_rows),
//          delegate: ReorderableSliverChildBuilderDelegate(
//            (BuildContext context, int index) => _rows[index],
//            childCount: _rows.length
//          ),
          onReorder: _onReorder,
        )
      ],
    );

  }
}
