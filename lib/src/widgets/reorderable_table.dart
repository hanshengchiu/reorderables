//import 'dart:math' as math;
import 'package:flutter/material.dart';

import './reorderable_flex.dart';
import './tabluar_flex.dart';
import './typedefs.dart';
import '../rendering/tabluar_flex.dart';

class ReorderableTableRow extends TabluarRow {
  ReorderableTableRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    Decoration? decoration,
    Key? key,
  }) : super(
          children: children,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          decoration: decoration,
          key: key,
        );
}

typedef DecorateDraggableFeedback = Widget Function(
    BuildContext feedbackContext, Widget draggableFeedback);

/// Reorderable (drag and drop) version of [Table], a widget that displays its
/// children in a two-dimensional grid.
///
/// The difference between table and list is that cells in a table are
/// horizontally aligned, whereas in a list, each item can have children but
/// they are not aligned with children in another item.
/// Making a row draggable requires cells to be contained in a single widget.
/// This isn't achievable with [Table] or [GridView] widget since their
/// children are laid out as cells of widget instead of rows of widget.
///
/// Cells of each row must be children of [ReorderableTableRow] and each
/// [ReorderableTableRow] must have a key.
///
/// See also:
///
///  * [ReorderableTableRow], which is the container of a row of cells.
///  * [Table], which uses the table layout algorithm for its children.
class ReorderableTable extends StatelessWidget {
  /// Creates a reorderable table.
  ///
  /// The [children], [defaultColumnWidth], and [defaultVerticalAlignment]
  /// arguments must not be null.
  ReorderableTable({
    required this.onReorder,
    this.children = const <ReorderableTableRow>[],
    this.columnWidths,
    this.defaultColumnWidth = const FlexColumnWidth(1.0),
    this.textDirection,
    this.border,
    this.defaultVerticalAlignment = TableCellVerticalAlignment.top,
    this.textBaseline,
    this.header,
    this.footer,
    this.decorateDraggableFeedback,
    this.onNoReorder,
    this.reorderAnimationDuration,
    this.scrollAnimationDuration,
    this.ignorePrimaryScrollController = false,
    Key? key,
  })  : assert(() {
          if (children.any((ReorderableTableRow row1) =>
              row1.key != null &&
              children.any((ReorderableTableRow row2) =>
                  row1 != row2 && row1.key == row2.key))) {
            throw FlutterError(
                'Two or more ReorderableTableRow children of this Table had the same key.\n'
                'All the keyed ReorderableTableRow children of a Table must have different Keys.');
          }
          return true;
        }()),
//      assert(() {
//        if (children.isNotEmpty) {
//          final int cellCount = children.first.children.length;
//          if (children.any((ReorderableTableRow row) => row.children.length != cellCount)) {
//            throw FlutterError(
//              'Table contains irregular row lengths.\n'
//                'Every ReorderableTableRow in a Table must have the same number of children, so that every cell is filled. '
//                'Otherwise, the table will contain holes.'
//            );
//          }
//        }
//        return true;
//      }()),

        super(key: key) {
    assert(() {
      final List<Widget> flatChildren = children
          .expand<Widget>((ReorderableTableRow row) => row.children)
          .toList(growable: false);
      if (debugChildrenHaveDuplicateKeys(this, flatChildren)) {
        throw FlutterError(
            'Two or more cells in this Table contain widgets with the same key.\n'
            'Every widget child of every TableRow in a Table must have different keys. The cells of a Table are '
            'flattened out for processing, so separate cells cannot have duplicate keys even if they are in '
            'different rows.');
      }
      return true;
    }());
  }

  /// The rows of the table.
  ///
  /// Every row in a table must have the same number of children, and all the
  /// children must be non-null.
  final List<ReorderableTableRow> children;

  /// How the horizontal extents of the columns of this table should be determined.
  ///
  /// If the [Map] has a null entry for a given column, the table uses the
  /// [defaultColumnWidth] instead. By default, that uses flex sizing to
  /// distribute free space equally among the columns.
  ///
  /// The [FixedColumnWidth] class can be used to specify a specific width in
  /// pixels. That is the cheapest way to size a table's columns.
  ///
  /// The layout performance of the table depends critically on which column
  /// sizing algorithms are used here. In particular, [IntrinsicColumnWidth] is
  /// quite expensive because it needs to measure each cell in the column to
  /// determine the intrinsic size of the column.
  final Map<int, TableColumnWidth>? columnWidths;

