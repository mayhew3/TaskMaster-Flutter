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

/// Logical-width breakpoint at/above which the wide adaptive shell (left
/// navigation sidebar instead of the bottom NavigationBar) is used. Material
/// 3's "expanded" window class starts at 840dp; we adopt 840 rather than the
/// TM-188 design doc's loose "~600dp" because flutter_test's default viewport
/// is 800x600 logical — a 600 gate would flip every wide-enough widget test
/// into the sidebar layout. 840 keeps phones AND the default test viewport
/// compact while giving web / desktop / large landscape tablets the sidebar.
const double kWideLayoutWidthBreakpoint = 840.0;

/// True when [logicalSize] should render the wide adaptive shell (TM-382).
/// Both conditions are required: it is NOT a phone form factor (so a
/// wide-but-short landscape phone stays on the compact path) AND the logical
/// width is at least [kWideLayoutWidthBreakpoint].
bool isWideLayout(Size logicalSize) =>
    !isPhoneFormFactor(logicalSize) &&
    logicalSize.width >= kWideLayoutWidthBreakpoint;

/// Logical-width breakpoint at/above which the wide adaptive shell adds a
/// third Row cell on the right for the contextual right pane (TM-383
/// Story 2 scaffold; TM-384 editor and TM-385 View-Options panel populate
/// it). Below this width, the layout stays Story-1 shape (sidebar +
/// center column only), even though [isWideLayout] is true.
///
/// Chosen so the center column retains usable width at the minimum
/// two-pane viewport. With the sidebar at TM-382's fixed width and the
/// right pane at [kRightPaneWidth], the center has room left over;
/// it hits its 720dp prototype max comfortably at ~1364dp+.
const double kTwoPaneWideLayoutWidthBreakpoint = 1200.0;

/// Fixed width of the right pane on the wide two-pane shell (TM-383).
/// Lives here so [kTwoPaneWideLayoutWidthBreakpoint]'s rationale stays
/// in sync with the actual layout literal in `riverpod_app.dart`'s
/// `_buildWideShell`.
const double kRightPaneWidth = 380.0;

/// True when [logicalSize] should render the two-pane wide shell (sidebar
/// + center column + right pane). Requires [isWideLayout] AND a logical
/// width of at least [kTwoPaneWideLayoutWidthBreakpoint] (TM-383).
bool isTwoPaneWideLayout(Size logicalSize) =>
    isWideLayout(logicalSize) &&
    logicalSize.width >= kTwoPaneWideLayoutWidthBreakpoint;

/// Whether TM-371's portrait lock should apply: phones only, never on
/// web (web landscape is a deliberate future feature, TM-354), never on
/// tablets.
bool shouldLockPortrait({required bool isWeb, required Size logicalSize}) =>
    !isWeb && isPhoneFormFactor(logicalSize);
