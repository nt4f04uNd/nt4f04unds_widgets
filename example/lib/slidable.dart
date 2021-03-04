import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'main.dart';

class SlidableExamples extends StatelessWidget {
  const SlidableExamples({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      name: 'slidable',
      children: [
        Tile(
          name: 'Youtube app', 
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => _Slidable1())
          ),
        ),
        Tile(
          name: 'Another slidable bottom bar', 
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => _Slidable2())
          ),
        ),
        Tile(
          name: 'Drawer', 
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => _Slidable3())
          ),
        ),
      ],
    );
  }
}

class _Slidable1 extends StatefulWidget {
  _Slidable1({Key key}) : super(key: key);

  @override
  _Slidable1State createState() => _Slidable1State();
}

class _Slidable1State extends State<_Slidable1> with SingleTickerProviderStateMixin {
  SlidableController controller;
  @override
  void initState() {
    super.initState();
    controller = SlidableController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> list = List.generate(1000, (index) => index);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(title: Text('Youtube app'))
            ),
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: ListView.builder(
                itemCount: list.length, 
                itemBuilder:(context, index) => ListTile(title: Text(index.toString())),
              ),
            ),
            Slidable(
              direction: SlideDirection.upFromBottom,
              startOffset: Offset.zero,
              endOffset: Offset.zero,
              controller: controller,
              disableSlideTransition: true,
              child: Container(
                constraints: BoxConstraints(maxWidth: screenWidth),
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/YouTube_full-color_icon_%282017%29.svg/1024px-YouTube_full-color_icon_%282017%29.svg.png',
                ),
              ),
              barrier: Container(color: Colors.black54),
              childBuilder: (animation, child) {
                return AnimatedBuilder(
                  animation: animation,
                  child: child,
                  builder: (context, child) {
                    final intervalAnimation = CurvedAnimation(parent: animation, curve: Interval(0.0, 0.2));
                    final remainingIntervalAnimation = CurvedAnimation(parent: animation, curve: Interval(0.2, 1.0));
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
                              height: 100 + animation.value * (screenHeight / 4 - 100.0), 
                              child: Row(
                                children: [
                                  Container(
                                    width: screenWidth / 4 + screenWidth / 4 * 3 * intervalAnimation.value,
                                    height: double.infinity,
                                    child: child,
                                    color: Colors.black
                                  ),
                                  Flexible(
                                    child: Container(width: screenWidth, color: Colors.red)
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: screenWidth, 
                              height: remainingIntervalAnimation.value * (screenHeight / 4 * 3), 
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
  _Slidable2({Key key}) : super(key: key);

  @override
  _Slidable2State createState() => _Slidable2State();
}

class _Slidable2State extends State<_Slidable2> with SingleTickerProviderStateMixin {
  SlidableController controller;
  @override
  void initState() {
    super.initState();
    controller = SlidableController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> list = List.generate(1000, (index) => index);
    final screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(title: Text('Another slidable bottom bar'))
            ),
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: ListView.builder(
                itemCount: list.length, 
                itemBuilder:(context, index) => ListTile(title: Text(index.toString())),
              ),
            ),
            Slidable(
              direction: SlideDirection.upFromBottom,
              startOffset: Offset(1.0 - 64.0 / screenHeight, 0.0),
              endOffset: Offset.zero,
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
  _Slidable3({Key key}) : super(key: key);

  @override
  _Slidable3State createState() => _Slidable3State();
}

class _Slidable3State extends State<_Slidable3> with SingleTickerProviderStateMixin {
  SlidableController controller;
  @override
  void initState() {
    super.initState();
    controller = SlidableController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> list = List.generate(1000, (index) => index);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final double edgeGestureWidth = screenHeight / 2;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(title: Text('Drawer'))
            ),
            Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: ListView.builder(
                itemCount: list.length, 
                itemBuilder:(context, index) => ListTile(title: Text(index.toString())),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (_, child) => SizedBox(
                width: controller.isDismissed ? edgeGestureWidth / 2 : null,
                child: child
              ),
              child: Slidable(
                direction: SlideDirection.startToEnd,
                startOffset: Offset(-304.0 / screenWidth, 0.0),
                endOffset: Offset(0.0 , 0.0),
                controller: controller,
                onBarrierTap: controller.close,
                barrierIgnoringStrategy: const IgnoringStrategy(
                  dismissed: true,
                ),
                hitTestBehaviorStrategy: HitTestBehaviorStrategy.opaque(
                  dismissed: HitTestBehavior.translucent,
                ),
                draggedHitTestBehaviorStrategy: HitTestBehaviorStrategy.opaque(
                  dismissed: HitTestBehavior.translucent,
                ),
                child: Container(width: 304.0, alignment: Alignment.centerLeft, child: Drawer()),
                childBuilder: (animation, child) => controller.isDismissed ? const SizedBox.shrink() : child,
                barrier: Container(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}