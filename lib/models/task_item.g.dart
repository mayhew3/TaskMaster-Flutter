// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskItem extends TaskItem {
  @override
  final int id;
  @override
  final int personId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? project;
  @override
  final String? context;
  @override
  final int? urgency;
  @override
  final int? priority;
  @override
  final int? duration;
  @override
  final int? gamePoints;
  @override
  final DateTime? startDate;
  @override
  final DateTime? targetDate;
  @override
  final DateTime? dueDate;
  @override
  final DateTime? urgentDate;
  @override
  final DateTime? completionDate;
  @override
  final int? recurNumber;
  @override
  final String? recurUnit;
  @override
  final bool? recurWait;
  @override
  final int? recurrenceId;
  @override
  final int? recurIteration;
  @override
  final bool offCycle;

  factory _$TaskItem([void Function(TaskItemBuilder)? updates]) =>
      (new TaskItemBuilder()..update(updates))._build();

  _$TaskItem._(
      {required this.id,
      required this.personId,
      required this.name,
      this.description,
      this.project,
      this.context,
      this.urgency,
      this.priority,
      this.duration,
      this.gamePoints,
      this.startDate,
      this.targetDate,
      this.dueDate,
      this.urgentDate,
      this.completionDate,
      this.recurNumber,
      this.recurUnit,
      this.recurWait,
      this.recurrenceId,
      this.recurIteration,
      required this.offCycle})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'TaskItem', 'id');
    BuiltValueNullFieldError.checkNotNull(personId, r'TaskItem', 'personId');
    BuiltValueNullFieldError.checkNotNull(name, r'TaskItem', 'name');
    BuiltValueNullFieldError.checkNotNull(offCycle, r'TaskItem', 'offCycle');
  }

  @override
  TaskItem rebuild(void Function(TaskItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskItemBuilder toBuilder() => new TaskItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskItem &&
        id == other.id &&
        personId == other.personId &&
        name == other.name &&
        description == other.description &&
        project == other.project &&
        context == other.context &&
        urgency == other.urgency &&
        priority == other.priority &&
        duration == other.duration &&
        gamePoints == other.gamePoints &&
        startDate == other.startDate &&
        targetDate == other.targetDate &&
        dueDate == other.dueDate &&
        urgentDate == other.urgentDate &&
        completionDate == other.completionDate &&
        recurNumber == other.recurNumber &&
        recurUnit == other.recurUnit &&
        recurWait == other.recurWait &&
        recurrenceId == other.recurrenceId &&
        recurIteration == other.recurIteration &&
        offCycle == other.offCycle;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, personId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, project.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jc(_$hash, urgency.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, gamePoints.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, targetDate.hashCode);
    _$hash = $jc(_$hash, dueDate.hashCode);
    _$hash = $jc(_$hash, urgentDate.hashCode);
    _$hash = $jc(_$hash, completionDate.hashCode);
    _$hash = $jc(_$hash, recurNumber.hashCode);
    _$hash = $jc(_$hash, recurUnit.hashCode);
    _$hash = $jc(_$hash, recurWait.hashCode);
    _$hash = $jc(_$hash, recurrenceId.hashCode);
    _$hash = $jc(_$hash, recurIteration.hashCode);
    _$hash = $jc(_$hash, offCycle.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskItem')
          ..add('id', id)
          ..add('personId', personId)
          ..add('name', name)
          ..add('description', description)
          ..add('project', project)
          ..add('context', context)
          ..add('urgency', urgency)
          ..add('priority', priority)
          ..add('duration', duration)
          ..add('gamePoints', gamePoints)
          ..add('startDate', startDate)
          ..add('targetDate', targetDate)
          ..add('dueDate', dueDate)
          ..add('urgentDate', urgentDate)
          ..add('completionDate', completionDate)
          ..add('recurNumber', recurNumber)
          ..add('recurUnit', recurUnit)
          ..add('recurWait', recurWait)
          ..add('recurrenceId', recurrenceId)
          ..add('recurIteration', recurIteration)
          ..add('offCycle', offCycle))
        .toString();
  }
}

class TaskItemBuilder implements Builder<TaskItem, TaskItemBuilder> {
  _$TaskItem? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _personId;
  int? get personId => _$this._personId;
  set personId(int? personId) => _$this._personId = personId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _project;
  String? get project => _$this._project;
  set project(String? project) => _$this._project = project;

