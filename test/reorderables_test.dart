import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderables/reorderables.dart';

void main() {
  testWidgets(
    'ending a drag after disposal does not use disposed animation controllers',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableWrap(
            needsLongPressDraggable: false,
            onReorder: (int oldIndex, int newIndex) {},
            children: const <Widget>[
              Icon(Icons.looks_one, key: ValueKey<String>('one')),
              Icon(Icons.looks_two, key: ValueKey<String>('two')),
            ],
          ),
        ),
      );
      await tester.pump();

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey<String>('one'))),
      );
      await gesture.moveBy(const Offset(kTouchSlop + 1, 0));
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await gesture.up();
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
