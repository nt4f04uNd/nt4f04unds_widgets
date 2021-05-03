import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Layouts a widgets and measures its size.
///
/// This widget should be used only for debug purposes,
/// For production, consider using [boxy](https://pub.dev/packages/boxy) package.
///
/// Taken from https://stackoverflow.com/a/60868972/9710294
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({
    Key? key,
    required Widget child,
    required this.onChange,
  }) : super(key: key, child: child);

  final OnWidgetSizeChange onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  MeasureSizeRenderObject(this.onChange);
  
  late Size oldSize;
  final OnWidgetSizeChange onChange;

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize)
      return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}
