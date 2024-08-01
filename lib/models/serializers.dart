library serializers;

import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/sprint.dart';

part 'serializers.g.dart';

@SerializersFor([
  Sprint,
])
final Serializers serializers = _$serializers;
