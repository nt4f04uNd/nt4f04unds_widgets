import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This was taken from https://github.com/flutter/flutter/issues/18450#issuecomment-575447316
///
/// The reason to use this is to make [HitTestBehavior.translucent]
/// work as expected with stack.
class StackWithAllChildrenReceiveEvents extends Stack {
  StackWithAllChildrenReceiveEvents({
    Key key,
    AlignmentDirectional alignment = AlignmentDirectional.topStart,
    TextDirection textDirection = TextDirection.ltr,
    StackFit fit = StackFit.loose,
    List<Widget> children = const <Widget>[],
  }) : super(
          key: key,
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
          children: children,
        );

  @override
  RenderStackWithAllChildrenReceiveEvents createRenderObject(
      BuildContext context) {
    return RenderStackWithAllChildrenReceiveEvents(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      RenderStackWithAllChildrenReceiveEvents renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..fit = fit;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<StackFit>('fit', fit));
  }
}

class RenderStackWithAllChildrenReceiveEvents extends RenderStack {
  RenderStackWithAllChildrenReceiveEvents({
    List<RenderBox> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection textDirection,
    StackFit fit = StackFit.loose,
  }) : super(
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
        );

  bool allCdefaultHitTestChildren(HitTestResult result, {Offset position}) {
    // the x, y parameters have the top left of the node's box as the origin
    RenderBox child = lastChild;
    while (child != null) {
      final StackParentData childParentData = child.parentData;
      child.hitTest(result, position: position - childParentData.offset);
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return allCdefaultHitTestChildren(result, position: position);
  }
}
