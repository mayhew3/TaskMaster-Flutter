import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/data_object.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'snooze_serializable.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SnoozeSerializable {

  late int taskID;
  late int snoozeNumber;
  late String snoozeUnits;
  late String snoozeAnchor;
  late DateTime previousAnchor;
  late DateTime newAnchor;

  static List<String> controlledFields = ['id', 'date_added'];

  SnoozeSerializable(): super();

  List<String> getControlledFields() {
    return controlledFields;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory SnoozeSerializable.fromJson(Map<String, dynamic> json) => _$SnoozeSerializableFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SnoozeSerializableToJson(this);
}
