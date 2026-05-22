import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/platform/form_factor.dart';

void main() {
  group('isPhoneFormFactor', () {
    test('typical phone (portrait) is a phone', () {
      expect(isPhoneFormFactor(const Size(390, 844)), isTrue);
    });

    test('typical phone (landscape) is still a phone — shortest side wins',
        () {
      expect(isPhoneFormFactor(const Size(844, 390)), isTrue);
    });

    test('iPad-sized screen is not a phone', () {
      expect(isPhoneFormFactor(const Size(768, 1024)), isFalse);
    });

    test('just below the breakpoint is a phone', () {
      expect(isPhoneFormFactor(const Size(599, 1200)), isTrue);
    });

    test('exactly at the breakpoint is a tablet (exclusive)', () {
      expect(isPhoneFormFactor(const Size(600, 1200)), isFalse);
    });
  });

  group('shouldLockPortrait', () {
    test('native phone locks', () {
      expect(
        shouldLockPortrait(isWeb: false, logicalSize: const Size(390, 844)),
        isTrue,
      );
    });

    test('web phone does not lock (web landscape is intentional)', () {
      expect(
        shouldLockPortrait(isWeb: true, logicalSize: const Size(390, 844)),
        isFalse,
      );
    });

    test('native tablet does not lock', () {
      expect(
        shouldLockPortrait(isWeb: false, logicalSize: const Size(768, 1024)),
        isFalse,
      );
    });

    test('web tablet does not lock', () {
      expect(
        shouldLockPortrait(isWeb: true, logicalSize: const Size(768, 1024)),
        isFalse,
      );
    });
  });

  group('isWideLayout (TM-382)', () {
    test('flutter_test default 800x600 viewport stays compact', () {
      // PRIME DIRECTIVE guard: a 600-width gate would flip every
      // shell/integration test into the sidebar layout.
      expect(isWideLayout(const Size(800, 600)), isFalse);
    });

    test('phone portrait is not wide', () {
      expect(isWideLayout(const Size(599, 1200)), isFalse);
    });

    test('wide-but-short landscape phone is not wide (!isPhoneFormFactor)',
        () {
      // 844 width clears the 840 breakpoint, but shortest side 390 < 600
      // keeps it a phone — must stay compact.
      expect(isWideLayout(const Size(844, 390)), isFalse);
    });

    test('iPad portrait (768 wide) stays compact', () {
      expect(isWideLayout(const Size(768, 1024)), isFalse);
    });

    test('iPad landscape (1024 wide) is wide', () {
      expect(isWideLayout(const Size(1024, 768)), isTrue);
    });

    test('desktop / large web window is wide', () {
      expect(isWideLayout(const Size(1280, 800)), isTrue);
    });

    test('just below the breakpoint is not wide', () {
      expect(isWideLayout(const Size(839, 1200)), isFalse);
    });

    test('exactly at the breakpoint is wide (inclusive)', () {
      expect(isWideLayout(const Size(840, 1200)), isTrue);
    });
  });

  group('isTwoPaneWideLayout (TM-383)', () {
    test('flutter_test default 800x600 viewport is not two-pane', () {
      // PRIME DIRECTIVE guard: the default test viewport must never
      // accidentally land in the two-pane shape.
      expect(isTwoPaneWideLayout(const Size(800, 600)), isFalse);
    });

    test('wide-but-short landscape phone is not two-pane', () {
      // 1300 width clears both wide AND two-pane thresholds, but shortest
      // side 390 < 600 keeps it a phone — must stay compact entirely.
      expect(isTwoPaneWideLayout(const Size(1300, 390)), isFalse);
    });

    test('iPad portrait stays single-pane', () {
      expect(isTwoPaneWideLayout(const Size(768, 1024)), isFalse);
    });

    test('iPad landscape (1024 wide) is wide but not two-pane', () {
      // Below the 1200dp two-pane gate, so even though isWideLayout is
      // true, no right pane should render.
      expect(isWideLayout(const Size(1024, 768)), isTrue);
      expect(isTwoPaneWideLayout(const Size(1024, 768)), isFalse);
    });

    test('1199 wide is wide but not two-pane (boundary − 1)', () {
      expect(isWideLayout(const Size(1199, 800)), isTrue);
      expect(isTwoPaneWideLayout(const Size(1199, 800)), isFalse);
    });

    test('exactly 1200 wide IS two-pane (boundary inclusive)', () {
      expect(isTwoPaneWideLayout(const Size(1200, 800)), isTrue);
    });

    test('typical laptop viewport (1280) is two-pane', () {
      expect(isTwoPaneWideLayout(const Size(1280, 800)), isTrue);
    });

    test('large desktop (1920) is two-pane', () {
      expect(isTwoPaneWideLayout(const Size(1920, 1080)), isTrue);
    });
  });
}
