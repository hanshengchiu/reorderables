# reorderables

[![pub package](https://img.shields.io/pub/v/reorderables.svg)](https://pub.dartlang.org/packages/reorderables)
[![Donate](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/q5gkeA4t2)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2L56VGH228QJE)

Various reorderable Flutter widgets, including reorderable table, row, column, and wrap, that handle
dragging and dropping the children within the widget. Parent widget only need to provide a function
that is invoked with the old and new indexes of child being reordered.

## Usage
To use this package, add `reorderables` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
```
dependencies:
  reorderables:
```
And import the package in your code.
``` dart
import 'package:reorderables/reorderables.dart';
```
## Examples

This package includes ReorderableTable, ReorderableWrap, ReorderableRow, and ReorderableColumn, 
which are reorderable versions of Flutter's Table, Wrap, Row, and Column respectively.

##### Reorderable Table

``` dart
class _TableExampleState extends State<TableExample> {
  List<ReorderableTableRow> _itemRows;

  @override
  void initState() {
    super.initState();
    var data = [
      ['Alex', 'D', 'B+', 'AA', ''],
      ['Bob', 'AAAAA+', '', 'B', ''],
      ['Cindy', '', 'To Be Confirmed', '', ''],
      ['Duke', 'C-', '', 'Failed', ''],
      ['Ellenina', 'C', 'B', 'A', 'A'],
      ['Floral', '', 'BBB', 'A', 'A'],
    ];

    Widget _textWithPadding(String text) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(text, textScaleFactor: 1.1),
      );
    }

    _itemRows = data.map((row) {
      return ReorderableTableRow(
        //a key must be specified for each row
        key: ObjectKey(row),
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _textWithPadding('${row[0]}'),
          _textWithPadding('${row[1]}'),
          _textWithPadding('${row[2]}'),
          _textWithPadding('${row[3]}'),
//          Text('${row[4]}'),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var headerRow = ReorderableTableRow(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Name', textScaleFactor: 1.5),
        Text('Math', textScaleFactor: 1.5),
        Text('Science', textScaleFactor: 1.5),
        Text('Physics', textScaleFactor: 1.5),
        Text('Sports', textScaleFactor: 1.5)
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
      children: _itemRows,
      onReorder: _onReorder,
    );
  }
}
```

In a table, cells in each row are aligned on column basis with cells in other rows, 
whereas cells in a row of a list view don't align with  other rows.

##### Reorderable Table Demo

<img src="https://github.com/hanshengchiu/reorderables/blob/master/example/gifs/reorderable_table.gif?raw=true" width="540" height="960" title="ReorderableTable">

## Support

If my work has helped you, you can support me by buying me a coffee or donate me via PayPal.
Your support is very much appreciated. :)

[![Donate](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/q5gkeA4t2) 
 or 
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2L56VGH228QJE)
