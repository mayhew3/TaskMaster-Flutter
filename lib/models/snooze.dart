import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'snooze.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class Snooze {

  int? id;
  DateTime? dateAdded;

  int taskId;
  int snoozeNumber;
  String snoozeUnits;
  String snoozeAnchor;
  DateTime? previousAnchor;
  DateTime newAnchor;

  static List<String> controlledFields = ['id', 'date_added'];

  Snooze({
    required this.taskId,
    required this.snoozeNumber,
    required this.snoozeUnits,
    required this.snoozeAnchor,
    this.previousAnchor,
    required this.newAnchor
  });

  List<String> getControlledFields() {
    return controlledFields;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Snooze.fromJson(Map<String, dynamic> json) => _$SnoozeFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SnoozeToJson(this);
}
