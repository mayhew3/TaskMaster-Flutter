// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_recur_preview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<TaskItemRecurPreview> _$taskItemRecurPreviewSerializer =
    new _$TaskItemRecurPreviewSerializer();

class _$TaskItemRecurPreviewSerializer
    implements StructuredSerializer<TaskItemRecurPreview> {
  @override
  final Iterable<Type> types = const [
    TaskItemRecurPreview,
    _$TaskItemRecurPreview
  ];
  @override
  final String wireName = 'TaskItemRecurPreview';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, TaskItemRecurPreview object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'offCycle',
      serializers.serialize(object.offCycle,
          specifiedType: const FullType(bool)),
      'sprintAssignments',
      serializers.serialize(object.sprintAssignments,
          specifiedType: const FullType(
              BuiltList, const [const FullType(SprintAssignment)])),
    ];
    Object? value;
    value = object.personDocId;

    result
      ..add('personDocId')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.description;

    result
      ..add('description')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.project;

    result
      ..add('project')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.context;

    result
      ..add('context')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.urgency;

    result
      ..add('urgency')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.priority;

    result
      ..add('priority')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.duration;

    result
      ..add('duration')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.gamePoints;

    result
      ..add('gamePoints')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.startDate;

    result
      ..add('startDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.targetDate;

    result
      ..add('targetDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.dueDate;

    result
      ..add('dueDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.urgentDate;

    result
      ..add('urgentDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.completionDate;

    result
      ..add('completionDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.recurNumber;

    result
      ..add('recurNumber')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.recurUnit;

    result
      ..add('recurUnit')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.recurWait;

    result
      ..add('recurWait')
      ..add(serializers.serialize(value, specifiedType: const FullType(bool)));
    value = object.retired;

    result
      ..add('retired')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.retiredDate;

    result
      ..add('retiredDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.recurrenceDocId;

    result
      ..add('recurrenceDocId')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.recurIteration;

    result
      ..add('recurIteration')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.recurrence;

    result
      ..add('recurrence')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(TaskRecurrence)));

    return result;
  }

  @override
  TaskItemRecurPreview deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TaskItemRecurPreviewBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'personDocId':
          result.personDocId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'project':
          result.project = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'context':
          result.context = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'urgency':
          result.urgency = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'priority':
          result.priority = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'duration':
          result.duration = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'gamePoints':
          result.gamePoints = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'startDate':
          result.startDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'targetDate':
          result.targetDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'dueDate':
          result.dueDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'urgentDate':
          result.urgentDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'completionDate':
          result.completionDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'recurNumber':
          result.recurNumber = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'recurUnit':
          result.recurUnit = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurWait':
          result.recurWait = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'retired':
          result.retired = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'retiredDate':
          result.retiredDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'recurrenceDocId':
          result.recurrenceDocId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurIteration':
          result.recurIteration = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'offCycle':
          result.offCycle = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'sprintAssignments':
          result.sprintAssignments.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(SprintAssignment)]))!
              as BuiltList<Object?>);
          break;
        case 'recurrence':
          result.recurrence.replace(serializers.deserialize(value,
                  specifiedType: const FullType(TaskRecurrence))!
              as TaskRecurrence);
          break;
      }
    }

    return result.build();
  }
}

class _$TaskItemRecurPreview extends TaskItemRecurPreview {
  @override
  final String docId;
  @override
  final String? personDocId;
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
  final String? retired;
  @override
  final DateTime? retiredDate;
  @override
  final String? recurrenceDocId;
  @override
  final int? recurIteration;
  @override
  final bool offCycle;
  @override
  final BuiltList<SprintAssignment> sprintAssignments;
  @override
  final TaskRecurrence? recurrence;

  factory _$TaskItemRecurPreview(
          [void Function(TaskItemRecurPreviewBuilder)? updates]) =>
      (new TaskItemRecurPreviewBuilder()..update(updates))._build();

