
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
  "retired_date": null,
};

final DateTime bdayDue = DateTime.utc(2020, 8, 2, 17, 30, 0);
final DateTime bdayAdded = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);

final Map<String, dynamic> birthdayJSON = {
  "id": 26,
  "person_id": 1,
  "name": "Hunter Birthday",
  "description": null,
  "project": "Friends",
  "context": "Planning",
  "urgency": 6,
  "priority": 7,
  "duration": 35,
  "start_date": null,
  "target_date": null,
  "due_date": bdayDue.toIso8601String(),
  "completion_date": null,
  "urgent_date": null,
  "game_points": 15,
  "recur_number": null,
  "recur_unit": null,
  "recur_wait": null,
  "recurrence_id": null,
  "date_added": bdayAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
};