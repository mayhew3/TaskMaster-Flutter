library;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/date_pass_through_serializer.dart';
import 'package:taskmaestro/models/family.dart';
import 'package:taskmaestro/models/family_invitation.dart';
import 'package:taskmaestro/models/models.dart';
import 'package:taskmaestro/models/person.dart';
import 'package:taskmaestro/models/snooze.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';
import 'package:taskmaestro/models/task_date_type_serializer.dart';
import 'package:taskmaestro/models/task_item_recur_preview.dart';

import 'anchor_date.dart';

part 'serializers.g.dart';

@SerializersFor([
  AnchorDate,
  Area,
  Family,
  FamilyInvitation,
  Person,
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
  ..add(TaskDateTypeSerializer())
).build();
