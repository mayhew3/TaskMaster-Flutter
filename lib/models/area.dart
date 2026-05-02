import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';

part 'area.g.dart';

/// User-customizable category/area-of-responsibility tag for tasks (TM-345).
///
/// Replaces the previously hard-coded `project` list with a Firestore-backed
/// per-user collection. Tasks reference the area by its string `name`, not by
/// `docId`, so deleting an area does not orphan tasks tagged with it — they
/// keep displaying the value, the value just no longer appears in the picker.
abstract class Area implements Built<Area, AreaBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Area> get serializer => _$areaSerializer;

  String get docId;

  DateTime get dateAdded;

  String get name;

  /// Lower values sort earlier in the picker / management screen.
  /// User-defined drag-to-reorder writes new values across the whole list.
  int get sortOrder;

  String get personDocId;

  String? get retired;
  DateTime? get retiredDate;

  Area._();

  factory Area([void Function(AreaBuilder) updates]) = _$Area;

  dynamic toJson() {
    return serializers.serializeWith(Area.serializer, this);
  }
}
