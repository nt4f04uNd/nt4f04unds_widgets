## 3.0.0

* Made `SystemUiStyleController` a singleton to make it mockable (rather than an abstract class with static methods)
* Adapt to recent Flutter theme and other deprecations
* Remove `NFButton` and `NFCopyButton`
* Remove `ShowFunctions.showAlert`
* Remove localization
* Remove `NFBackButtonListener` - can now use `BackButtonListener` from the framework

## 2.0.0

* fix for breaking changes in gestures in Flutter 2.5.0
* removed deprecated `ScreenSize` and `NFSpinner`

## 1.1.5

* added `AnimationStatusBuilder` and `AnimationStrategyBuilder`
* overhauled `Pref` API
* added explicit `environment` Flutter SDK constraint
* deprecated `ScreenSize`
* improved `RepaintBoundary` for `Slidable`
* changed `SelectionController` return values to `TickerFuture`
* added `SelectionController.alwaysInSelection`
* `DismissibleRoute` now exposes its controller via `SlidableControllerProvider`
* other small stuff

## 1.1.4

* added `MeasureSize` for debug
* now app bar theme supports [toolbarHeight](https://github.com/flutter/flutter/pull/80467), therefore removed NFRoute and NFAppBar and moved preferred app bar height constant to NFConstants
* made `SystemUiStyleController.actualUi` non-nullable
* other fixes

* ## 1.1.3

* fixed Slidable sometimes jumped or didn't react on drags
* removed NFDefaultAnimation, as it didn't bring much benefit
* other fixes and stuff

## 1.1.2

* fixed bug with Slidable couldn't be dragged in some conditions
* error improvements

## 1.1.1

* added Enum class for creating enhanced enums

## 1.1.0

* null safety migration
* revied and refactored all widgets and APIs
* improved docs
* added some examples
* added NFSpinner
* removed NFDissmisible, NFLabelledSlider, StackTransition
* other stuff
 
## 1.0.3

* multiple route observers support
* some fixes
* basic text selection menu
* deleted switcher

## 1.0.2

* updated namings
* rewritten scrollbar
* added animation strategies
* rewritten slidable
* screen size api
* some fixes
* other stuff

## 1.0.1

* restructured
* generated docs
 
## 1.0.0

* initial release