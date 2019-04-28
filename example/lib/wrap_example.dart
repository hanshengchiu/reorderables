import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class WrapExample extends StatefulWidget {
  @override
  _WrapExampleState createState() => _WrapExampleState();
}

class _WrapExampleState extends State<WrapExample> {
  final double _iconSize = 90;
  List<Widget> _tiles;

  @override
  void initState() {
    super.initState();
    _tiles = <Widget>[
      Icon(Icons.filter_1, key: ValueKey(1), size: _iconSize),
      Icon(Icons.filter_2, key: ValueKey(2), size: _iconSize),
      Icon(Icons.filter_3, key: ValueKey(3), size: _iconSize),
      Icon(Icons.filter_4, key: ValueKey(4), size: _iconSize),
      Icon(Icons.filter_5, key: ValueKey(5), size: _iconSize),
      Icon(Icons.filter_6, key: ValueKey(6), size: _iconSize),
      Icon(Icons.filter_7, key: ValueKey(7), size: _iconSize),
      Icon(Icons.filter_8, key: ValueKey(8), size: _iconSize),
      Icon(Icons.filter_9, key: ValueKey(9), size: _iconSize),
    ];
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = _tiles.removeAt(oldIndex);
        _tiles.insert(newIndex, row);
      });
    }

    var wrap = ReorderableWrap(
      spacing: 8.0,
      runSpacing: 4.0,
      padding: const EdgeInsets.all(8),
      children: _tiles,
      onReorder: _onReorder
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        wrap,
        ButtonBar(
          alignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle),
              color: Colors.deepOrange,
              onPressed: () {
                var newTile = Icon(Icons.filter_9_plus, key: ValueKey(_tiles.length+1), size: _iconSize);
                setState(() {
                  _tiles.add(newTile);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.remove_circle),
              color: Colors.teal,
              onPressed: () {
                setState(() {
                  _tiles.removeAt(0);
                });
              },
            ),
          ],
        ),
      ],
    );

  }
}
