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
}
