
import 'package:taskmaster/models/snooze.dart';
import 'package:test/test.dart';

void main() {

  test('to json', () async {
    Snooze snooze = new Snooze((s) => s
      ..id = 3
      ..dateAdded = DateTime.now().toUtc()
      ..taskId = 4
      ..snoozeNumber = 1
      ..snoozeUnits = "days"
      ..snoozeAnchor = "Due"
      ..newAnchor = DateTime.utc(2023, 2, 1));

    Map<String, dynamic> json = snooze.toJson();
    expect(json.length, 8);
    expect(json['taskId'], 4);
    expect(json['snoozeNumber'], 1);
    expect(json['snoozeUnits'], "days");
    expect(json['snoozeAnchor'], "Due");
    expect(json['newAnchor'], "2023-02-01T00:00:00.000Z");
  });

  test('from json', () async {
    Map<String, dynamic> json = {
      "id": 2302,
      "dateAdded": "2023-01-01T00:00:00.000Z",
      "taskId": 4,
      "snoozeNumber": 1,
      "snoozeUnits": "days",
      "snoozeAnchor": "Due",
      "newAnchor": "2023-02-01T00:00:00.000Z"
    };

    Snooze snooze = Snooze.fromJson(json);
    expect(snooze.id, 2302);
    expect(snooze.dateAdded, DateTime.utc(2023, 1, 1));
    expect(snooze.taskId, 4);
    expect(snooze.snoozeNumber, 1);
    expect(snooze.snoozeUnits, "days");
    expect(snooze.snoozeAnchor, "Due");
    expect(snooze.newAnchor, DateTime.utc(2023, 2, 1));
  });

}