import 'dart:ui';

/// Shortest-side breakpoint (logical pixels) separating phones from
/// tablets. 600dp is the standard Material/Flutter tablet threshold and
/// classifies small tablets (e.g. iPad Mini) as tablets — unlike Apple's
/// Info.plist iPhone/`~ipad` device bucket, which is why TM-371 uses this
/// single cross-platform Dart check instead of editing native files.
const double kPhoneShortestSideBreakpoint = 600.0;

/// True when [logicalSize] is a phone-sized screen (shortest side below
/// [kPhoneShortestSideBreakpoint]). Orientation-independent: a phone held
/// in landscape still has a shortest side under the breakpoint.
bool isPhoneFormFactor(Size logicalSize) =>
    logicalSize.shortestSide < kPhoneShortestSideBreakpoint;

/// Whether TM-371's portrait lock should apply: phones only, never on
/// web (web landscape is a deliberate future feature, TM-354), never on
/// tablets.
bool shouldLockPortrait({
  required bool isWeb,
  required Size logicalSize,
}) =>
    !isWeb && isPhoneFormFactor(logicalSize);
