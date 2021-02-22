import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'main.dart';

class RouteTransitionExamples extends StatelessWidget {
  const RouteTransitionExamples({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      name: 'route_transitions',
      children: [
        Tile(
          name: 'expand_up_transition',
          onTap: () => Navigator.of(context).push(
            ExpandUpRouteTransition(route: Scaffold(backgroundColor: Colors.red))
          ),
        ),
        Tile(
          name: 'fade_in_transition',
          onTap: () => Navigator.of(context).push(
            FadeInRouteTransition(route: Scaffold(backgroundColor: Colors.red))
          ),
        ),
        Tile(
          name: 'stack_fade_transition',
          onTap: () => Navigator.of(context).push(
            StackFadeRouteTransition(route: Scaffold(backgroundColor: Colors.red))
          ),
        ),
        Tile(
          name: 'stack_transition',
          onTap: () => Navigator.of(context).push(
            StackRouteTransition(route: Scaffold(backgroundColor: Colors.red))
          ),
        ),
        Tile(
          name: 'zoom_transition',
          onTap: () => Navigator.of(context).push(
            ZoomRouteTransition(route: Scaffold(backgroundColor: Colors.red))
          ),
        ),
      ],
    );
  }
}