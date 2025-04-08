import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'main.dart';

class RouteTransitionExamples extends StatelessWidget {
  const RouteTransitionExamples({super.key});

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(backgroundColor: Colors.red, appBar: AppBar());
    final uiStyle = SystemUiOverlayStyle(systemNavigationBarColor: Colors.green);
    final transitionSettings = RouteTransitionSettings(uiStyle: uiStyle);
    return Screen(
      name: 'route_transitions',
      children: [
        Tile(
          name: 'expand_up_transition',
          onTap:
              () => Navigator.of(
                context,
              ).push(ExpandUpRouteTransition(child: child, transitionSettings: transitionSettings)),
        ),
        Tile(
          name: 'fade_in_transition',
          onTap:
              () => Navigator.of(
                context,
              ).push(FadeInRouteTransition(child: child, transitionSettings: transitionSettings)),
        ),
        Tile(
          name: 'stack_fade_transition',
          onTap:
              () => Navigator.of(context).push(
                StackFadeRouteTransition(
                  transitionSettings: StackFadeRouteTransitionSettings(
                    dismissible: true,
                    opaque: false,
                    uiStyle: uiStyle,
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.red,
                    appBar: AppBar(),
                    body: const Center(child: Text('dismiss me by swiping to right!')),
                  ),
                ),
              ),
        ),
        Tile(
          name: 'zoom_transition',
          onTap:
              () =>
                  Navigator.of(context).push(ZoomRouteTransition(child: child, transitionSettings: transitionSettings)),
        ),
      ],
    );
  }
}
