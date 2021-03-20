import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class NestedWrapExample extends StatefulWidget {
  NestedWrapExample({
    Key? key,
    this.depth = 0,
    this.valuePrefix = '',
    this.color,
  }) : super(key: key);
  final int depth;
  final String valuePrefix;
  final Color? color;
  final List<Widget> _tiles = [];

  @override
  State createState() => _NestedWrapExampleState();
}

class _NestedWrapExampleState extends State<NestedWrapExample> {
//  List<Widget> _tiles;
  Color? _color;
  Color? _colorBrighter;

  @override
  void initState() {
    super.initState();
    _color = widget.color ?? Colors.primaries[widget.depth % Colors.primaries.length];
    _colorBrighter = Color.lerp(_color, Colors.white, 0.6);
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        widget._tiles.insert(newIndex, widget._tiles.removeAt(oldIndex));
      });
    }

    var wrap = ReorderableWrap(
      spacing: 8.0,
      runSpacing: 4.0,
      padding: const EdgeInsets.all(8),
      children: widget._tiles,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        //this callback is optional
        debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
      },
    );

    var buttonBar = Container(
      color: _colorBrighter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            iconSize: 42,
            icon: Icon(Icons.add_circle),
            color: Colors.deepOrange,
            padding: const EdgeInsets.all(0.0),
            onPressed: () {
              setState(() {
                widget._tiles.add(
                  Card(
                    child: Container(
                      child: Text('${widget.valuePrefix}${widget._tiles.length}', textScaleFactor: 3 / math.sqrt(widget.depth + 1)),
                      padding: EdgeInsets.all((24.0 / math.sqrt(widget.depth + 1)).roundToDouble()),
                    ),
                    color: _colorBrighter,
                    elevation: 3,
                  )
                );
              });
            },
          ),
          IconButton(
            iconSize: 42,
            icon: Icon(Icons.remove_circle),
            color: Colors.teal,
            padding: const EdgeInsets.all(0.0),
            onPressed: () {
              setState(() {
                widget._tiles.removeAt(0);
              });
            },
          ),
          IconButton(
            iconSize: 42,
            icon: Icon(Icons.add_to_photos),
            color: Colors.pink,
            padding: const EdgeInsets.all(0.0),
            onPressed: () {
              setState(() {
                widget._tiles.add(NestedWrapExample(depth: widget.depth + 1, valuePrefix: '${widget.valuePrefix}${widget._tiles.length}.',));
              });
            },
          ),
          Text('Level ${widget.depth} / ${widget.valuePrefix}'),
        ],
      )
    );

    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buttonBar,
        wrap,
      ]
    );

    return SingleChildScrollView(
      child: Container(child: column, color: _color,),
    );
  }
}


//main() => runApp(MaterialApp(
//  home: Scaffold(
//    appBar: AppBar(),
//    body: NestedWrapExample(),
//  ),
//));
