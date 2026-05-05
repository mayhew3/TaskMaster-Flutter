
import 'package:flutter/material.dart';

class TaskColors {
  // Brand sources (raw, from logo). Use only for logo / splash / accent.
  static const Color brandBlue = Color(0xFF2C74C5);
  static const Color brandMagenta = Color(0xFFD83AFF);
  static const Color brandMagentaMuted = Color(0xFFC45EE0);

  // Surfaces — post-tweak values (bgDarkness=0.35, cardSaturation=1, cardDarkness=0.08).
  static const Color highlight = brandMagenta;
  static const Color menuColor = Color(0xFF286BB5);
  static const Color cardColor = Color(0xFF286BB5);
  static const Color backgroundColor = Color(0xFF1A4676);
  static const Color bgDeep = Color(0xFF133255);
  static const Color primaryLight = Color.fromRGBO(179, 181, 221, 1.0);

  // Text scale.
  static const Color textPrimary = Color(0xFFF2F4FA);
  static final Color textDim = Colors.white.withValues(alpha: 0.72);
  static final Color textFaint = Colors.white.withValues(alpha: 0.55);
  static final Color hairline = Colors.white.withValues(alpha: 0.08);

  // Pending / sprint / connection — semantic roles unchanged by the redesign.
  static final Color pendingBackground = Color.fromRGBO(178, 158, 67, 0.3);
  static final Color pendingCheckbox = Color.fromRGBO(178, 158, 67, 0.8);
  static final Color sprintColor = Color.fromRGBO(240, 240, 60, 1.0);

  // Date pill tones — fg / bg / border triples from design DATE_TONES.
  // Existing names (startText, scheduledColor, scheduledOutline, scheduledText,
  // targetText/targetColor, urgentText/urgentColor, dueText/dueColor) keep their
  // semantic role; values updated to match the design. New `*Border` tokens
  // surface the pill border colors.
  static const Color startText = Color(0xFFB3B5DD);
  static const Color scheduledText = Color(0xFFB3B5DD);
  static final Color scheduledColor = Color.fromRGBO(120, 130, 200, 0.22);
  static final Color scheduledOutline = Color.fromRGBO(179, 181, 221, 0.4);
  static final Color startBorder = Color.fromRGBO(179, 181, 221, 0.4);

  static const Color targetText = Color(0xFFEFE0A0);
  static final Color targetColor = Color.fromRGBO(140, 130, 50, 0.28);
  static final Color targetBorder = Color.fromRGBO(239, 224, 160, 0.4);

  static const Color urgentText = Color(0xFFF4C8A8);
  static final Color urgentColor = Color.fromRGBO(180, 110, 50, 0.28);
  static final Color urgentBorder = Color.fromRGBO(244, 200, 168, 0.4);

  static const Color dueText = Color(0xFFF4B0B0);
  static final Color dueColor = Color.fromRGBO(180, 60, 80, 0.28);
  static final Color dueBorder = Color.fromRGBO(244, 176, 176, 0.4);

  // Completed / skipped pill — magenta family.
  static const Color completedText = Color(0xFFF4C8F9);
  static final Color completedColor = Color.fromRGBO(216, 58, 255, 0.18);
  static final Color completedBorder = Color.fromRGBO(216, 58, 255, 0.42);

  /// Card surface tint when a task is completed/skipped: 55% card + 45% #6E1F8E
  /// at 92% opacity. Precomputed because Flutter has no runtime color-mix.
  static final Color cardCompletedTint = Color.fromRGBO(72, 73, 163, 0.92);

  static final Color invisible = Color.fromRGBO(0, 0, 0, 0.0);

  static const Color connectionWarning = Color(0xFFE65100);
  static const Color connectionError = Color(0xFFC62828);

  /// Curated 16-color palette for area decoration. The first 10 are the
  /// design's `AREA_COLORS`; the next 6 fill out the wheel so a user with
  /// up to 16 areas can have unique colors when assigned by sortOrder.
  /// Hash-based fallback (for stale/unknown area strings) still lives in
  /// `AreaColorHelper`.
  static const List<Color> areaPalette = [
    Color(0xFFE2A6F0), // pink-violet
    Color(0xFFF0B97A), // orange
    Color(0xFF9DC8F0), // sky blue
    Color(0xFFA0E0B5), // mint green
    Color(0xFFF0D77A), // gold
    Color(0xFFB5C9F0), // periwinkle
    Color(0xFFF09A9A), // coral
    Color(0xFF7AE0C6), // teal
    Color(0xFFD8A0F0), // violet
    Color(0xFFF09AC0), // pink
    Color(0xFFF0E091), // pale yellow
    Color(0xFFA8E091), // lime
    Color(0xFFE0A891), // tan
    Color(0xFFC891E0), // purple
    Color(0xFFE0E091), // chartreuse
    Color(0xFF91D0E0), // dusty cyan
  ];
}
