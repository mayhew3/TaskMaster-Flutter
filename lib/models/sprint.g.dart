// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sprint _$SprintFromJson(Map<String, dynamic> json) => Sprint(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      closeDate: json['close_date'] == null
          ? null
          : DateTime.parse(json['close_date'] as String),
      numUnits: json['num_units'] as int,
      unitName: json['unit_name'] as String,
      personId: json['person_id'] as int,
    )
      ..id = json['id'] as int?
      ..dateAdded = json['date_added'] == null
          ? null
          : DateTime.parse(json['date_added'] as String);

Map<String, dynamic> _$SprintToJson(Sprint instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('date_added', instance.dateAdded?.toIso8601String());
  val['start_date'] = instance.startDate.toIso8601String();
  val['end_date'] = instance.endDate.toIso8601String();
  writeNotNull('close_date', instance.closeDate?.toIso8601String());
  val['num_units'] = instance.numUnits;
  val['unit_name'] = instance.unitName;
  val['person_id'] = instance.personId;
  return val;
}
