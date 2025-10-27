/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The reason to use this is to make [HitTestBehavior.translucent]
/// work with stack, see https://github.com/flutter/flutter/issues/75099
///
/// This was taken from https://github.com/flutter/flutter/issues/18450#issuecomment-575447316
class StackWithAllChildrenReceiveEvents extends Stack {
  StackWithAllChildrenReceiveEvents({
    Key? key,
    AlignmentDirectional alignment = AlignmentDirectional.topStart,
    TextDirection textDirection = TextDirection.ltr,
    StackFit fit = StackFit.loose,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, alignment: alignment, textDirection: textDirection, fit: fit, children: children);

  @override
  _RenderStackWithAllChildrenReceiveEvents createRenderObject(BuildContext context) {
    return _RenderStackWithAllChildrenReceiveEvents(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderStackWithAllChildrenReceiveEvents renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..fit = fit;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(EnumProperty<StackFit>('fit', fit));
  }
}

class _RenderStackWithAllChildrenReceiveEvents extends RenderStack {
  _RenderStackWithAllChildrenReceiveEvents({
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
  }) : super(alignment: alignment, textDirection: textDirection, fit: fit);

  bool allCdefaultHitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final StackParentData childParentData = child.parentData! as StackParentData;
      child.hitTest(result, position: position - childParentData.offset);
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return allCdefaultHitTestChildren(result, position: position);
  }
}
