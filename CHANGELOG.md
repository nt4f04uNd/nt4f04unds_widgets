## Unreleased

## 8.0.0
* Support Flutter 3.50.

## 7.0.0
* Support Flutter 3.35.
* Removed the unused `multiple_localization` dependency.
* Updated dependencies.
* Removed `NFTab` and `NFTabBar` widgets; use Flutter's `Tab` and `TabBar` widgets instead.

## 6.0.0
* Removed `SelectionController.wasEverSelected`, it always returned `false`.

## 5.0.0
* Support Flutter 3.29
  - The `additionalActions` in `NFShowFunctions.showDialog` now expand horizontally by default to half the dialog width.
    Previously they would shrink by default.

## 4.0.1
* Reject pointer events as drag events when the buttons change when using the `NFDragGestureRecognizer`, which is closer
  to what Flutter does.

## 4.0.0
* Support Flutter 3.22
  - `NFVerticalDragGestureRecognizer`, `NFHorizontalDragGestureRecognizer`, `NFPanGestureRecognizer` and
    `NFDragGestureRecognizer` now accept an `allowedButtonsFilter`
  - Additionally `NFDragGestureRecognizer` now accepts a `multitouchDragStrategy` and a `onlyAcceptDragOnThreshold` flag
  - Stop using deprecated style elements
  - Use `TextScaler` instead of `textScaleFactor` to support non-linear text scaling
  - Removed `NFTextSelectionControls`, replaced by Flutters
    [`TextSelectionControls`](https://api.flutter.dev/flutter/widgets/TextSelectionControls-class.html)
  - Update dependencies

## 3.0.0
* Made `SystemUiStyleController` a singleton to make it mockable (rather than an abstract class with static methods)
* Adapt to recent Flutter theme and other deprecations
* Remove `NFButton` and `NFCopyButton`
* Remove `ShowFunctions.showAlert`
* Remove localization
* Remove `NFBackButtonListener` - can now use `BackButtonListener` from the framework
* Fix `SelectionAppBar` actions alignment
* Fix `SelectionAppBar.defaultSelectionActionsBuilder` sometimes didn't animate correctly

## 2.0.0
* Fix for breaking changes in gestures in Flutter 2.5.0
* Removed deprecated `ScreenSize` and `NFSpinner`

## 1.1.5
* Added `AnimationStatusBuilder` and `AnimationStrategyBuilder`
* Overhauled `Pref` API
* Added explicit `environment` Flutter SDK constraint
* Deprecated `ScreenSize`
* Improved `RepaintBoundary` for `Slidable`
* Changed `SelectionController` return values to `TickerFuture`
* Added `SelectionController.alwaysInSelection`
* `DismissibleRoute` now exposes its controller via `SlidableControllerProvider`
* Other small stuff

## 1.1.4
* Added `MeasureSize` for debug
* Now app bar theme supports [toolbarHeight](https://github.com/flutter/flutter/pull/80467), therefore removed NFRoute and NFAppBar and moved preferred app bar height constant to NFConstants
* Made `SystemUiStyleController.actualUi` non-nullable
* Other fixes

* ## 1.1.3
* Fixed Slidable sometimes jumped or didn't react on drags
* Removed NFDefaultAnimation, as it didn't bring much benefit
* Other fixes and stuff

## 1.1.2
* Fixed bug with Slidable couldn't be dragged in some conditions
* Error improvements

## 1.1.1
* Added Enum class for creating enhanced enums

## 1.1.0
* Null safety migration
* Reviewed and refactored all widgets and APIs
* Improved docs
* Added some examples
* Added NFSpinner
* Removed NFDissmisible, NFLabelledSlider, StackTransition
* Other stuff
 
## 1.0.3
* Multiple route observers support
* Some fixes
* Basic text selection menu
* Deleted switcher

## 1.0.2
* Updated namings
* Rewritten scrollbar
* Added animation strategies
* Rewritten slidable
* Screen size api
* Some fixes
* Other stuff

## 1.0.1
* Restructured
* Generated docs
 
## 1.0.0
* Initial release