  String? _context;
  String? get context => _$this._context;
  set context(String? context) => _$this._context = context;

  int? _urgency;
  int? get urgency => _$this._urgency;
  set urgency(int? urgency) => _$this._urgency = urgency;

  int? _priority;
  int? get priority => _$this._priority;
  set priority(int? priority) => _$this._priority = priority;

  int? _duration;
  int? get duration => _$this._duration;
  set duration(int? duration) => _$this._duration = duration;

  int? _gamePoints;
  int? get gamePoints => _$this._gamePoints;
  set gamePoints(int? gamePoints) => _$this._gamePoints = gamePoints;

  DateTime? _startDate;
  DateTime? get startDate => _$this._startDate;
  set startDate(DateTime? startDate) => _$this._startDate = startDate;

  DateTime? _targetDate;
  DateTime? get targetDate => _$this._targetDate;
  set targetDate(DateTime? targetDate) => _$this._targetDate = targetDate;

  DateTime? _dueDate;
  DateTime? get dueDate => _$this._dueDate;
  set dueDate(DateTime? dueDate) => _$this._dueDate = dueDate;

  DateTime? _urgentDate;
  DateTime? get urgentDate => _$this._urgentDate;
  set urgentDate(DateTime? urgentDate) => _$this._urgentDate = urgentDate;

  DateTime? _completionDate;
  DateTime? get completionDate => _$this._completionDate;
  set completionDate(DateTime? completionDate) =>
      _$this._completionDate = completionDate;

  int? _recurNumber;
  int? get recurNumber => _$this._recurNumber;
  set recurNumber(int? recurNumber) => _$this._recurNumber = recurNumber;

  String? _recurUnit;
  String? get recurUnit => _$this._recurUnit;
  set recurUnit(String? recurUnit) => _$this._recurUnit = recurUnit;

  bool? _recurWait;
  bool? get recurWait => _$this._recurWait;
  set recurWait(bool? recurWait) => _$this._recurWait = recurWait;

  int? _recurrenceId;
  int? get recurrenceId => _$this._recurrenceId;
  set recurrenceId(int? recurrenceId) => _$this._recurrenceId = recurrenceId;

  int? _recurIteration;
  int? get recurIteration => _$this._recurIteration;
  set recurIteration(int? recurIteration) =>
      _$this._recurIteration = recurIteration;

  bool? _offCycle;
  bool? get offCycle => _$this._offCycle;
  set offCycle(bool? offCycle) => _$this._offCycle = offCycle;

  TaskItemBuilder();

  TaskItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _personId = $v.personId;
      _name = $v.name;
      _description = $v.description;
      _project = $v.project;
      _context = $v.context;
      _urgency = $v.urgency;
      _priority = $v.priority;
      _duration = $v.duration;
      _gamePoints = $v.gamePoints;
      _startDate = $v.startDate;
      _targetDate = $v.targetDate;
      _dueDate = $v.dueDate;
      _urgentDate = $v.urgentDate;
      _completionDate = $v.completionDate;
      _recurNumber = $v.recurNumber;
      _recurUnit = $v.recurUnit;
      _recurWait = $v.recurWait;
      _recurrenceId = $v.recurrenceId;
      _recurIteration = $v.recurIteration;
      _offCycle = $v.offCycle;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskItem other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TaskItem;
  }

  @override
  void update(void Function(TaskItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskItem build() => _build();

  _$TaskItem _build() {
    final _$result = _$v ??
        new _$TaskItem._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'TaskItem', 'id'),
            personId: BuiltValueNullFieldError.checkNotNull(
                personId, r'TaskItem', 'personId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TaskItem', 'name'),
            description: description,
            project: project,
            context: context,
            urgency: urgency,
            priority: priority,
            duration: duration,
            gamePoints: gamePoints,
            startDate: startDate,
            targetDate: targetDate,
            dueDate: dueDate,
            urgentDate: urgentDate,
            completionDate: completionDate,
            recurNumber: recurNumber,
            recurUnit: recurUnit,
            recurWait: recurWait,
            recurrenceId: recurrenceId,
            recurIteration: recurIteration,
            offCycle: BuiltValueNullFieldError.checkNotNull(
                offCycle, r'TaskItem', 'offCycle'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItem _$TaskItemFromJson(Map<String, dynamic> json) => TaskItem();

Map<String, dynamic> _$TaskItemToJson(TaskItem instance) => <String, dynamic>{};
