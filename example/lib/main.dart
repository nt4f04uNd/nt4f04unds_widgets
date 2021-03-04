import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'slidable.dart';
import 'route_transitions.dart';
import 'snackbar.dart';

void main() {
  runApp(App());
}

MaterialPageRoute route(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}

class App extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Examples',
      navigatorKey: App.navigatorKey,
      // checkerboardRasterCacheImages: true,
      // showPerformanceOverlay: true,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() { 
    super.initState();
    NFWidgets.init(
      navigatorKey: App.navigatorKey,
      routeObservers: [RouteObserver()],
    );
  }

  void _handleTap(Widget child) {
    Navigator.of(context).push(route(child));
  }

  @override
  Widget build(BuildContext context) {
    return NFTheme(
      data: NFThemeData(systemUiStyle: SystemUiOverlayStyle.dark),
      child: Screen(
        name: 'Examples',
        children: [
          Tile(
            name: 'slidable',
            onTap: () => _handleTap(SlidableExamples()),
          ),
          Tile(
            name: 'route_transitions',
            onTap: () => _handleTap(RouteTransitionExamples()),
          ),
          Tile(
            name: 'snackbar',
            onTap: () => _handleTap(SnackbarExamples()),
          ),
        ],
      ),
    );
  }
}

class Screen extends StatelessWidget {
  const Screen({ Key key, @required this.name, @required this.children }) : super(key: key);

  final String name;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(children: children),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({ Key key, this.name = '', this.onTap }) : super(key: key);

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: onTap,
    );
  }
}