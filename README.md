# nt4f04und's widgets

### manifest

a library for personal use

the comments are poor, the code is horrible

i cannot (and don't want to) guarantee you the safety of your ass during its usage

**it's mine**

#### [pub dev package](https://pub.dev/packages/nt4f04unds_widgets)

### setup


```dart
final RouteObserver<Route> routeObserver = RouteObserver();

class App extends StatefulWidget {
  App({Key key}) : super(key: key);
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    NFWidgets.init(
      routeObservers: [routeObserver],
      navigatorKey: App.navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NFTheme(
      data: NFThemeData(systemUiStyle: SystemUiOverlayStyle.dark),
      child: MaterialApp(
        title: 'Example',
        color: Colors.black,
        navigatorKey: App.navigatorKey,
        theme: Constants.AppTheme.theme,
        supportedLocales: Constants.Config.supportedLocales,
        localizationsDelegates: const [
          NFLocalizations.delegate,
          // ... other locales
        ],
        navigatorObservers: [routeObserver],
        onGenerateInitialRoutes: (routeName) => RouteControl.handleOnGenerateInitialRoutes(routeName, context),
        onGenerateRoute: (settings) => RouteControl.handleOnGenerateRoutes(settings),
      ),
    );
  }
}

```

### naming conventions

names have `NF` prefix if:

* they could be easily messed up with some names from flutter - `NFSnackbarController`
* i just preferred them to have this prefix - `NFCopyButton`
