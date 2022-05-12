## [0.5.0] - 12 May 2022.
* Bugfix: [#51](https://github.com/hanshengchiu/reorderables/issues/151). Added lint fixes due to Flutter 3.
  (thanks [diegotori](https://github.com/diegotori)).
* ***Breaking Change***: Library now requires Flutter version `3.0.0` or higher.

## [0.4.4] - 18 April 2022.
* Bugfix: [#146](https://github.com/hanshengchiu/reorderables/issues/146). ReorderableWrap: adding scroll controller causes exception
  (thanks [diegotori](https://github.com/diegotori)).

## [0.4.3] - 22 February 2022.
* New Feature: [#143](https://github.com/hanshengchiu/reorderables/pull/143). Allow enableReorder on DraggableWrap
  (thanks [89jd](https://github.com/89jd)).
* Removed redundant import statements due to latest Dart analysis rules.  

## [0.4.2] - 01 December 2021.
* Bugfix: [#75](https://github.com/hanshengchiu/reorderables/issues/75). Add ReorderStartedCallback to ReorderableFlex, Change ReorderableFlex Draggable data to index
  (thanks [pxsanghyo](https://github.com/pxsanghyo)).
* New Feature: [#111](https://github.com/hanshengchiu/reorderables/pull/121). Fix: Made Non-ReorderableWrap item non-droppable and non-draggable
  (thanks [avi-yadav](https://github.com/avi-yadav)).
* New Feature: [#136](https://github.com/hanshengchiu/reorderables/pull/136). Ft: add scroll phyiscs to SingleChildScrollView in ReorderableWrap
  (thanks [pcvdheuvel](https://github.com/pcvdheuvel)).
* New Feature: [#138](https://github.com/hanshengchiu/reorderables/pull/138). Flutter 2.5 deprecation fixes
  (thanks [diegotori](https://github.com/diegotori)).
  
## [0.4.1] - 11 April 2021.
* Addresses Issue [#111](https://github.com/hanshengchiu/reorderables/issues/111). Resolves ReorderableSliverList ScrollController conflict (thanks [qAison](https://github.com/qAison)).

## [0.4.0] - 24 March 2021.

* Initial Null-Safety release.

## [0.3.2] - 10 March 2020.
* Fix health suggestions.

## [0.3.1] - 10 March 2020.
* Supports making individual child non-reorderable. See ReorderableColumn example 1.

## [0.3.0] - 10 Jan 2020.
* Fix: Bad type in onLeave

## [0.2.12] - 22 June 2019.
* Removed dependency of FlutterErrorDetails and other ErrorXXX classes.
* Bugfix: needsLongPressDraggable had no default value.

## [0.2.11+1] - 11 June 2019.
* Flutter version dependency in pubspec

## [0.2.11] - 11 June 2019.

* ReorderableRow and ReorderableColumn:
Set needsLongPressDraggable to false to use Draggable.
Provide scrollController if use of external scroller controller is preferred.
* Added onReorderStarted callback in ReorderableWrap
* updated README

## [0.2.10] - 10 June 2019.

* Bugfix: DiagnosticsNode instead of String for newer version of Flutter

## [0.2.9] - 16 May 2019.

* Allows use of CupertinoApp

## [0.2.8] - 16 May 2019.

* Added onNoReorder callback

## [0.2.7] - 11 May 2019.

* Sliver's cross axis alignment defaults to start
* Remove the use of global keys in reorderable sliver to allow nested sliver

## [0.2.6] - 6 May 2019.

* Bugfix: "width is null"

## [0.2.5] - 3 May 2019.

* Bugfix: ReorderableWrap supports nested wraps.
* Improvement: children of ReorderableWrap don't have to have a key anymore.
* Included nested ReorderableWrap example

## [0.2.1] - 28 April 2019.

* Bugfix: couldn't add/remove elements in ReorderableWrap.
* Bugfix: added elements weren't draggable in ReorderableSliverList.
* Merged pull request: flag to choose between long press draggable and the short one.

## [0.2.0] - 5 March 2019.

* Added ReorderableSliverList, ReorderableSliverChildBuilderDelegate, and ReorderableSliverChildListDelegate.
* Bugfix: ReorderableFlex's animation.

## [0.1.6] - 1 March 2019.

* Updated API references and README.
* Bugfix: made ReorderableTable's onReorder required.
* Bugfix: corrected scrollDirection in ReorderableRow.

## [0.1.5] - 26 February 2019.

* Updated API references.

## [0.1.4] - 25 February 2019.

* Alignment bugfix.
* Added column examples.
