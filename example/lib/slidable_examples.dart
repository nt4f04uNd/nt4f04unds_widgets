import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'main.dart';

class SlidableExamples extends StatelessWidget {
  const SlidableExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      name: 'slidable',
      children: [
        Tile(
          name: 'Youtube app',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _Slidable1())),
        ),
        Tile(
          name: 'Another slidable bottom bar',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _Slidable2())),
        ),
        Tile(
          name: 'Drawer',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _Slidable3())),
        ),
      ],
    );
  }
}

class _Slidable1 extends StatefulWidget {
  _Slidable1({Key? key}) : super(key: key);

  @override
  _Slidable1State createState() => _Slidable1State();
}

class _Slidable1State extends State<_Slidable1>
    with SingleTickerProviderStateMixin {
  late SlidableController controller;
  @override
  void initState() {
    super.initState();
    controller = SlidableController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> list = List.generate(1000, (index) => index);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(title: Text('Youtube app')),
            ),
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(index.toString()),
                ),
              ),
            ),
            Slidable(
              start: 0.0,
              end: 0.0,
              controller: controller,
              disableSlideTransition: true,
              child: Container(
                constraints: BoxConstraints(maxWidth: screenWidth),
                child: Image.asset(
                  'assets/yt.png',
                ),
              ),
              barrier: Container(color: Colors.black54),
              childBuilder: (animation, child) {
                return AnimatedBuilder(
                  animation: animation,
                  child: child,
                  builder: (context, child) {
                    final intervalAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Interval(0.0, 0.2),
                    );
                    final remainingIntervalAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Interval(0.2, 1.0),
                    );
                    return Align(
                      child: SizedBox(
                        height: screenHeight,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: screenWidth,
                                height: 100 +
                                    animation.value *
                                        (screenHeight / 4 - 100.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: screenWidth / 4 +
                                          screenWidth /
                                              4 *
                                              3 *
                                              intervalAnimation.value,
                                      height: double.infinity,
                                      child: child,
                                      color: Colors.black,
                                    ),
                                    Flexible(
                                      child: Container(
                                        width: screenWidth,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenWidth,
                                height: remainingIntervalAnimation.value *
                                    (screenHeight / 4 * 3),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Slidable2 extends StatefulWidget {
  _Slidable2({Key? key}) : super(key: key);

  @override
  _Slidable2State createState() => _Slidable2State();
}

class _Slidable2State extends State<_Slidable2>
    with SingleTickerProviderStateMixin {
  late SlidableController controller;
  @override
  void initState() {
    super.initState();
    controller = SlidableController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> list = List.generate(1000, (index) => index);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(title: Text('Another slidable bottom bar'))),
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(index.toString())),
              ),
            ),
            Slidable(
              start: 1.0 - 64.0 / screenHeight,
              end: 0.0,
              controller: controller,
              child: Container(
                color: Colors.red,
              ),
              barrier: Container(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slidable3 extends StatefulWidget {
  _Slidable3({Key? key}) : super(key: key);

  @override
  _Slidable3State createState() => _Slidable3State();
}

class _Slidable3State extends State<_Slidable3>
    with SingleTickerProviderStateMixin {
  late SlidableController controller;
  @override
  void initState() {
    super.initState();
    controller = SlidableController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> list = List.generate(1000, (index) => index);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top;
    final double edgeGestureWidth = screenHeight / 2;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(title: Text('Drawer')),
            ),
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(index.toString()),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (_, child) => SizedBox(
                width: controller.isDismissed ? edgeGestureWidth / 2 : null,
                child: child,
              ),
              child: Slidable(
                direction: SlideDirection.right,
                start: -304.0 / screenWidth,
                end: 0.0,
                controller: controller,
                onBarrierTap: controller.close,
                barrierIgnoringStrategy:
                    const IgnoringStrategy(dismissed: true),
                hitTestBehaviorStrategy: const HitTestBehaviorStrategy.opaque(
                  dismissed: HitTestBehavior.translucent,
                ),
                child: Container(
                  height: mediaQuery.size.height,
                  width: mediaQuery.size.width,
                  child: Container(
                    width: 304.0,
                    alignment: Alignment.centerLeft,
                    child: Drawer(),
                  ),
                ),
                childBuilder: (animation, child) =>
                    controller.isDismissed ? const SizedBox.shrink() : child,
                barrier: Container(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
