
import 'package:taskmaster/models/snooze_serializable.dart';
import 'package:test/test.dart';

void main() {

  test('to json', () async {
    SnoozeSerializable snoozeSerializable = new SnoozeSerializable();
    snoozeSerializable.taskId = 4;
    snoozeSerializable.previousAnchor = DateTime(2023, 1, 1);

    Map<String, dynamic> json = snoozeSerializable.toJson();
    expect(json.length, 2);
    expect(json['task_id'], 4);
    expect(json['previous_anchor'], "2023-01-01T00:00:00.000");
  });

  test('from json', () async {
    Map<String, dynamic> json = {
      "task_id": 4,
      "previous_anchor": "2023-01-01T00:00:00.000"
    };

    SnoozeSerializable snoozeSerializable = SnoozeSerializable.fromJson(json);
    expect(snoozeSerializable.taskId, 4);
  });

}