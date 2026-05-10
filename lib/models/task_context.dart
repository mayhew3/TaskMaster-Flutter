import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaestro/models/serializers.dart';

part 'task_context.g.dart';

/// One context assignment on a TaskItem (TM-181).
///
/// Tasks carry a `BuiltList<TaskContext>` (zero or more). The picker only
/// surfaces names today; [value] is reserved for Tier 2's numeric-context UI
/// (e.g. "Phone (15)" for a context that's been given a quantity), but it's
/// part of the schema from day one so a list-of-string → list-of-object
/// migration isn't needed later.
abstract class TaskContext implements Built<TaskContext, TaskContextBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskContext> get serializer => _$taskContextSerializer;

  String get name;
  int? get value;

  TaskContext._();

  factory TaskContext([void Function(TaskContextBuilder) updates]) =
      _$TaskContext;

  /// Convenience constructor for the common case of a name-only assignment.
  factory TaskContext.named(String name) =>
      TaskContext((b) => b..name = name);

  dynamic toJson() {
    return serializers.serializeWith(TaskContext.serializer, this);
  }
}
