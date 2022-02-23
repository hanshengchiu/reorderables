import 'package:flutter/widgets.dart';

import '../rendering/tabluar_flex.dart';

class TabluarFlex extends Flex {
  TabluarFlex({
    required Axis direction,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    this.decoration,
    Key? key,
  }) : super(
          key: key,
          children: children,
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  final Decoration? decoration;

  @override
  RenderTabluarFlex createRenderObject(BuildContext context) {
    return RenderTabluarFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      decoration: decoration,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderTabluarFlex renderObject) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = getEffectiveTextDirection(context)
      ..verticalDirection = verticalDirection
      ..textBaseline = textBaseline
      ..decoration = decoration
      ..configuration = createLocalImageConfiguration(context);
  }
}

/// A widget that displays its children in a horizontal array.
///
/// To cause a child to expand to fill the available horizontal space, wrap the
/// child in an [Expanded] widget.
///
/// The [Row] widget does not scroll (and in general it is considered an error
/// to have more children in a [Row] than will fit in the available room). If
/// you have a line of widgets and want them to be able to scroll if there is
/// insufficient room, consider using a [ListView].
///
/// For a vertical variant, see [Column].
///
/// If you only have one child, then consider using [Align] or [Center] to
/// position the child.
///
/// {@tool sample}
///
/// This example divides the available space into three (horizontally), and
/// places text centered in the first two cells and the Flutter logo centered in
/// the third:
///
/// ```dart
/// Row(
///   children: <Widget>[
///     Expanded(
///       child: Text('Deliver features faster', textAlign: TextAlign.center),
///     ),
///     Expanded(
///       child: Text('Craft beautiful UIs', textAlign: TextAlign.center),
///     ),
///     Expanded(
///       child: FittedBox(
///         fit: BoxFit.contain, // otherwise the logo will be tiny
///         child: const FlutterLogo(),
///       ),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// ## Troubleshooting
///
/// ### Why does my row have a yellow and black warning stripe?
///
/// If the non-flexible contents of the row (those that are not wrapped in
/// [Expanded] or [Flexible] widgets) are together wider than the row itself,
/// then the row is said to have overflowed. When a row overflows, the row does
/// not have any remaining space to share between its [Expanded] and [Flexible]
/// children. The row reports this by drawing a yellow and black striped
/// warning box on the edge that is overflowing. If there is room on the outside
/// of the row, the amount of overflow is printed in red lettering.
///
/// {@tool sample}
///
/// #### Story time
///
/// Suppose, for instance, that you had this code:
///
/// ```dart
/// Row(
///   children: <Widget>[
///     const FlutterLogo(),
///     const Text('Flutter\'s hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.'),
///     const Icon(Icons.sentiment_very_satisfied),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// The row first asks its first child, the [FlutterLogo], to lay out, at
/// whatever size the logo would like. The logo is friendly and happily decides
/// to be 24 pixels to a side. This leaves lots of room for the next child. The
/// row then asks that next child, the text, to lay out, at whatever size it
/// thinks is best.
///
/// At this point, the text, not knowing how wide is too wide, says "Ok, I will
/// be thiiiiiiiiiiiiiiiiiiiis wide.", and goes well beyond the space that the
/// row has available, not wrapping. The row responds, "That's not fair, now I
/// have no more room available for my other children!", and gets angry and
/// sprouts a yellow and black strip.
///
/// {@tool sample}
/// The fix is to wrap the second child in an [Expanded] widget, which tells the
/// row that the child should be given the remaining room:
///
/// ```dart
/// Row(
///   children: <Widget>[
///     const FlutterLogo(),
///     const Expanded(
///       child: Text('Flutter\'s hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.'),
///     ),
///     const Icon(Icons.sentiment_very_satisfied),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// Now, the row first asks the logo to lay out, and then asks the _icon_ to lay
/// out. The [Icon], like the logo, is happy to take on a reasonable size (also
/// 24 pixels, not coincidentally, since both [FlutterLogo] and [Icon] honor the
/// ambient [IconTheme]). This leaves some room left over, and now the row tells
/// the text exactly how wide to be: the exact width of the remaining space. The
/// text, now happy to comply to a reasonable request, wraps the text within
/// that width, and you end up with a paragraph split over several lines.
///
/// ## Layout algorithm
///
/// _This section describes how a [Row] is rendered by the framework._
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// Layout for a [Row] proceeds in six steps:
///
/// 1. Layout each child a null or zero flex factor (e.g., those that are not
///    [Expanded]) with unbounded horizontal constraints and the incoming
///    vertical constraints. If the [crossAxisAlignment] is
///    [CrossAxisAlignment.stretch], instead use tight vertical constraints that
///    match the incoming max height.
/// 2. Divide the remaining horizontal space among the children with non-zero
///    flex factors (e.g., those that are [Expanded]) according to their flex
///    factor. For example, a child with a flex factor of 2.0 will receive twice
///    the amount of horizontal space as a child with a flex factor of 1.0.
/// 3. Layout each of the remaining children with the same vertical constraints
///    as in step 1, but instead of using unbounded horizontal constraints, use
///    horizontal constraints based on the amount of space allocated in step 2.
///    Children with [Flexible.fit] properties that are [FlexFit.tight] are
///    given tight constraints (i.e., forced to fill the allocated space), and
///    children with [Flexible.fit] properties that are [FlexFit.loose] are
///    given loose constraints (i.e., not forced to fill the allocated space).
/// 4. The height of the [Row] is the maximum height of the children (which will
///    always satisfy the incoming vertical constraints).
/// 5. The width of the [Row] is determined by the [mainAxisSize] property. If
///    the [mainAxisSize] property is [MainAxisSize.max], then the width of the
///    [Row] is the max width of the incoming constraints. If the [mainAxisSize]
///    property is [MainAxisSize.min], then the width of the [Row] is the sum
///    of widths of the children (subject to the incoming constraints).
/// 6. Determine the position for each child according to the
///    [mainAxisAlignment] and the [crossAxisAlignment]. For example, if the
///    [mainAxisAlignment] is [MainAxisAlignment.spaceBetween], any horizontal
///    space that has not been allocated to children is divided evenly and
///    placed between the children.
///
/// See also:
///
///  * [Column], for a vertical equivalent.
///  * [Flex], if you don't know in advance if you want a horizontal or vertical
///    arrangement.
///  * [Expanded], to indicate children that should take all the remaining room.
///  * [Flexible], to indicate children that should share the remaining room but
///    that may by sized smaller (leaving some remaining room unused).
///  * [Spacer], a widget that takes up space proportional to it's flex value.
///  * The [catalog of layout widgets](https://flutter.io/widgets/layout/).
class TabluarRow extends TabluarFlex {
  /// Creates a horizontal array of children.
  ///
  /// The [direction], [mainAxisAlignment], [mainAxisSize],
  /// [crossAxisAlignment], and [verticalDirection] arguments must not be null.
  /// If [crossAxisAlignment] is [CrossAxisAlignment.baseline], then
  /// [textBaseline] must not be null.
  ///
  /// The [textDirection] argument defaults to the ambient [Directionality], if
  /// any. If there is no ambient directionality, and a text direction is going
  /// to be necessary to determine the layout order (which is always the case
  /// unless the row has no children or only one child) or to disambiguate
  /// `start` or `end` values for the [mainAxisAlignment], the [textDirection]
  /// must not be null.
  TabluarRow({
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
          key: key,
          direction: Axis.horizontal,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          decoration: decoration,
        );
}

/// A widget that displays its children in a vertical array.
///
/// To cause a child to expand to fill the available vertical space, wrap the
/// child in an [Expanded] widget.
///
/// The [Column] widget does not scroll (and in general it is considered an error
/// to have more children in a [Column] than will fit in the available room). If
/// you have a line of widgets and want them to be able to scroll if there is
/// insufficient room, consider using a [ListView].
///
/// For a horizontal variant, see [Row].
///
/// If you only have one child, then consider using [Align] or [Center] to
/// position the child.
///
/// {@tool sample}
///
/// This example uses a [Column] to arrange three widgets vertically, the last
/// being made to fill all the remaining space.
///
/// ```dart
/// Column(
///   children: <Widget>[
///     Text('Deliver features faster'),
///     Text('Craft beautiful UIs'),
///     Expanded(
///       child: FittedBox(
///         fit: BoxFit.contain, // otherwise the logo will be tiny
///         child: const FlutterLogo(),
///       ),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
/// {@tool sample}
///
/// In the sample above, the text and the logo are centered on each line. In the
/// following example, the [crossAxisAlignment] is set to
/// [CrossAxisAlignment.start], so that the children are left-aligned. The
/// [mainAxisSize] is set to [MainAxisSize.min], so that the column shrinks to
/// fit the children.
///
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   mainAxisSize: MainAxisSize.min,
///   children: <Widget>[
///     Text('We move under cover and we move as one'),
///     Text('Through the night, we have one shot to live another day'),
///     Text('We cannot let a stray gunshot give us away'),
///     Text('We will fight up close, seize the moment and stay in it'),
///     Text('It’s either that or meet the business end of a bayonet'),
///     Text('The code word is ‘Rochambeau,’ dig me?'),
///     Text('Rochambeau!', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// ## Troubleshooting
///
/// ### When the incoming vertical constraints are unbounded
///
/// When a [Column] has one or more [Expanded] or [Flexible] children, and is
/// placed in another [Column], or in a [ListView], or in some other context
/// that does not provide a maximum height constraint for the [Column], you will
/// get an exception at runtime saying that there are children with non-zero
/// flex but the vertical constraints are unbounded.
///
/// The problem, as described in the details that accompany that exception, is
/// that using [Flexible] or [Expanded] means that the remaining space after
/// laying out all the other children must be shared equally, but if the
/// incoming vertical constraints are unbounded, there is infinite remaining
/// space.
///
/// The key to solving this problem is usually to determine why the [Column] is
/// receiving unbounded vertical constraints.
///
/// One common reason for this to happen is that the [Column] has been placed in
/// another [Column] (without using [Expanded] or [Flexible] around the inner
/// nested [Column]). When a [Column] lays out its non-flex children (those that
/// have neither [Expanded] or [Flexible] around them), it gives them unbounded
/// constraints so that they can determine their own dimensions (passing
/// unbounded constraints usually signals to the child that it should
/// shrink-wrap its contents). The solution in this case is typically to just
/// wrap the inner column in an [Expanded] to indicate that it should take the
/// remaining space of the outer column, rather than being allowed to take any
/// amount of room it desires.
///
/// Another reason for this message to be displayed is nesting a [Column] inside
/// a [ListView] or other vertical scrollable. In that scenario, there really is
/// infinite vertical space (the whole point of a vertical scrolling list is to
/// allow infinite space vertically). In such scenarios, it is usually worth
/// examining why the inner [Column] should have an [Expanded] or [Flexible]
/// child: what size should the inner children really be? The solution in this
/// case is typically to remove the [Expanded] or [Flexible] widgets from around
/// the inner children.
///
/// For more discussion about constraints, see [BoxConstraints].
///
/// ### The yellow and black striped banner
///
/// When the contents of a [Column] exceed the amount of space available, the
/// [Column] overflows, and the contents are clipped. In debug mode, a yellow
/// and black striped bar is rendered at the overflowing edge to indicate the
/// problem, and a message is printed below the [Column] saying how much
/// overflow was detected.
///
/// The usual solution is to use a [ListView] rather than a [Column], to enable
/// the contents to scroll when vertical space is limited.
///
/// ## Layout algorithm
///
/// _This section describes how a [Column] is rendered by the framework._
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// Layout for a [Column] proceeds in six steps:
///
/// 1. Layout each child a null or zero flex factor (e.g., those that are not
///    [Expanded]) with unbounded vertical constraints and the incoming
///    horizontal constraints. If the [crossAxisAlignment] is
///    [CrossAxisAlignment.stretch], instead use tight horizontal constraints
///    that match the incoming max width.
/// 2. Divide the remaining vertical space among the children with non-zero
///    flex factors (e.g., those that are [Expanded]) according to their flex
///    factor. For example, a child with a flex factor of 2.0 will receive twice
///    the amount of vertical space as a child with a flex factor of 1.0.
/// 3. Layout each of the remaining children with the same horizontal
///    constraints as in step 1, but instead of using unbounded vertical
///    constraints, use vertical constraints based on the amount of space
///    allocated in step 2. Children with [Flexible.fit] properties that are
///    [FlexFit.tight] are given tight constraints (i.e., forced to fill the
///    allocated space), and children with [Flexible.fit] properties that are
///    [FlexFit.loose] are given loose constraints (i.e., not forced to fill the
///    allocated space).
/// 4. The width of the [Column] is the maximum width of the children (which
///    will always satisfy the incoming horizontal constraints).
/// 5. The height of the [Column] is determined by the [mainAxisSize] property.
///    If the [mainAxisSize] property is [MainAxisSize.max], then the height of
///    the [Column] is the max height of the incoming constraints. If the
///    [mainAxisSize] property is [MainAxisSize.min], then the height of the
///    [Column] is the sum of heights of the children (subject to the incoming
///    constraints).
/// 6. Determine the position for each child according to the
///    [mainAxisAlignment] and the [crossAxisAlignment]. For example, if the
///    [mainAxisAlignment] is [MainAxisAlignment.spaceBetween], any vertical
///    space that has not been allocated to children is divided evenly and
///    placed between the children.
///
/// See also:
///
///  * [Row], for a horizontal equivalent.
///  * [Flex], if you don't know in advance if you want a horizontal or vertical
///    arrangement.
///  * [Expanded], to indicate children that should take all the remaining room.
///  * [Flexible], to indicate children that should share the remaining room but
///    that may size smaller (leaving some remaining room unused).
///  * [SingleChildScrollView], whose documentation discusses some ways to
///    use a [Column] inside a scrolling container.
///  * [Spacer], a widget that takes up space proportional to it's flex value.
///  * The [catalog of layout widgets](https://flutter.io/widgets/layout/).
class TabluarColumn extends TabluarFlex {
  /// Creates a vertical array of children.
  ///
  /// The [direction], [mainAxisAlignment], [mainAxisSize],
  /// [crossAxisAlignment], and [verticalDirection] arguments must not be null.
  /// If [crossAxisAlignment] is [CrossAxisAlignment.baseline], then
  /// [textBaseline] must not be null.
  ///
  /// The [textDirection] argument defaults to the ambient [Directionality], if
  /// any. If there is no ambient directionality, and a text direction is going
  /// to be necessary to disambiguate `start` or `end` values for the
  /// [crossAxisAlignment], the [textDirection] must not be null.
  TabluarColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    VerticalDirection verticalDirection = VerticalDirection.down,
    List<Widget> children = const <Widget>[],
    TextDirection? textDirection,
    TextBaseline? textBaseline,
    Decoration? decoration,
    Key? key,
  }) : super(
          children: children,
          key: key,
          direction: Axis.vertical,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          decoration: decoration,
        );
}
