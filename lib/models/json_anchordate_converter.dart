import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/anchor_date.dart';

class JsonAnchorDateConverter implements JsonConverter<AnchorDate, Map<String, dynamic>> {
  const JsonAnchorDateConverter();

  @override
  AnchorDate fromJson(Map<String, dynamic> json) {
    return AnchorDate.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(AnchorDate object) {
    return object.toJson();
  }

}