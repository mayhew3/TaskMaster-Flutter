// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrenceBlueprint _$TaskRecurrenceBlueprintFromJson(
        Map<String, dynamic> json) =>
    TaskRecurrenceBlueprint()
      ..personDocId = json['personDocId'] as String?
      ..name = json['name'] as String?
      ..recurNumber = (json['recurNumber'] as num?)?.toInt()
      ..recurUnit = json['recurUnit'] as String?
      ..recurWait = json['recurWait'] as bool?
      ..recurIteration = (json['recurIteration'] as num?)?.toInt()
      ..anchorDate = json['anchorDate'] == null
          ? null
          : DateTime.parse(json['anchorDate'] as String)
      ..anchorType = json['anchorType'] as String?;

Map<String, dynamic> _$TaskRecurrenceBlueprintToJson(
        TaskRecurrenceBlueprint instance) =>
    <String, dynamic>{
      'personDocId': instance.personDocId,
      'name': instance.name,
      'recurNumber': instance.recurNumber,
      'recurUnit': instance.recurUnit,
      'recurWait': instance.recurWait,
      'recurIteration': instance.recurIteration,
      'anchorDate': instance.anchorDate?.toIso8601String(),
      'anchorType': instance.anchorType,
    };