  _$TaskItemRecurPreview._(
      {required this.docId,
      this.personDocId,
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
      this.retired,
      this.retiredDate,
      this.recurrenceDocId,
      this.recurIteration,
      required this.offCycle,
      required this.sprintAssignments,
      this.recurrence})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        docId, r'TaskItemRecurPreview', 'docId');
    BuiltValueNullFieldError.checkNotNull(
        name, r'TaskItemRecurPreview', 'name');
    BuiltValueNullFieldError.checkNotNull(
        offCycle, r'TaskItemRecurPreview', 'offCycle');
    BuiltValueNullFieldError.checkNotNull(
        sprintAssignments, r'TaskItemRecurPreview', 'sprintAssignments');
  }

  @override
  TaskItemRecurPreview rebuild(
          void Function(TaskItemRecurPreviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskItemRecurPreviewBuilder toBuilder() =>
      new TaskItemRecurPreviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskItemRecurPreview &&
        docId == other.docId &&
        personDocId == other.personDocId &&
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
        retired == other.retired &&
        retiredDate == other.retiredDate &&
        recurrenceDocId == other.recurrenceDocId &&
        recurIteration == other.recurIteration &&
        offCycle == other.offCycle &&
        sprintAssignments == other.sprintAssignments &&
        recurrence == other.recurrence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
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
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jc(_$hash, recurrenceDocId.hashCode);
    _$hash = $jc(_$hash, recurIteration.hashCode);
    _$hash = $jc(_$hash, offCycle.hashCode);
    _$hash = $jc(_$hash, sprintAssignments.hashCode);
    _$hash = $jc(_$hash, recurrence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskItemRecurPreview')
          ..add('docId', docId)
          ..add('personDocId', personDocId)
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
          ..add('retired', retired)
          ..add('retiredDate', retiredDate)
          ..add('recurrenceDocId', recurrenceDocId)
          ..add('recurIteration', recurIteration)
          ..add('offCycle', offCycle)
          ..add('sprintAssignments', sprintAssignments)
          ..add('recurrence', recurrence))
        .toString();
  }
}

class TaskItemRecurPreviewBuilder
    implements Builder<TaskItemRecurPreview, TaskItemRecurPreviewBuilder> {
  _$TaskItemRecurPreview? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

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

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  String? _recurrenceDocId;
  String? get recurrenceDocId => _$this._recurrenceDocId;
  set recurrenceDocId(String? recurrenceDocId) =>
      _$this._recurrenceDocId = recurrenceDocId;

  int? _recurIteration;
  int? get recurIteration => _$this._recurIteration;
  set recurIteration(int? recurIteration) =>
      _$this._recurIteration = recurIteration;

  bool? _offCycle;
  bool? get offCycle => _$this._offCycle;
  set offCycle(bool? offCycle) => _$this._offCycle = offCycle;

  ListBuilder<SprintAssignment>? _sprintAssignments;
  ListBuilder<SprintAssignment> get sprintAssignments =>
      _$this._sprintAssignments ??= new ListBuilder<SprintAssignment>();
  set sprintAssignments(ListBuilder<SprintAssignment>? sprintAssignments) =>
      _$this._sprintAssignments = sprintAssignments;

  TaskRecurrenceBuilder? _recurrence;
  TaskRecurrenceBuilder get recurrence =>
      _$this._recurrence ??= new TaskRecurrenceBuilder();
  set recurrence(TaskRecurrenceBuilder? recurrence) =>
      _$this._recurrence = recurrence;

  TaskItemRecurPreviewBuilder() {
    TaskItemRecurPreview._setDefaults(this);
  }

  TaskItemRecurPreviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _personDocId = $v.personDocId;
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
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
      _recurrenceDocId = $v.recurrenceDocId;
      _recurIteration = $v.recurIteration;
      _offCycle = $v.offCycle;
      _sprintAssignments = $v.sprintAssignments.toBuilder();
      _recurrence = $v.recurrence?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskItemRecurPreview other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TaskItemRecurPreview;
  }

  @override
  void update(void Function(TaskItemRecurPreviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskItemRecurPreview build() => _build();

  _$TaskItemRecurPreview _build() {
    _$TaskItemRecurPreview _$result;
    try {
      _$result = _$v ??
          new _$TaskItemRecurPreview._(
              docId: BuiltValueNullFieldError.checkNotNull(
                  docId, r'TaskItemRecurPreview', 'docId'),
              personDocId: personDocId,
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'TaskItemRecurPreview', 'name'),
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
              retired: retired,
              retiredDate: retiredDate,
              recurrenceDocId: recurrenceDocId,
              recurIteration: recurIteration,
              offCycle: BuiltValueNullFieldError.checkNotNull(
                  offCycle, r'TaskItemRecurPreview', 'offCycle'),
              sprintAssignments: sprintAssignments.build(),
              recurrence: _recurrence?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sprintAssignments';
        sprintAssignments.build();
        _$failedField = 'recurrence';
        _recurrence?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'TaskItemRecurPreview', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
