
import 'package:taskmaster/models/snooze.dart';
import 'package:test/test.dart';

void main() {

  test('to json', () async {
    Snooze snoozeSerializable = new Snooze(
        taskId: 4,
        snoozeNumber: 1,
        snoozeUnits: "days",
        snoozeAnchor: "Due",
        newAnchor: DateTime(2023, 2, 1));

    Map<String, dynamic> json = snoozeSerializable.toJson();
    expect(json.length, 5);
    expect(json['task_id'], 4);
    expect(json['snooze_number'], 1);
    expect(json['snooze_units'], "days");
    expect(json['snooze_anchor'], "Due");
    expect(json['new_anchor'], "2023-02-01T00:00:00.000");
  });

  test('from json', () async {
    Map<String, dynamic> json = {
      "task_id": 4,
      "snooze_number": 1,
      "snooze_units": "days",
      "snooze_anchor": "Due",
      "new_anchor": "2023-02-01T00:00:00.000"
    };

    Snooze snoozeSerializable = Snooze.fromJson(json);
    expect(snoozeSerializable.taskId, 4);
    expect(snoozeSerializable.snoozeNumber, 1);
    expect(snoozeSerializable.snoozeUnits, "days");
    expect(snoozeSerializable.snoozeAnchor, "Due");
    expect(snoozeSerializable.newAnchor, DateTime(2023, 2, 1));
  });

}