import 'package:flutter_test/flutter_test.dart';

class IsApproximately extends CustomMatcher {
  Object? valueOrMatcher;

  IsApproximately(Object? valueOrMatcher): super(
      'a date which is close to',
      'DateTime field',
      valueOrMatcher
  ) {
    this.valueOrMatcher = valueOrMatcher;
  }

  @override
  bool matches(Object? item, Map matchState) {
    DateTime? expected = valueOrMatcher as DateTime?;
    DateTime? actual = item as DateTime?;
    if (expected != null && actual != null) {
      var difference = expected.difference(actual);
      return difference.abs().inMilliseconds < 1000;
    }
    return false;
  }
}

Matcher isApproximately(Object? valueOrMatcher) => IsApproximately(valueOrMatcher);