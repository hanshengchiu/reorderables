import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class ColumnExample1 extends StatefulWidget {
  @override
  _ColumnExample1State createState() => _ColumnExample1State();
}

class _ColumnExample1State extends State<ColumnExample1> {
  late List<Widget> _rows;

  @override
  void initState() {
    super.initState();

    _rows = List<ReorderableWidget>.generate(
        10,
        (int index) => ReorderableWidget(
              reorderable: true,
              key: ValueKey(index),
              child: Container(
                  width: double.infinity,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('This is row $index', textScaleFactor: 1.5))),
            ));

    _rows += <ReorderableWidget>[
      ReorderableWidget(
        reorderable: false,
        key: ValueKey(10),
        child: Text('This row is not reorderable', textScaleFactor: 2),
      )
    ];

    _rows += List<ReorderableWidget>.generate(
        40,
        (int index) => ReorderableWidget(
              reorderable: true,
              key: ValueKey(11 + index),
              child: Container(
                width: double.infinity,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('This is row $index', textScaleFactor: 1.5)),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = _rows.removeAt(oldIndex);
        _rows.insert(newIndex, row);
      });
    }

    return ReorderableColumn(
      header: Text('THIS IS THE HEADER ROW'),
      footer: Text('THIS IS THE FOOTER ROW'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _rows,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        //this callback is optional
        debugPrint(
            '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
      },
    );
  }
}
