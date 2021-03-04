/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: maybe PR this to marquee package

// @dart = 2.12

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class NFMarquee extends StatelessWidget {
  const NFMarquee({
    Key? key,
    required this.text,
    required this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.velocity = 30.0,
    this.blankSpace = 65.0,
    this.startAfter = const Duration(milliseconds: 2000),
    this.pauseAfterRound = const Duration(milliseconds: 2000),
  }) : super(key: key);

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double velocity;
  final double blankSpace;
  final Duration startAfter;
  final Duration pauseAfterRound;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return SizedBox(
      height: (fontSize + 13.0) * textScaleFactor,
      child: AutoSizeText(
        text,
        minFontSize: fontSize,
        maxFontSize: fontSize,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight:fontWeight,
        ),
        overflowReplacement: Marquee(
          text: text,
          blankSpace: blankSpace,
          accelerationCurve: Curves.easeOutCubic,
          velocity: velocity,
          startPadding: 2.0,
          startAfter: startAfter,
          pauseAfterRound: pauseAfterRound,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}