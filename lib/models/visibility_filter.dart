import 'package:built_value/built_value.dart';

part 'visibility_filter.g.dart';

abstract class VisibilityFilter implements Built<VisibilityFilter, VisibilityFilterBuilder> {
  bool get showScheduled;
  bool get showCompleted;
  bool get showActiveSprint;

  VisibilityFilter._();
  factory VisibilityFilter([Function(VisibilityFilterBuilder) updates]) = _$VisibilityFilter;

  factory VisibilityFilter.init({
    bool showScheduled = false,
    bool showCompleted = false,
    bool showActiveSprint = false}) => VisibilityFilter((a) => a
    ..showScheduled = showScheduled
    ..showCompleted = showCompleted
    ..showActiveSprint = showActiveSprint
  );
}