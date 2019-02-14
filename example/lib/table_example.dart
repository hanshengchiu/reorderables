import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class TableExample extends StatefulWidget {
  @override
  _TableExampleState createState() => _TableExampleState();
}

class _TableExampleState extends State<TableExample> {
  List<ReorderableTableRow> _itemRows;

  @override
  void initState() {
    super.initState();
    var data = [
      [0, '0.1', '0.2', '0.3'],
      [1, '101', '', '103'],
      [2, '', '200002', ''],
      [3, '0.31', '', '0.33'],
    ];

    _itemRows = data.map((row) {
      return ReorderableTableRow(
        //a key must be specified for each row
        key: ObjectKey(row),
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('${row[0]}'),
          Text('${row[1]}'),
          Text('${row[2]}'),
          Text('${row[3]}'),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var headerRow = ReorderableTableRow(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text('Index'), Text('Col 1'), Text('Col 2'), Text('Col 3'), Text('Col 4')
      ]
    );

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        ReorderableTableRow row = _itemRows.removeAt(oldIndex);
        _itemRows.insert(newIndex, row);
      });
    }

    return ReorderableTable(
      header: headerRow,
//      footer: toolBar,//toolBarRow,
      children: _itemRows,
      onReorder: _onReorder,
    );
  }
}
