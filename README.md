# nt4f04und's widgets

### Manifest

A library for personal use.

The comments are poor, the code is horrible.

I cannot (and don't want to) guarantee you the safety of your ass during its usage.

**It's mine.**

#### [Pub dev package](https://pub.dev/packages/nt4f04unds_widgets)

### Setup

Call the `NFWidgets.init`:

```dart
final RouteObserver<Route> routeObserver = RouteObserver();

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    
    NFWidgets.init(
      routeObservers: [routeObserver],
      navigatorKey: App.navigatorKey,
      defaultSystemUiStyle: Constants.AppSystemUIThemes.defaultStyle,
      defaultModalSystemUiStyle: null,
      defaultBottomSheetSystemUiStyle: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      color: Colors.black,
      navigatorKey: App.navigatorKey,
      theme: Constants.AppTheme.theme,
      supportedLocales: Constants.Config.supportedLocales
          .map<Locale>((e) => Locale(e, e.toUpperCase())),
      localizationsDelegates: const [
        NFLocalizations.delegate,
        // ... other locales
      ],
      navigatorObservers: [routeObserver],
      onGenerateInitialRoutes: (routeName) => RouteControl.handleOnGenerateInitialRoutes(routeName, context),
      onGenerateRoute: (settings) => RouteControl.handleOnGenerateRoutes(settings),
    );
  }
}

```

