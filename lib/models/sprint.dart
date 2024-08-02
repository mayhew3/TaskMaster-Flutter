import 'package:built_value/built_value.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'sprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
abstract class Sprint implements Built<Sprint, SprintBuilder> {

  int? get id;

  DateTime? get dateAdded;

  DateTime get startDate;
  DateTime get endDate;

  DateTime? get closeDate;

  int get numUnits;
  String get unitName;

  int get personId;

  int? get sprintNumber;

  Sprint._();

  factory Sprint([void Function(SprintBuilder) updates]) = _$Sprint;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Sprint.fromJson(Map<String, dynamic> json) => _$SprintFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SprintToJson(this);
}