  /// How to determine with widths of columns that don't have an explicit sizing algorithm.
  ///
  /// Specifically, the [defaultColumnWidth] is used for column `i` if
  /// `columnWidths[i]` is null.
  final TableColumnWidth defaultColumnWidth;

  /// The direction in which the columns are ordered.
  ///
  /// Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// The style to use when painting the boundary and interior divisions of the table.
  final TableBorder? border;

  /// How cells that do not explicitly specify a vertical alignment are aligned vertically.
  final TableCellVerticalAlignment defaultVerticalAlignment;

  /// The text baseline to use when aligning rows using [TableCellVerticalAlignment.baseline].
  final TextBaseline? textBaseline;

  /// Non-reorderable widget at top of the table. Cells in [header] also affects
  /// alignment of columns.
  final Widget? header;

  /// Non-reorderable widget at top of the table. Cells in [footer] also affects
  /// alignment of columns.
  final Widget? footer;

  /// Called when a child is dropped into a new position to shuffle the
  /// children.
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final DecorateDraggableFeedback? decorateDraggableFeedback;
  final Duration? reorderAnimationDuration;
  final Duration? scrollAnimationDuration;
  final bool ignorePrimaryScrollController;

  @override
  Widget build(BuildContext context) {
//    return TabluarColumn(
//      mainAxisSize: MainAxisSize.min,
//      children: itemRows +
//        [
//          ReorderableTableRow(key: ValueKey<int>(1), mainAxisSize:MainAxisSize.min, children: <Widget>[Text('111111111111'), Text('222')]),
//          ReorderableTableRow(key: ValueKey<int>(2), mainAxisSize:MainAxisSize.min, children: <Widget>[Text('33'), Text('4444444444')])
//        ],
//    )
    final GlobalKey tableKey =
        GlobalKey(debugLabel: '$ReorderableTable table key');

    return ReorderableFlex(
        header: header,
        footer: footer,
        children: children,
        onReorder: onReorder,
        onNoReorder: onNoReorder,
        direction: Axis.vertical,
        buildItemsContainer: (BuildContext containerContext, Axis direction,
            List<Widget> children) {
          return TabluarFlex(
              key: tableKey,
              direction: direction,
//          mainAxisAlignment: mainAxisAlignment,
//          mainAxisSize: MainAxisSize.min,
//          crossAxisAlignment: crossAxisAlignment,
              textDirection: textDirection,
//          verticalDirection: verticalDirection,
              textBaseline: textBaseline,
              children: children);
        },
        buildDraggableFeedback: (BuildContext feedbackContext,
            BoxConstraints constraints, Widget child) {
          // The child is a ReorderableTableRow because children is a List<ReorderableTableRow>
          ReorderableTableRow tableRow = child as ReorderableTableRow;
          RenderTabluarFlex renderTabluarFlex =
              tableKey.currentContext!.findRenderObject() as RenderTabluarFlex;
          int grandChildIndex = 0;
          for (;
              grandChildIndex < tableRow.children.length;
              grandChildIndex++) {
            tableRow.children[grandChildIndex] = ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: renderTabluarFlex
                        .maxGrandchildrenCrossSize[grandChildIndex]!),
                child: tableRow.children[grandChildIndex]);
          }
          for (;
              grandChildIndex <
                  renderTabluarFlex.maxGrandchildrenCrossSize.length;
              grandChildIndex++) {
            tableRow.children.add(ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: renderTabluarFlex
                      .maxGrandchildrenCrossSize[grandChildIndex]!),
            ));
          }

          ConstrainedBox constrainedTableRow =
              ConstrainedBox(constraints: constraints, child: tableRow);

          return Transform(
            transform: new Matrix4.rotationZ(0),
            alignment: FractionalOffset.topLeft,
            child: Material(
//            child: Card(child: ConstrainedBox(constraints: constraints, child: tableRow)),
              child: (decorateDraggableFeedback ??
                      defaultDecorateDraggableFeedback)(
                  feedbackContext, constrainedTableRow),
              elevation: 6.0,
              color: Colors.transparent,
              borderRadius: BorderRadius.zero,
            ),
          );
        },
        reorderAnimationDuration: reorderAnimationDuration,
        scrollAnimationDuration: scrollAnimationDuration,
        ignorePrimaryScrollController: ignorePrimaryScrollController);
  }

  Widget defaultDecorateDraggableFeedback(
          BuildContext feedbackContext, Widget draggableFeedback) =>
      Card(child: draggableFeedback);
}
