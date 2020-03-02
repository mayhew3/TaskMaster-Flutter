
final DateTime catStart = DateTime.utc(2019, 11, 5, 3, 0, 0);
final DateTime catTarget = DateTime.utc(2019, 11, 7, 3, 0, 0);
final DateTime catEnd = DateTime.utc(2019, 11, 9, 2, 49, 43);
final DateTime catAdded = DateTime.utc(2019, 9, 27, 4, 34, 48, 460);
final DateTime catRetired = DateTime.utc(2019, 10, 18, 3, 14, 47, 666);

final Map<String, dynamic> catLitterJSON = {
  "id": 25,
  "person_id": 1,
  "name": "Cat Litter",
  "description": null,
  "project": "Maintenance",
  "context": "Home",
  "urgency": 4,
  "priority": 6,
  "duration": 12,
  "start_date": null,
  "target_date": catTarget.toIso8601String(),
  "due_date": null,
  "completion_date": catEnd.toIso8601String(),
  "urgent_date": null,
  "game_points": 5,
  "recur_number": 10,
  "recur_unit": "Days",
  "recur_wait": true,
  "recurrence_id": null,
  "date_added": catAdded.toIso8601String(),
  "retired": 0,
  "retired_date": catRetired.toIso8601String(),
};