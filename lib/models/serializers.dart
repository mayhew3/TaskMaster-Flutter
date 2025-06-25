library;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:taskmaster/models/date_pass_through_serializer.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';

import 'anchor_date.dart';

part 'serializers.g.dart';

@SerializersFor([
  AnchorDate,
  Snooze,
  Sprint,
  SprintAssignment,
  TaskItem,
  TaskItemRecurPreview,
  TaskRecurrence,
])
final Serializers serializers = (_$serializers.toBuilder()
  ..addPlugin(StandardJsonPlugin())
  ..add(DatePassThroughSerializer())
).build();
