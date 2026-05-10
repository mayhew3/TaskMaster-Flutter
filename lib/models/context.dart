import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaestro/models/serializers.dart';

part 'context.g.dart';

/// User-customizable context (TM-181).
///
/// Contexts tag tasks with where/how they can be performed (e.g. "Phone",
/// "Computer", "Home"). Replaces the previously hard-coded list with a
/// Firestore-backed per-user collection. Tasks reference contexts by string
/// `name`, not by `docId`, so deleting a context does not orphan tasks tagged
/// with it — they keep displaying the value, the value just no longer appears
/// in the picker.
///
/// [iconName] keys into the closed [ContextIcon] set (Tier 1 ships ~14
/// built-in glyphs). [color] is reserved for Tier 2's per-context color UI;
/// it's nullable from day one so no schema migration is needed when that
/// picker lands.
abstract class Context implements Built<Context, ContextBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Context> get serializer => _$contextSerializer;

  String get docId;

  DateTime get dateAdded;

  String get name;

  /// Lower values sort earlier in the picker / management screen.
  /// User-defined drag-to-reorder writes new values across the whole list.
  int get sortOrder;

  /// Canonical lowercase name keying into the closed `ContextIcon` set.
  /// Null means "no icon" (user-created contexts default to null until
  /// the Tier-2 icon picker assigns one).
  String? get iconName;

  /// Hex string (e.g. `#3B82F6`) for the optional accent color. Tier 2's
  /// picker will populate this; Tier 1 leaves it null.
  String? get color;

  String get personDocId;

  String? get retired;
  DateTime? get retiredDate;

  Context._();

  factory Context([void Function(ContextBuilder) updates]) = _$Context;

  dynamic toJson() {
    return serializers.serializeWith(Context.serializer, this);
  }
}
