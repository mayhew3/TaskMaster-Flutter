
import 'package:taskmaster/models/snooze.dart';
import 'package:test/test.dart';

void main() {

  test('to json', () async {
    Snooze snooze = new Snooze(
        taskId: 4,
        snoozeNumber: 1,
        snoozeUnits: "days",
        snoozeAnchor: "Due",
        newAnchor: DateTime(2023, 2, 1));

    Map<String, dynamic> json = snooze.toJson();
    expect(json.length, 5);
    expect(json['task_id'], 4);
    expect(json['snooze_number'], 1);
    expect(json['snooze_units'], "days");
    expect(json['snooze_anchor'], "Due");
    expect(json['new_anchor'], "2023-02-01T00:00:00.000");
  });

  test('from json', () async {
    Map<String, dynamic> json = {
      "id": 2302,
      "date_added": "2023-01-01T00:00:00.000",
      "task_id": 4,
      "snooze_number": 1,
      "snooze_units": "days",
      "snooze_anchor": "Due",
      "new_anchor": "2023-02-01T00:00:00.000"
    };

    Snooze snooze = Snooze.fromJson(json);
    expect(snooze.id, 2302);
    expect(snooze.dateAdded, DateTime(2023, 1, 1));
    expect(snooze.taskId, 4);
    expect(snooze.snoozeNumber, 1);
    expect(snooze.snoozeUnits, "days");
    expect(snooze.snoozeAnchor, "Due");
    expect(snooze.newAnchor, DateTime(2023, 2, 1));
  });

}