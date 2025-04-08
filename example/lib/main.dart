import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'slidable_examples.dart';
import 'route_transitions_examples.dart';
import 'snackbar_examples.dart';

final routerObserver = RouteObserver();

void main() {
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  for (var view in binding.renderViews) {
    view.automaticSystemUiAdjustment = false;
  }
  runApp(App());
}

class App extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  const App({super.key});

  @override
  State createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    NFWidgets.init(navigatorKey: App.navigatorKey, routeObservers: [routerObserver]);
    SystemUiStyleController.instance.setSystemUiOverlay(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    return NFTheme(
      data: NFThemeData(systemUiStyle: SystemUiOverlayStyle.dark),
      child: MaterialApp(
        title: 'Examples',
        navigatorKey: App.navigatorKey,
        navigatorObservers: [routerObserver],
        // checkerboardRasterCacheImages: true,
        // showPerformanceOverlay: true,
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MaterialPageRoute _route(Widget child) {
    return MaterialPageRoute(builder: (context) => child);
  }

  void _handleTap(PageRoute child) {
    Navigator.of(context).push(child);
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      name: 'Examples',
      children: [
        Tile(name: 'slidable', onTap: () => _handleTap(_route(SlidableExamples()))),
        Tile(
          name: 'route_transitions',
          onTap: () => _handleTap(FadeInRouteTransition(child: RouteTransitionExamples())),
        ),
        Tile(name: 'snackbar', onTap: () => _handleTap(_route(SnackbarExamples()))),
      ],
    );
  }
}

class Screen extends StatelessWidget {
  const Screen({super.key, required this.name, this.children});

  final String name;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(name)), body: children == null ? null : ListView(children: children!));
  }
}

class Tile extends StatelessWidget {
  const Tile({super.key, this.name = '', this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(name), onTap: onTap);
  }
}
