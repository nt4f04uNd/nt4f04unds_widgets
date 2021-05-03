/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Returns the formatted time string in format <M>:<S>.
///
/// * Minutes can go from 0 to 99.
/// * Seconds from 0 to 59.
String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  // Seconds in 0-59 format
  final seconds = duration.inSeconds % 60;
  return '${minutes.toString().length < 2 ? 0 : ''}$minutes:${seconds.toString().length < 2 ? 0 : ''}$seconds';
}
