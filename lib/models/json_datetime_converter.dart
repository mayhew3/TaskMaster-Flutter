import 'package:json_annotation/json_annotation.dart';

class JsonDateTimePassThroughConverter implements JsonConverter<DateTime, DateTime> {
  const JsonDateTimePassThroughConverter();

  @override
  DateTime fromJson(DateTime json) {
    return json;
  }

  @override
  DateTime toJson(DateTime object) {
    return object.toUtc();
  }

}