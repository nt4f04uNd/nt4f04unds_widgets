/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: review

// @dart = 2.12

import 'package:flutter/material.dart';

/// Creates a setting item with [title], [description] and [content] sections.
class NFSettingItem extends StatelessWidget {
  const NFSettingItem({
    Key? key,
    required this.title,
    this.description,
    this.trailing,
    this.child,
  })  : assert(title != null),
        super(key: key);

  /// Text displayed as main title of the settings.
  final String title;

  /// Text displayed as the settings description.
  final String? description;

  /// A place for widget to display at the end of title line.
  final Widget? trailing;

  /// A place for a custom widget at the bottom of the item.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              if (trailing != null)
                trailing!
            ],
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                description!,
                style: TextStyle(
                  color: Theme.of(context).textTheme.caption?.color,
                ),
              ),
            ),
          if (child != null)
            child!
        ],
      ),
    );
  }
}

/// A widget that shows or hides a [child] performing an animation.
/// Can be used to make "save" buttons, for example.
///
/// The [child] is untouchable in the animation.
class NFChangedSwitcher extends StatefulWidget {
  NFChangedSwitcher({
    Key? key,
    this.changed = false,
    this.child,
  }) : super(key: key);

  /// When true, the [child] is shown and clickable.
  /// When false, the [child] is hidden and untouchable, but occupies the same space.
  ///
  /// Represents that some setting has been changed.
  final bool changed;

  /// The widget below this widget in the tree.
  final Widget? child;

  @override
  _NFChangedSwitcherState createState() => _NFChangedSwitcherState();
}

class _NFChangedSwitcherState extends State<NFChangedSwitcher> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.changed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        opacity: widget.changed ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(right: widget.changed ? 0.0 : 3.0),
          child: widget.child,
        ),
      ),
    );
  }
}
