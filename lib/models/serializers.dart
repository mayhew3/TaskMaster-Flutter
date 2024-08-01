library serializers;

import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/models.dart';

part 'serializers.g.dart';

@SerializersFor([
  Sprint,
  TaskItem,
  TaskRecurrence,
])
final Serializers serializers = _$serializers;
