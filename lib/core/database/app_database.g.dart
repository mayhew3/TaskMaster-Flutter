// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personDocIdMeta = const VerificationMeta(
    'personDocId',
  );
  @override
  late final GeneratedColumn<String> personDocId = GeneratedColumn<String>(
    'person_doc_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectMeta = const VerificationMeta(
    'project',
  );
  @override
  late final GeneratedColumn<String> project = GeneratedColumn<String>(
    'project',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskContextMeta = const VerificationMeta(
    'taskContext',
  );
  @override
  late final GeneratedColumn<String> taskContext = GeneratedColumn<String>(
    'task_context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<int> urgency = GeneratedColumn<int>(
    'urgency',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gamePointsMeta = const VerificationMeta(
    'gamePoints',
  );
  @override
  late final GeneratedColumn<int> gamePoints = GeneratedColumn<int>(
    'game_points',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgentDateMeta = const VerificationMeta(
    'urgentDate',
  );
  @override
  late final GeneratedColumn<DateTime> urgentDate = GeneratedColumn<DateTime>(
    'urgent_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionDateMeta = const VerificationMeta(
    'completionDate',
  );
  @override
  late final GeneratedColumn<DateTime> completionDate =
      GeneratedColumn<DateTime>(
        'completion_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurNumberMeta = const VerificationMeta(
    'recurNumber',
  );
  @override
  late final GeneratedColumn<int> recurNumber = GeneratedColumn<int>(
    'recur_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurUnitMeta = const VerificationMeta(
    'recurUnit',
  );
  @override
  late final GeneratedColumn<String> recurUnit = GeneratedColumn<String>(
    'recur_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurWaitMeta = const VerificationMeta(
    'recurWait',
  );
  @override
  late final GeneratedColumn<bool> recurWait = GeneratedColumn<bool>(
    'recur_wait',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recur_wait" IN (0, 1))',
    ),
  );
  static const VerificationMeta _recurrenceDocIdMeta = const VerificationMeta(
    'recurrenceDocId',
  );
  @override
  late final GeneratedColumn<String> recurrenceDocId = GeneratedColumn<String>(
    'recurrence_doc_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurIterationMeta = const VerificationMeta(
    'recurIteration',
  );
  @override
  late final GeneratedColumn<int> recurIteration = GeneratedColumn<int>(
    'recur_iteration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiredMeta = const VerificationMeta(
    'retired',
  );
  @override
  late final GeneratedColumn<String> retired = GeneratedColumn<String>(
    'retired',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiredDateMeta = const VerificationMeta(
    'retiredDate',
  );
  @override
  late final GeneratedColumn<DateTime> retiredDate = GeneratedColumn<DateTime>(
    'retired_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offCycleMeta = const VerificationMeta(
    'offCycle',
  );
  @override
  late final GeneratedColumn<bool> offCycle = GeneratedColumn<bool>(
    'off_cycle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("off_cycle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    docId,
    dateAdded,
    personDocId,
    name,
    description,
    project,
    taskContext,
    urgency,
    priority,
    duration,
    gamePoints,
    startDate,
    targetDate,
    dueDate,
    urgentDate,
    completionDate,
    recurNumber,
    recurUnit,
    recurWait,
    recurrenceDocId,
    recurIteration,
    retired,
    retiredDate,
    offCycle,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('person_doc_id')) {
      context.handle(
        _personDocIdMeta,
        personDocId.isAcceptableOrUnknown(
          data['person_doc_id']!,
          _personDocIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('project')) {
      context.handle(
        _projectMeta,
        project.isAcceptableOrUnknown(data['project']!, _projectMeta),
      );
    }
    if (data.containsKey('task_context')) {
      context.handle(
        _taskContextMeta,
        taskContext.isAcceptableOrUnknown(
          data['task_context']!,
          _taskContextMeta,
        ),
      );
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('game_points')) {
      context.handle(
        _gamePointsMeta,
        gamePoints.isAcceptableOrUnknown(data['game_points']!, _gamePointsMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('urgent_date')) {
      context.handle(
        _urgentDateMeta,
        urgentDate.isAcceptableOrUnknown(data['urgent_date']!, _urgentDateMeta),
      );
    }
    if (data.containsKey('completion_date')) {
      context.handle(
        _completionDateMeta,
        completionDate.isAcceptableOrUnknown(
          data['completion_date']!,
          _completionDateMeta,
        ),
      );
    }
    if (data.containsKey('recur_number')) {
      context.handle(
        _recurNumberMeta,
        recurNumber.isAcceptableOrUnknown(
          data['recur_number']!,
          _recurNumberMeta,
        ),
      );
    }
    if (data.containsKey('recur_unit')) {
      context.handle(
        _recurUnitMeta,
        recurUnit.isAcceptableOrUnknown(data['recur_unit']!, _recurUnitMeta),
      );
    }
    if (data.containsKey('recur_wait')) {
      context.handle(
        _recurWaitMeta,
        recurWait.isAcceptableOrUnknown(data['recur_wait']!, _recurWaitMeta),
      );
    }
    if (data.containsKey('recurrence_doc_id')) {
      context.handle(
        _recurrenceDocIdMeta,
        recurrenceDocId.isAcceptableOrUnknown(
          data['recurrence_doc_id']!,
          _recurrenceDocIdMeta,
        ),
      );
    }
    if (data.containsKey('recur_iteration')) {
      context.handle(
        _recurIterationMeta,
        recurIteration.isAcceptableOrUnknown(
          data['recur_iteration']!,
          _recurIterationMeta,
        ),
      );
    }
    if (data.containsKey('retired')) {
      context.handle(
        _retiredMeta,
        retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta),
      );
    }
    if (data.containsKey('retired_date')) {
      context.handle(
        _retiredDateMeta,
        retiredDate.isAcceptableOrUnknown(
          data['retired_date']!,
          _retiredDateMeta,
        ),
      );
    }
    if (data.containsKey('off_cycle')) {
      context.handle(
        _offCycleMeta,
        offCycle.isAcceptableOrUnknown(data['off_cycle']!, _offCycleMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {docId};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      personDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_doc_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      project: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project'],
      ),
      taskContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_context'],
      ),
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urgency'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      gamePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_points'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      urgentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}urgent_date'],
      ),
      completionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_date'],
      ),
      recurNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recur_number'],
      ),
      recurUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recur_unit'],
      ),
      recurWait: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recur_wait'],
      ),
      recurrenceDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_doc_id'],
      ),
      recurIteration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recur_iteration'],
      ),
      retired: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retired'],
      ),
      retiredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_date'],
      ),
      offCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}off_cycle'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String docId;
  final DateTime dateAdded;
  final String? personDocId;
  final String name;
  final String? description;
  final String? project;
  final String? taskContext;
  final int? urgency;
  final int? priority;
  final int? duration;
  final int? gamePoints;
  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? dueDate;
  final DateTime? urgentDate;
  final DateTime? completionDate;
  final int? recurNumber;
  final String? recurUnit;
  final bool? recurWait;
  final String? recurrenceDocId;
  final int? recurIteration;
  final String? retired;
  final DateTime? retiredDate;
  final bool offCycle;
  final String syncState;
  const Task({
    required this.docId,
    required this.dateAdded,
    this.personDocId,
    required this.name,
    this.description,
    this.project,
    this.taskContext,
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
    this.recurrenceDocId,
    this.recurIteration,
    this.retired,
    this.retiredDate,
    required this.offCycle,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['doc_id'] = Variable<String>(docId);
    map['date_added'] = Variable<DateTime>(dateAdded);
    if (!nullToAbsent || personDocId != null) {
      map['person_doc_id'] = Variable<String>(personDocId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || project != null) {
      map['project'] = Variable<String>(project);
    }
    if (!nullToAbsent || taskContext != null) {
      map['task_context'] = Variable<String>(taskContext);
    }
    if (!nullToAbsent || urgency != null) {
      map['urgency'] = Variable<int>(urgency);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || gamePoints != null) {
      map['game_points'] = Variable<int>(gamePoints);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || urgentDate != null) {
      map['urgent_date'] = Variable<DateTime>(urgentDate);
    }
    if (!nullToAbsent || completionDate != null) {
      map['completion_date'] = Variable<DateTime>(completionDate);
    }
    if (!nullToAbsent || recurNumber != null) {
      map['recur_number'] = Variable<int>(recurNumber);
    }
    if (!nullToAbsent || recurUnit != null) {
      map['recur_unit'] = Variable<String>(recurUnit);
    }
    if (!nullToAbsent || recurWait != null) {
      map['recur_wait'] = Variable<bool>(recurWait);
    }
    if (!nullToAbsent || recurrenceDocId != null) {
      map['recurrence_doc_id'] = Variable<String>(recurrenceDocId);
    }
    if (!nullToAbsent || recurIteration != null) {
      map['recur_iteration'] = Variable<int>(recurIteration);
    }
    if (!nullToAbsent || retired != null) {
      map['retired'] = Variable<String>(retired);
    }
    if (!nullToAbsent || retiredDate != null) {
      map['retired_date'] = Variable<DateTime>(retiredDate);
    }
    map['off_cycle'] = Variable<bool>(offCycle);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      docId: Value(docId),
      dateAdded: Value(dateAdded),
      personDocId: personDocId == null && nullToAbsent
          ? const Value.absent()
          : Value(personDocId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      project: project == null && nullToAbsent
          ? const Value.absent()
          : Value(project),
      taskContext: taskContext == null && nullToAbsent
          ? const Value.absent()
          : Value(taskContext),
      urgency: urgency == null && nullToAbsent
          ? const Value.absent()
          : Value(urgency),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      gamePoints: gamePoints == null && nullToAbsent
          ? const Value.absent()
          : Value(gamePoints),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      urgentDate: urgentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(urgentDate),
      completionDate: completionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completionDate),
      recurNumber: recurNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(recurNumber),
      recurUnit: recurUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(recurUnit),
      recurWait: recurWait == null && nullToAbsent
          ? const Value.absent()
          : Value(recurWait),
      recurrenceDocId: recurrenceDocId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceDocId),
      recurIteration: recurIteration == null && nullToAbsent
          ? const Value.absent()
          : Value(recurIteration),
      retired: retired == null && nullToAbsent
          ? const Value.absent()
          : Value(retired),
      retiredDate: retiredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredDate),
      offCycle: Value(offCycle),
      syncState: Value(syncState),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      docId: serializer.fromJson<String>(json['docId']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      personDocId: serializer.fromJson<String?>(json['personDocId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      project: serializer.fromJson<String?>(json['project']),
      taskContext: serializer.fromJson<String?>(json['taskContext']),
      urgency: serializer.fromJson<int?>(json['urgency']),
      priority: serializer.fromJson<int?>(json['priority']),
      duration: serializer.fromJson<int?>(json['duration']),
      gamePoints: serializer.fromJson<int?>(json['gamePoints']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      urgentDate: serializer.fromJson<DateTime?>(json['urgentDate']),
      completionDate: serializer.fromJson<DateTime?>(json['completionDate']),
      recurNumber: serializer.fromJson<int?>(json['recurNumber']),
      recurUnit: serializer.fromJson<String?>(json['recurUnit']),
      recurWait: serializer.fromJson<bool?>(json['recurWait']),
      recurrenceDocId: serializer.fromJson<String?>(json['recurrenceDocId']),
      recurIteration: serializer.fromJson<int?>(json['recurIteration']),
      retired: serializer.fromJson<String?>(json['retired']),
      retiredDate: serializer.fromJson<DateTime?>(json['retiredDate']),
      offCycle: serializer.fromJson<bool>(json['offCycle']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'docId': serializer.toJson<String>(docId),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'personDocId': serializer.toJson<String?>(personDocId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'project': serializer.toJson<String?>(project),
      'taskContext': serializer.toJson<String?>(taskContext),
      'urgency': serializer.toJson<int?>(urgency),
      'priority': serializer.toJson<int?>(priority),
      'duration': serializer.toJson<int?>(duration),
      'gamePoints': serializer.toJson<int?>(gamePoints),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'urgentDate': serializer.toJson<DateTime?>(urgentDate),
      'completionDate': serializer.toJson<DateTime?>(completionDate),
      'recurNumber': serializer.toJson<int?>(recurNumber),
      'recurUnit': serializer.toJson<String?>(recurUnit),
      'recurWait': serializer.toJson<bool?>(recurWait),
      'recurrenceDocId': serializer.toJson<String?>(recurrenceDocId),
      'recurIteration': serializer.toJson<int?>(recurIteration),
      'retired': serializer.toJson<String?>(retired),
      'retiredDate': serializer.toJson<DateTime?>(retiredDate),
      'offCycle': serializer.toJson<bool>(offCycle),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  Task copyWith({
    String? docId,
    DateTime? dateAdded,
    Value<String?> personDocId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> project = const Value.absent(),
    Value<String?> taskContext = const Value.absent(),
    Value<int?> urgency = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    Value<int?> gamePoints = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> urgentDate = const Value.absent(),
    Value<DateTime?> completionDate = const Value.absent(),
    Value<int?> recurNumber = const Value.absent(),
    Value<String?> recurUnit = const Value.absent(),
    Value<bool?> recurWait = const Value.absent(),
    Value<String?> recurrenceDocId = const Value.absent(),
    Value<int?> recurIteration = const Value.absent(),
    Value<String?> retired = const Value.absent(),
    Value<DateTime?> retiredDate = const Value.absent(),
    bool? offCycle,
    String? syncState,
  }) => Task(
    docId: docId ?? this.docId,
    dateAdded: dateAdded ?? this.dateAdded,
    personDocId: personDocId.present ? personDocId.value : this.personDocId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    project: project.present ? project.value : this.project,
    taskContext: taskContext.present ? taskContext.value : this.taskContext,
    urgency: urgency.present ? urgency.value : this.urgency,
    priority: priority.present ? priority.value : this.priority,
    duration: duration.present ? duration.value : this.duration,
    gamePoints: gamePoints.present ? gamePoints.value : this.gamePoints,
    startDate: startDate.present ? startDate.value : this.startDate,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    urgentDate: urgentDate.present ? urgentDate.value : this.urgentDate,
    completionDate: completionDate.present
        ? completionDate.value
        : this.completionDate,
    recurNumber: recurNumber.present ? recurNumber.value : this.recurNumber,
    recurUnit: recurUnit.present ? recurUnit.value : this.recurUnit,
    recurWait: recurWait.present ? recurWait.value : this.recurWait,
    recurrenceDocId: recurrenceDocId.present
        ? recurrenceDocId.value
        : this.recurrenceDocId,
    recurIteration: recurIteration.present
        ? recurIteration.value
        : this.recurIteration,
    retired: retired.present ? retired.value : this.retired,
    retiredDate: retiredDate.present ? retiredDate.value : this.retiredDate,
    offCycle: offCycle ?? this.offCycle,
    syncState: syncState ?? this.syncState,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      docId: data.docId.present ? data.docId.value : this.docId,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      personDocId: data.personDocId.present
          ? data.personDocId.value
          : this.personDocId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      project: data.project.present ? data.project.value : this.project,
      taskContext: data.taskContext.present
          ? data.taskContext.value
          : this.taskContext,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      priority: data.priority.present ? data.priority.value : this.priority,
      duration: data.duration.present ? data.duration.value : this.duration,
      gamePoints: data.gamePoints.present
          ? data.gamePoints.value
          : this.gamePoints,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      urgentDate: data.urgentDate.present
          ? data.urgentDate.value
          : this.urgentDate,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
      recurNumber: data.recurNumber.present
          ? data.recurNumber.value
          : this.recurNumber,
      recurUnit: data.recurUnit.present ? data.recurUnit.value : this.recurUnit,
      recurWait: data.recurWait.present ? data.recurWait.value : this.recurWait,
      recurrenceDocId: data.recurrenceDocId.present
          ? data.recurrenceDocId.value
          : this.recurrenceDocId,
      recurIteration: data.recurIteration.present
          ? data.recurIteration.value
          : this.recurIteration,
      retired: data.retired.present ? data.retired.value : this.retired,
      retiredDate: data.retiredDate.present
          ? data.retiredDate.value
          : this.retiredDate,
      offCycle: data.offCycle.present ? data.offCycle.value : this.offCycle,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('docId: $docId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('personDocId: $personDocId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('project: $project, ')
          ..write('taskContext: $taskContext, ')
          ..write('urgency: $urgency, ')
          ..write('priority: $priority, ')
          ..write('duration: $duration, ')
          ..write('gamePoints: $gamePoints, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('urgentDate: $urgentDate, ')
          ..write('completionDate: $completionDate, ')
          ..write('recurNumber: $recurNumber, ')
          ..write('recurUnit: $recurUnit, ')
          ..write('recurWait: $recurWait, ')
          ..write('recurrenceDocId: $recurrenceDocId, ')
          ..write('recurIteration: $recurIteration, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('offCycle: $offCycle, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    docId,
    dateAdded,
    personDocId,
    name,
    description,
    project,
    taskContext,
    urgency,
    priority,
    duration,
    gamePoints,
    startDate,
    targetDate,
    dueDate,
    urgentDate,
    completionDate,
    recurNumber,
    recurUnit,
    recurWait,
    recurrenceDocId,
    recurIteration,
    retired,
    retiredDate,
    offCycle,
    syncState,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.docId == this.docId &&
          other.dateAdded == this.dateAdded &&
          other.personDocId == this.personDocId &&
          other.name == this.name &&
          other.description == this.description &&
          other.project == this.project &&
          other.taskContext == this.taskContext &&
          other.urgency == this.urgency &&
          other.priority == this.priority &&
          other.duration == this.duration &&
          other.gamePoints == this.gamePoints &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.dueDate == this.dueDate &&
          other.urgentDate == this.urgentDate &&
          other.completionDate == this.completionDate &&
          other.recurNumber == this.recurNumber &&
          other.recurUnit == this.recurUnit &&
          other.recurWait == this.recurWait &&
          other.recurrenceDocId == this.recurrenceDocId &&
          other.recurIteration == this.recurIteration &&
          other.retired == this.retired &&
          other.retiredDate == this.retiredDate &&
          other.offCycle == this.offCycle &&
          other.syncState == this.syncState);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> docId;
  final Value<DateTime> dateAdded;
  final Value<String?> personDocId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> project;
  final Value<String?> taskContext;
  final Value<int?> urgency;
  final Value<int?> priority;
  final Value<int?> duration;
  final Value<int?> gamePoints;
  final Value<DateTime?> startDate;
  final Value<DateTime?> targetDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> urgentDate;
  final Value<DateTime?> completionDate;
  final Value<int?> recurNumber;
  final Value<String?> recurUnit;
  final Value<bool?> recurWait;
  final Value<String?> recurrenceDocId;
  final Value<int?> recurIteration;
  final Value<String?> retired;
  final Value<DateTime?> retiredDate;
  final Value<bool> offCycle;
  final Value<String> syncState;
  final Value<int> rowid;
  const TasksCompanion({
    this.docId = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.personDocId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.project = const Value.absent(),
    this.taskContext = const Value.absent(),
    this.urgency = const Value.absent(),
    this.priority = const Value.absent(),
    this.duration = const Value.absent(),
    this.gamePoints = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.urgentDate = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.recurNumber = const Value.absent(),
    this.recurUnit = const Value.absent(),
    this.recurWait = const Value.absent(),
    this.recurrenceDocId = const Value.absent(),
    this.recurIteration = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.offCycle = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String docId,
    required DateTime dateAdded,
    this.personDocId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.project = const Value.absent(),
    this.taskContext = const Value.absent(),
    this.urgency = const Value.absent(),
    this.priority = const Value.absent(),
    this.duration = const Value.absent(),
    this.gamePoints = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.urgentDate = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.recurNumber = const Value.absent(),
    this.recurUnit = const Value.absent(),
    this.recurWait = const Value.absent(),
    this.recurrenceDocId = const Value.absent(),
    this.recurIteration = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.offCycle = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : docId = Value(docId),
       dateAdded = Value(dateAdded),
       name = Value(name);
  static Insertable<Task> custom({
    Expression<String>? docId,
    Expression<DateTime>? dateAdded,
    Expression<String>? personDocId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? project,
    Expression<String>? taskContext,
    Expression<int>? urgency,
    Expression<int>? priority,
    Expression<int>? duration,
    Expression<int>? gamePoints,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? urgentDate,
    Expression<DateTime>? completionDate,
    Expression<int>? recurNumber,
    Expression<String>? recurUnit,
    Expression<bool>? recurWait,
    Expression<String>? recurrenceDocId,
    Expression<int>? recurIteration,
    Expression<String>? retired,
    Expression<DateTime>? retiredDate,
    Expression<bool>? offCycle,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (docId != null) 'doc_id': docId,
      if (dateAdded != null) 'date_added': dateAdded,
      if (personDocId != null) 'person_doc_id': personDocId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (project != null) 'project': project,
      if (taskContext != null) 'task_context': taskContext,
      if (urgency != null) 'urgency': urgency,
      if (priority != null) 'priority': priority,
      if (duration != null) 'duration': duration,
      if (gamePoints != null) 'game_points': gamePoints,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (dueDate != null) 'due_date': dueDate,
      if (urgentDate != null) 'urgent_date': urgentDate,
      if (completionDate != null) 'completion_date': completionDate,
      if (recurNumber != null) 'recur_number': recurNumber,
      if (recurUnit != null) 'recur_unit': recurUnit,
      if (recurWait != null) 'recur_wait': recurWait,
      if (recurrenceDocId != null) 'recurrence_doc_id': recurrenceDocId,
      if (recurIteration != null) 'recur_iteration': recurIteration,
      if (retired != null) 'retired': retired,
      if (retiredDate != null) 'retired_date': retiredDate,
      if (offCycle != null) 'off_cycle': offCycle,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? docId,
    Value<DateTime>? dateAdded,
    Value<String?>? personDocId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? project,
    Value<String?>? taskContext,
    Value<int?>? urgency,
    Value<int?>? priority,
    Value<int?>? duration,
    Value<int?>? gamePoints,
    Value<DateTime?>? startDate,
    Value<DateTime?>? targetDate,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? urgentDate,
    Value<DateTime?>? completionDate,
    Value<int?>? recurNumber,
    Value<String?>? recurUnit,
    Value<bool?>? recurWait,
    Value<String?>? recurrenceDocId,
    Value<int?>? recurIteration,
    Value<String?>? retired,
    Value<DateTime?>? retiredDate,
    Value<bool>? offCycle,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      docId: docId ?? this.docId,
      dateAdded: dateAdded ?? this.dateAdded,
      personDocId: personDocId ?? this.personDocId,
      name: name ?? this.name,
      description: description ?? this.description,
      project: project ?? this.project,
      taskContext: taskContext ?? this.taskContext,
      urgency: urgency ?? this.urgency,
      priority: priority ?? this.priority,
      duration: duration ?? this.duration,
      gamePoints: gamePoints ?? this.gamePoints,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      dueDate: dueDate ?? this.dueDate,
      urgentDate: urgentDate ?? this.urgentDate,
      completionDate: completionDate ?? this.completionDate,
      recurNumber: recurNumber ?? this.recurNumber,
      recurUnit: recurUnit ?? this.recurUnit,
      recurWait: recurWait ?? this.recurWait,
      recurrenceDocId: recurrenceDocId ?? this.recurrenceDocId,
      recurIteration: recurIteration ?? this.recurIteration,
      retired: retired ?? this.retired,
      retiredDate: retiredDate ?? this.retiredDate,
      offCycle: offCycle ?? this.offCycle,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (personDocId.present) {
      map['person_doc_id'] = Variable<String>(personDocId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (project.present) {
      map['project'] = Variable<String>(project.value);
    }
    if (taskContext.present) {
      map['task_context'] = Variable<String>(taskContext.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<int>(urgency.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (gamePoints.present) {
      map['game_points'] = Variable<int>(gamePoints.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (urgentDate.present) {
      map['urgent_date'] = Variable<DateTime>(urgentDate.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<DateTime>(completionDate.value);
    }
    if (recurNumber.present) {
      map['recur_number'] = Variable<int>(recurNumber.value);
    }
    if (recurUnit.present) {
      map['recur_unit'] = Variable<String>(recurUnit.value);
    }
    if (recurWait.present) {
      map['recur_wait'] = Variable<bool>(recurWait.value);
    }
    if (recurrenceDocId.present) {
      map['recurrence_doc_id'] = Variable<String>(recurrenceDocId.value);
    }
    if (recurIteration.present) {
      map['recur_iteration'] = Variable<int>(recurIteration.value);
    }
    if (retired.present) {
      map['retired'] = Variable<String>(retired.value);
    }
    if (retiredDate.present) {
      map['retired_date'] = Variable<DateTime>(retiredDate.value);
    }
    if (offCycle.present) {
      map['off_cycle'] = Variable<bool>(offCycle.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('docId: $docId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('personDocId: $personDocId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('project: $project, ')
          ..write('taskContext: $taskContext, ')
          ..write('urgency: $urgency, ')
          ..write('priority: $priority, ')
          ..write('duration: $duration, ')
          ..write('gamePoints: $gamePoints, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('urgentDate: $urgentDate, ')
          ..write('completionDate: $completionDate, ')
          ..write('recurNumber: $recurNumber, ')
          ..write('recurUnit: $recurUnit, ')
          ..write('recurWait: $recurWait, ')
          ..write('recurrenceDocId: $recurrenceDocId, ')
          ..write('recurIteration: $recurIteration, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('offCycle: $offCycle, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskRecurrencesTable extends TaskRecurrences
    with TableInfo<$TaskRecurrencesTable, TaskRecurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRecurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personDocIdMeta = const VerificationMeta(
    'personDocId',
  );
  @override
  late final GeneratedColumn<String> personDocId = GeneratedColumn<String>(
    'person_doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurNumberMeta = const VerificationMeta(
    'recurNumber',
  );
  @override
  late final GeneratedColumn<int> recurNumber = GeneratedColumn<int>(
    'recur_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurUnitMeta = const VerificationMeta(
    'recurUnit',
  );
  @override
  late final GeneratedColumn<String> recurUnit = GeneratedColumn<String>(
    'recur_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurWaitMeta = const VerificationMeta(
    'recurWait',
  );
  @override
  late final GeneratedColumn<bool> recurWait = GeneratedColumn<bool>(
    'recur_wait',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recur_wait" IN (0, 1))',
    ),
  );
  static const VerificationMeta _recurIterationMeta = const VerificationMeta(
    'recurIteration',
  );
  @override
  late final GeneratedColumn<int> recurIteration = GeneratedColumn<int>(
    'recur_iteration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorDateJsonMeta = const VerificationMeta(
    'anchorDateJson',
  );
  @override
  late final GeneratedColumn<String> anchorDateJson = GeneratedColumn<String>(
    'anchor_date_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiredMeta = const VerificationMeta(
    'retired',
  );
  @override
  late final GeneratedColumn<String> retired = GeneratedColumn<String>(
    'retired',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiredDateMeta = const VerificationMeta(
    'retiredDate',
  );
  @override
  late final GeneratedColumn<DateTime> retiredDate = GeneratedColumn<DateTime>(
    'retired_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    docId,
    dateAdded,
    personDocId,
    name,
    recurNumber,
    recurUnit,
    recurWait,
    recurIteration,
    anchorDateJson,
    retired,
    retiredDate,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_recurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRecurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('person_doc_id')) {
      context.handle(
        _personDocIdMeta,
        personDocId.isAcceptableOrUnknown(
          data['person_doc_id']!,
          _personDocIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personDocIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('recur_number')) {
      context.handle(
        _recurNumberMeta,
        recurNumber.isAcceptableOrUnknown(
          data['recur_number']!,
          _recurNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurNumberMeta);
    }
    if (data.containsKey('recur_unit')) {
      context.handle(
        _recurUnitMeta,
        recurUnit.isAcceptableOrUnknown(data['recur_unit']!, _recurUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_recurUnitMeta);
    }
    if (data.containsKey('recur_wait')) {
      context.handle(
        _recurWaitMeta,
        recurWait.isAcceptableOrUnknown(data['recur_wait']!, _recurWaitMeta),
      );
    } else if (isInserting) {
      context.missing(_recurWaitMeta);
    }
    if (data.containsKey('recur_iteration')) {
      context.handle(
        _recurIterationMeta,
        recurIteration.isAcceptableOrUnknown(
          data['recur_iteration']!,
          _recurIterationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurIterationMeta);
    }
    if (data.containsKey('anchor_date_json')) {
      context.handle(
        _anchorDateJsonMeta,
        anchorDateJson.isAcceptableOrUnknown(
          data['anchor_date_json']!,
          _anchorDateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorDateJsonMeta);
    }
    if (data.containsKey('retired')) {
      context.handle(
        _retiredMeta,
        retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta),
      );
    }
    if (data.containsKey('retired_date')) {
      context.handle(
        _retiredDateMeta,
        retiredDate.isAcceptableOrUnknown(
          data['retired_date']!,
          _retiredDateMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {docId};
  @override
  TaskRecurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRecurrence(
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      personDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_doc_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      recurNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recur_number'],
      )!,
      recurUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recur_unit'],
      )!,
      recurWait: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recur_wait'],
      )!,
      recurIteration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recur_iteration'],
      )!,
      anchorDateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_date_json'],
      )!,
      retired: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retired'],
      ),
      retiredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_date'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $TaskRecurrencesTable createAlias(String alias) {
    return $TaskRecurrencesTable(attachedDatabase, alias);
  }
}

class TaskRecurrence extends DataClass implements Insertable<TaskRecurrence> {
  final String docId;
  final DateTime dateAdded;
  final String personDocId;
  final String name;
  final int recurNumber;
  final String recurUnit;
  final bool recurWait;
  final int recurIteration;
  final String anchorDateJson;
  final String? retired;
  final DateTime? retiredDate;
  final String syncState;
  const TaskRecurrence({
    required this.docId,
    required this.dateAdded,
    required this.personDocId,
    required this.name,
    required this.recurNumber,
    required this.recurUnit,
    required this.recurWait,
    required this.recurIteration,
    required this.anchorDateJson,
    this.retired,
    this.retiredDate,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['doc_id'] = Variable<String>(docId);
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['person_doc_id'] = Variable<String>(personDocId);
    map['name'] = Variable<String>(name);
    map['recur_number'] = Variable<int>(recurNumber);
    map['recur_unit'] = Variable<String>(recurUnit);
    map['recur_wait'] = Variable<bool>(recurWait);
    map['recur_iteration'] = Variable<int>(recurIteration);
    map['anchor_date_json'] = Variable<String>(anchorDateJson);
    if (!nullToAbsent || retired != null) {
      map['retired'] = Variable<String>(retired);
    }
    if (!nullToAbsent || retiredDate != null) {
      map['retired_date'] = Variable<DateTime>(retiredDate);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TaskRecurrencesCompanion toCompanion(bool nullToAbsent) {
    return TaskRecurrencesCompanion(
      docId: Value(docId),
      dateAdded: Value(dateAdded),
      personDocId: Value(personDocId),
      name: Value(name),
      recurNumber: Value(recurNumber),
      recurUnit: Value(recurUnit),
      recurWait: Value(recurWait),
      recurIteration: Value(recurIteration),
      anchorDateJson: Value(anchorDateJson),
      retired: retired == null && nullToAbsent
          ? const Value.absent()
          : Value(retired),
      retiredDate: retiredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredDate),
      syncState: Value(syncState),
    );
  }

  factory TaskRecurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRecurrence(
      docId: serializer.fromJson<String>(json['docId']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      personDocId: serializer.fromJson<String>(json['personDocId']),
      name: serializer.fromJson<String>(json['name']),
      recurNumber: serializer.fromJson<int>(json['recurNumber']),
      recurUnit: serializer.fromJson<String>(json['recurUnit']),
      recurWait: serializer.fromJson<bool>(json['recurWait']),
      recurIteration: serializer.fromJson<int>(json['recurIteration']),
      anchorDateJson: serializer.fromJson<String>(json['anchorDateJson']),
      retired: serializer.fromJson<String?>(json['retired']),
      retiredDate: serializer.fromJson<DateTime?>(json['retiredDate']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'docId': serializer.toJson<String>(docId),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'personDocId': serializer.toJson<String>(personDocId),
      'name': serializer.toJson<String>(name),
      'recurNumber': serializer.toJson<int>(recurNumber),
      'recurUnit': serializer.toJson<String>(recurUnit),
      'recurWait': serializer.toJson<bool>(recurWait),
      'recurIteration': serializer.toJson<int>(recurIteration),
      'anchorDateJson': serializer.toJson<String>(anchorDateJson),
      'retired': serializer.toJson<String?>(retired),
      'retiredDate': serializer.toJson<DateTime?>(retiredDate),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TaskRecurrence copyWith({
    String? docId,
    DateTime? dateAdded,
    String? personDocId,
    String? name,
    int? recurNumber,
    String? recurUnit,
    bool? recurWait,
    int? recurIteration,
    String? anchorDateJson,
    Value<String?> retired = const Value.absent(),
    Value<DateTime?> retiredDate = const Value.absent(),
    String? syncState,
  }) => TaskRecurrence(
    docId: docId ?? this.docId,
    dateAdded: dateAdded ?? this.dateAdded,
    personDocId: personDocId ?? this.personDocId,
    name: name ?? this.name,
    recurNumber: recurNumber ?? this.recurNumber,
    recurUnit: recurUnit ?? this.recurUnit,
    recurWait: recurWait ?? this.recurWait,
    recurIteration: recurIteration ?? this.recurIteration,
    anchorDateJson: anchorDateJson ?? this.anchorDateJson,
    retired: retired.present ? retired.value : this.retired,
    retiredDate: retiredDate.present ? retiredDate.value : this.retiredDate,
    syncState: syncState ?? this.syncState,
  );
  TaskRecurrence copyWithCompanion(TaskRecurrencesCompanion data) {
    return TaskRecurrence(
      docId: data.docId.present ? data.docId.value : this.docId,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      personDocId: data.personDocId.present
          ? data.personDocId.value
          : this.personDocId,
      name: data.name.present ? data.name.value : this.name,
      recurNumber: data.recurNumber.present
          ? data.recurNumber.value
          : this.recurNumber,
      recurUnit: data.recurUnit.present ? data.recurUnit.value : this.recurUnit,
      recurWait: data.recurWait.present ? data.recurWait.value : this.recurWait,
      recurIteration: data.recurIteration.present
          ? data.recurIteration.value
          : this.recurIteration,
      anchorDateJson: data.anchorDateJson.present
          ? data.anchorDateJson.value
          : this.anchorDateJson,
      retired: data.retired.present ? data.retired.value : this.retired,
      retiredDate: data.retiredDate.present
          ? data.retiredDate.value
          : this.retiredDate,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRecurrence(')
          ..write('docId: $docId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('personDocId: $personDocId, ')
          ..write('name: $name, ')
          ..write('recurNumber: $recurNumber, ')
          ..write('recurUnit: $recurUnit, ')
          ..write('recurWait: $recurWait, ')
          ..write('recurIteration: $recurIteration, ')
          ..write('anchorDateJson: $anchorDateJson, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    docId,
    dateAdded,
    personDocId,
    name,
    recurNumber,
    recurUnit,
    recurWait,
    recurIteration,
    anchorDateJson,
    retired,
    retiredDate,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRecurrence &&
          other.docId == this.docId &&
          other.dateAdded == this.dateAdded &&
          other.personDocId == this.personDocId &&
          other.name == this.name &&
          other.recurNumber == this.recurNumber &&
          other.recurUnit == this.recurUnit &&
          other.recurWait == this.recurWait &&
          other.recurIteration == this.recurIteration &&
          other.anchorDateJson == this.anchorDateJson &&
          other.retired == this.retired &&
          other.retiredDate == this.retiredDate &&
          other.syncState == this.syncState);
}

class TaskRecurrencesCompanion extends UpdateCompanion<TaskRecurrence> {
  final Value<String> docId;
  final Value<DateTime> dateAdded;
  final Value<String> personDocId;
  final Value<String> name;
  final Value<int> recurNumber;
  final Value<String> recurUnit;
  final Value<bool> recurWait;
  final Value<int> recurIteration;
  final Value<String> anchorDateJson;
  final Value<String?> retired;
  final Value<DateTime?> retiredDate;
  final Value<String> syncState;
  final Value<int> rowid;
  const TaskRecurrencesCompanion({
    this.docId = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.personDocId = const Value.absent(),
    this.name = const Value.absent(),
    this.recurNumber = const Value.absent(),
    this.recurUnit = const Value.absent(),
    this.recurWait = const Value.absent(),
    this.recurIteration = const Value.absent(),
    this.anchorDateJson = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRecurrencesCompanion.insert({
    required String docId,
    required DateTime dateAdded,
    required String personDocId,
    required String name,
    required int recurNumber,
    required String recurUnit,
    required bool recurWait,
    required int recurIteration,
    required String anchorDateJson,
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : docId = Value(docId),
       dateAdded = Value(dateAdded),
       personDocId = Value(personDocId),
       name = Value(name),
       recurNumber = Value(recurNumber),
       recurUnit = Value(recurUnit),
       recurWait = Value(recurWait),
       recurIteration = Value(recurIteration),
       anchorDateJson = Value(anchorDateJson);
  static Insertable<TaskRecurrence> custom({
    Expression<String>? docId,
    Expression<DateTime>? dateAdded,
    Expression<String>? personDocId,
    Expression<String>? name,
    Expression<int>? recurNumber,
    Expression<String>? recurUnit,
    Expression<bool>? recurWait,
    Expression<int>? recurIteration,
    Expression<String>? anchorDateJson,
    Expression<String>? retired,
    Expression<DateTime>? retiredDate,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (docId != null) 'doc_id': docId,
      if (dateAdded != null) 'date_added': dateAdded,
      if (personDocId != null) 'person_doc_id': personDocId,
      if (name != null) 'name': name,
      if (recurNumber != null) 'recur_number': recurNumber,
      if (recurUnit != null) 'recur_unit': recurUnit,
      if (recurWait != null) 'recur_wait': recurWait,
      if (recurIteration != null) 'recur_iteration': recurIteration,
      if (anchorDateJson != null) 'anchor_date_json': anchorDateJson,
      if (retired != null) 'retired': retired,
      if (retiredDate != null) 'retired_date': retiredDate,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskRecurrencesCompanion copyWith({
    Value<String>? docId,
    Value<DateTime>? dateAdded,
    Value<String>? personDocId,
    Value<String>? name,
    Value<int>? recurNumber,
    Value<String>? recurUnit,
    Value<bool>? recurWait,
    Value<int>? recurIteration,
    Value<String>? anchorDateJson,
    Value<String?>? retired,
    Value<DateTime?>? retiredDate,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return TaskRecurrencesCompanion(
      docId: docId ?? this.docId,
      dateAdded: dateAdded ?? this.dateAdded,
      personDocId: personDocId ?? this.personDocId,
      name: name ?? this.name,
      recurNumber: recurNumber ?? this.recurNumber,
      recurUnit: recurUnit ?? this.recurUnit,
      recurWait: recurWait ?? this.recurWait,
      recurIteration: recurIteration ?? this.recurIteration,
      anchorDateJson: anchorDateJson ?? this.anchorDateJson,
      retired: retired ?? this.retired,
      retiredDate: retiredDate ?? this.retiredDate,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (personDocId.present) {
      map['person_doc_id'] = Variable<String>(personDocId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (recurNumber.present) {
      map['recur_number'] = Variable<int>(recurNumber.value);
    }
    if (recurUnit.present) {
      map['recur_unit'] = Variable<String>(recurUnit.value);
    }
    if (recurWait.present) {
      map['recur_wait'] = Variable<bool>(recurWait.value);
    }
    if (recurIteration.present) {
      map['recur_iteration'] = Variable<int>(recurIteration.value);
    }
    if (anchorDateJson.present) {
      map['anchor_date_json'] = Variable<String>(anchorDateJson.value);
    }
    if (retired.present) {
      map['retired'] = Variable<String>(retired.value);
    }
    if (retiredDate.present) {
      map['retired_date'] = Variable<DateTime>(retiredDate.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskRecurrencesCompanion(')
          ..write('docId: $docId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('personDocId: $personDocId, ')
          ..write('name: $name, ')
          ..write('recurNumber: $recurNumber, ')
          ..write('recurUnit: $recurUnit, ')
          ..write('recurWait: $recurWait, ')
          ..write('recurIteration: $recurIteration, ')
          ..write('anchorDateJson: $anchorDateJson, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SprintsTable extends Sprints with TableInfo<$SprintsTable, Sprint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SprintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closeDateMeta = const VerificationMeta(
    'closeDate',
  );
  @override
  late final GeneratedColumn<DateTime> closeDate = GeneratedColumn<DateTime>(
    'close_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numUnitsMeta = const VerificationMeta(
    'numUnits',
  );
  @override
  late final GeneratedColumn<int> numUnits = GeneratedColumn<int>(
    'num_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personDocIdMeta = const VerificationMeta(
    'personDocId',
  );
  @override
  late final GeneratedColumn<String> personDocId = GeneratedColumn<String>(
    'person_doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sprintNumberMeta = const VerificationMeta(
    'sprintNumber',
  );
  @override
  late final GeneratedColumn<int> sprintNumber = GeneratedColumn<int>(
    'sprint_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiredMeta = const VerificationMeta(
    'retired',
  );
  @override
  late final GeneratedColumn<String> retired = GeneratedColumn<String>(
    'retired',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiredDateMeta = const VerificationMeta(
    'retiredDate',
  );
  @override
  late final GeneratedColumn<DateTime> retiredDate = GeneratedColumn<DateTime>(
    'retired_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    docId,
    dateAdded,
    startDate,
    endDate,
    closeDate,
    numUnits,
    unitName,
    personDocId,
    sprintNumber,
    retired,
    retiredDate,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sprints';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sprint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('close_date')) {
      context.handle(
        _closeDateMeta,
        closeDate.isAcceptableOrUnknown(data['close_date']!, _closeDateMeta),
      );
    }
    if (data.containsKey('num_units')) {
      context.handle(
        _numUnitsMeta,
        numUnits.isAcceptableOrUnknown(data['num_units']!, _numUnitsMeta),
      );
    } else if (isInserting) {
      context.missing(_numUnitsMeta);
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNameMeta);
    }
    if (data.containsKey('person_doc_id')) {
      context.handle(
        _personDocIdMeta,
        personDocId.isAcceptableOrUnknown(
          data['person_doc_id']!,
          _personDocIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personDocIdMeta);
    }
    if (data.containsKey('sprint_number')) {
      context.handle(
        _sprintNumberMeta,
        sprintNumber.isAcceptableOrUnknown(
          data['sprint_number']!,
          _sprintNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sprintNumberMeta);
    }
    if (data.containsKey('retired')) {
      context.handle(
        _retiredMeta,
        retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta),
      );
    }
    if (data.containsKey('retired_date')) {
      context.handle(
        _retiredDateMeta,
        retiredDate.isAcceptableOrUnknown(
          data['retired_date']!,
          _retiredDateMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {docId};
  @override
  Sprint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sprint(
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      closeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}close_date'],
      ),
      numUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}num_units'],
      )!,
      unitName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_name'],
      )!,
      personDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_doc_id'],
      )!,
      sprintNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sprint_number'],
      )!,
      retired: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retired'],
      ),
      retiredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_date'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $SprintsTable createAlias(String alias) {
    return $SprintsTable(attachedDatabase, alias);
  }
}

class Sprint extends DataClass implements Insertable<Sprint> {
  final String docId;
  final DateTime dateAdded;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? closeDate;
  final int numUnits;
  final String unitName;
  final String personDocId;
  final int sprintNumber;
  final String? retired;
  final DateTime? retiredDate;
  final String syncState;
  const Sprint({
    required this.docId,
    required this.dateAdded,
    required this.startDate,
    required this.endDate,
    this.closeDate,
    required this.numUnits,
    required this.unitName,
    required this.personDocId,
    required this.sprintNumber,
    this.retired,
    this.retiredDate,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['doc_id'] = Variable<String>(docId);
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || closeDate != null) {
      map['close_date'] = Variable<DateTime>(closeDate);
    }
    map['num_units'] = Variable<int>(numUnits);
    map['unit_name'] = Variable<String>(unitName);
    map['person_doc_id'] = Variable<String>(personDocId);
    map['sprint_number'] = Variable<int>(sprintNumber);
    if (!nullToAbsent || retired != null) {
      map['retired'] = Variable<String>(retired);
    }
    if (!nullToAbsent || retiredDate != null) {
      map['retired_date'] = Variable<DateTime>(retiredDate);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  SprintsCompanion toCompanion(bool nullToAbsent) {
    return SprintsCompanion(
      docId: Value(docId),
      dateAdded: Value(dateAdded),
      startDate: Value(startDate),
      endDate: Value(endDate),
      closeDate: closeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(closeDate),
      numUnits: Value(numUnits),
      unitName: Value(unitName),
      personDocId: Value(personDocId),
      sprintNumber: Value(sprintNumber),
      retired: retired == null && nullToAbsent
          ? const Value.absent()
          : Value(retired),
      retiredDate: retiredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredDate),
      syncState: Value(syncState),
    );
  }

  factory Sprint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sprint(
      docId: serializer.fromJson<String>(json['docId']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      closeDate: serializer.fromJson<DateTime?>(json['closeDate']),
      numUnits: serializer.fromJson<int>(json['numUnits']),
      unitName: serializer.fromJson<String>(json['unitName']),
      personDocId: serializer.fromJson<String>(json['personDocId']),
      sprintNumber: serializer.fromJson<int>(json['sprintNumber']),
      retired: serializer.fromJson<String?>(json['retired']),
      retiredDate: serializer.fromJson<DateTime?>(json['retiredDate']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'docId': serializer.toJson<String>(docId),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'closeDate': serializer.toJson<DateTime?>(closeDate),
      'numUnits': serializer.toJson<int>(numUnits),
      'unitName': serializer.toJson<String>(unitName),
      'personDocId': serializer.toJson<String>(personDocId),
      'sprintNumber': serializer.toJson<int>(sprintNumber),
      'retired': serializer.toJson<String?>(retired),
      'retiredDate': serializer.toJson<DateTime?>(retiredDate),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  Sprint copyWith({
    String? docId,
    DateTime? dateAdded,
    DateTime? startDate,
    DateTime? endDate,
    Value<DateTime?> closeDate = const Value.absent(),
    int? numUnits,
    String? unitName,
    String? personDocId,
    int? sprintNumber,
    Value<String?> retired = const Value.absent(),
    Value<DateTime?> retiredDate = const Value.absent(),
    String? syncState,
  }) => Sprint(
    docId: docId ?? this.docId,
    dateAdded: dateAdded ?? this.dateAdded,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    closeDate: closeDate.present ? closeDate.value : this.closeDate,
    numUnits: numUnits ?? this.numUnits,
    unitName: unitName ?? this.unitName,
    personDocId: personDocId ?? this.personDocId,
    sprintNumber: sprintNumber ?? this.sprintNumber,
    retired: retired.present ? retired.value : this.retired,
    retiredDate: retiredDate.present ? retiredDate.value : this.retiredDate,
    syncState: syncState ?? this.syncState,
  );
  Sprint copyWithCompanion(SprintsCompanion data) {
    return Sprint(
      docId: data.docId.present ? data.docId.value : this.docId,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      closeDate: data.closeDate.present ? data.closeDate.value : this.closeDate,
      numUnits: data.numUnits.present ? data.numUnits.value : this.numUnits,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      personDocId: data.personDocId.present
          ? data.personDocId.value
          : this.personDocId,
      sprintNumber: data.sprintNumber.present
          ? data.sprintNumber.value
          : this.sprintNumber,
      retired: data.retired.present ? data.retired.value : this.retired,
      retiredDate: data.retiredDate.present
          ? data.retiredDate.value
          : this.retiredDate,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sprint(')
          ..write('docId: $docId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('closeDate: $closeDate, ')
          ..write('numUnits: $numUnits, ')
          ..write('unitName: $unitName, ')
          ..write('personDocId: $personDocId, ')
          ..write('sprintNumber: $sprintNumber, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    docId,
    dateAdded,
    startDate,
    endDate,
    closeDate,
    numUnits,
    unitName,
    personDocId,
    sprintNumber,
    retired,
    retiredDate,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sprint &&
          other.docId == this.docId &&
          other.dateAdded == this.dateAdded &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.closeDate == this.closeDate &&
          other.numUnits == this.numUnits &&
          other.unitName == this.unitName &&
          other.personDocId == this.personDocId &&
          other.sprintNumber == this.sprintNumber &&
          other.retired == this.retired &&
          other.retiredDate == this.retiredDate &&
          other.syncState == this.syncState);
}

class SprintsCompanion extends UpdateCompanion<Sprint> {
  final Value<String> docId;
  final Value<DateTime> dateAdded;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<DateTime?> closeDate;
  final Value<int> numUnits;
  final Value<String> unitName;
  final Value<String> personDocId;
  final Value<int> sprintNumber;
  final Value<String?> retired;
  final Value<DateTime?> retiredDate;
  final Value<String> syncState;
  final Value<int> rowid;
  const SprintsCompanion({
    this.docId = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.numUnits = const Value.absent(),
    this.unitName = const Value.absent(),
    this.personDocId = const Value.absent(),
    this.sprintNumber = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SprintsCompanion.insert({
    required String docId,
    required DateTime dateAdded,
    required DateTime startDate,
    required DateTime endDate,
    this.closeDate = const Value.absent(),
    required int numUnits,
    required String unitName,
    required String personDocId,
    required int sprintNumber,
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : docId = Value(docId),
       dateAdded = Value(dateAdded),
       startDate = Value(startDate),
       endDate = Value(endDate),
       numUnits = Value(numUnits),
       unitName = Value(unitName),
       personDocId = Value(personDocId),
       sprintNumber = Value(sprintNumber);
  static Insertable<Sprint> custom({
    Expression<String>? docId,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? closeDate,
    Expression<int>? numUnits,
    Expression<String>? unitName,
    Expression<String>? personDocId,
    Expression<int>? sprintNumber,
    Expression<String>? retired,
    Expression<DateTime>? retiredDate,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (docId != null) 'doc_id': docId,
      if (dateAdded != null) 'date_added': dateAdded,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (closeDate != null) 'close_date': closeDate,
      if (numUnits != null) 'num_units': numUnits,
      if (unitName != null) 'unit_name': unitName,
      if (personDocId != null) 'person_doc_id': personDocId,
      if (sprintNumber != null) 'sprint_number': sprintNumber,
      if (retired != null) 'retired': retired,
      if (retiredDate != null) 'retired_date': retiredDate,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SprintsCompanion copyWith({
    Value<String>? docId,
    Value<DateTime>? dateAdded,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<DateTime?>? closeDate,
    Value<int>? numUnits,
    Value<String>? unitName,
    Value<String>? personDocId,
    Value<int>? sprintNumber,
    Value<String?>? retired,
    Value<DateTime?>? retiredDate,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return SprintsCompanion(
      docId: docId ?? this.docId,
      dateAdded: dateAdded ?? this.dateAdded,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      closeDate: closeDate ?? this.closeDate,
      numUnits: numUnits ?? this.numUnits,
      unitName: unitName ?? this.unitName,
      personDocId: personDocId ?? this.personDocId,
      sprintNumber: sprintNumber ?? this.sprintNumber,
      retired: retired ?? this.retired,
      retiredDate: retiredDate ?? this.retiredDate,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (closeDate.present) {
      map['close_date'] = Variable<DateTime>(closeDate.value);
    }
    if (numUnits.present) {
      map['num_units'] = Variable<int>(numUnits.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (personDocId.present) {
      map['person_doc_id'] = Variable<String>(personDocId.value);
    }
    if (sprintNumber.present) {
      map['sprint_number'] = Variable<int>(sprintNumber.value);
    }
    if (retired.present) {
      map['retired'] = Variable<String>(retired.value);
    }
    if (retiredDate.present) {
      map['retired_date'] = Variable<DateTime>(retiredDate.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SprintsCompanion(')
          ..write('docId: $docId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('closeDate: $closeDate, ')
          ..write('numUnits: $numUnits, ')
          ..write('unitName: $unitName, ')
          ..write('personDocId: $personDocId, ')
          ..write('sprintNumber: $sprintNumber, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SprintAssignmentsTable extends SprintAssignments
    with TableInfo<$SprintAssignmentsTable, SprintAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SprintAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskDocIdMeta = const VerificationMeta(
    'taskDocId',
  );
  @override
  late final GeneratedColumn<String> taskDocId = GeneratedColumn<String>(
    'task_doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sprintDocIdMeta = const VerificationMeta(
    'sprintDocId',
  );
  @override
  late final GeneratedColumn<String> sprintDocId = GeneratedColumn<String>(
    'sprint_doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiredMeta = const VerificationMeta(
    'retired',
  );
  @override
  late final GeneratedColumn<String> retired = GeneratedColumn<String>(
    'retired',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiredDateMeta = const VerificationMeta(
    'retiredDate',
  );
  @override
  late final GeneratedColumn<DateTime> retiredDate = GeneratedColumn<DateTime>(
    'retired_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    docId,
    taskDocId,
    sprintDocId,
    retired,
    retiredDate,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sprint_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SprintAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('task_doc_id')) {
      context.handle(
        _taskDocIdMeta,
        taskDocId.isAcceptableOrUnknown(data['task_doc_id']!, _taskDocIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskDocIdMeta);
    }
    if (data.containsKey('sprint_doc_id')) {
      context.handle(
        _sprintDocIdMeta,
        sprintDocId.isAcceptableOrUnknown(
          data['sprint_doc_id']!,
          _sprintDocIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sprintDocIdMeta);
    }
    if (data.containsKey('retired')) {
      context.handle(
        _retiredMeta,
        retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta),
      );
    }
    if (data.containsKey('retired_date')) {
      context.handle(
        _retiredDateMeta,
        retiredDate.isAcceptableOrUnknown(
          data['retired_date']!,
          _retiredDateMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {docId};
  @override
  SprintAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SprintAssignment(
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      taskDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_doc_id'],
      )!,
      sprintDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sprint_doc_id'],
      )!,
      retired: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retired'],
      ),
      retiredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_date'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $SprintAssignmentsTable createAlias(String alias) {
    return $SprintAssignmentsTable(attachedDatabase, alias);
  }
}

class SprintAssignment extends DataClass
    implements Insertable<SprintAssignment> {
  final String docId;
  final String taskDocId;
  final String sprintDocId;
  final String? retired;
  final DateTime? retiredDate;
  final String syncState;
  const SprintAssignment({
    required this.docId,
    required this.taskDocId,
    required this.sprintDocId,
    this.retired,
    this.retiredDate,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['doc_id'] = Variable<String>(docId);
    map['task_doc_id'] = Variable<String>(taskDocId);
    map['sprint_doc_id'] = Variable<String>(sprintDocId);
    if (!nullToAbsent || retired != null) {
      map['retired'] = Variable<String>(retired);
    }
    if (!nullToAbsent || retiredDate != null) {
      map['retired_date'] = Variable<DateTime>(retiredDate);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  SprintAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return SprintAssignmentsCompanion(
      docId: Value(docId),
      taskDocId: Value(taskDocId),
      sprintDocId: Value(sprintDocId),
      retired: retired == null && nullToAbsent
          ? const Value.absent()
          : Value(retired),
      retiredDate: retiredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredDate),
      syncState: Value(syncState),
    );
  }

  factory SprintAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SprintAssignment(
      docId: serializer.fromJson<String>(json['docId']),
      taskDocId: serializer.fromJson<String>(json['taskDocId']),
      sprintDocId: serializer.fromJson<String>(json['sprintDocId']),
      retired: serializer.fromJson<String?>(json['retired']),
      retiredDate: serializer.fromJson<DateTime?>(json['retiredDate']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'docId': serializer.toJson<String>(docId),
      'taskDocId': serializer.toJson<String>(taskDocId),
      'sprintDocId': serializer.toJson<String>(sprintDocId),
      'retired': serializer.toJson<String?>(retired),
      'retiredDate': serializer.toJson<DateTime?>(retiredDate),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  SprintAssignment copyWith({
    String? docId,
    String? taskDocId,
    String? sprintDocId,
    Value<String?> retired = const Value.absent(),
    Value<DateTime?> retiredDate = const Value.absent(),
    String? syncState,
  }) => SprintAssignment(
    docId: docId ?? this.docId,
    taskDocId: taskDocId ?? this.taskDocId,
    sprintDocId: sprintDocId ?? this.sprintDocId,
    retired: retired.present ? retired.value : this.retired,
    retiredDate: retiredDate.present ? retiredDate.value : this.retiredDate,
    syncState: syncState ?? this.syncState,
  );
  SprintAssignment copyWithCompanion(SprintAssignmentsCompanion data) {
    return SprintAssignment(
      docId: data.docId.present ? data.docId.value : this.docId,
      taskDocId: data.taskDocId.present ? data.taskDocId.value : this.taskDocId,
      sprintDocId: data.sprintDocId.present
          ? data.sprintDocId.value
          : this.sprintDocId,
      retired: data.retired.present ? data.retired.value : this.retired,
      retiredDate: data.retiredDate.present
          ? data.retiredDate.value
          : this.retiredDate,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SprintAssignment(')
          ..write('docId: $docId, ')
          ..write('taskDocId: $taskDocId, ')
          ..write('sprintDocId: $sprintDocId, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    docId,
    taskDocId,
    sprintDocId,
    retired,
    retiredDate,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SprintAssignment &&
          other.docId == this.docId &&
          other.taskDocId == this.taskDocId &&
          other.sprintDocId == this.sprintDocId &&
          other.retired == this.retired &&
          other.retiredDate == this.retiredDate &&
          other.syncState == this.syncState);
}

class SprintAssignmentsCompanion extends UpdateCompanion<SprintAssignment> {
  final Value<String> docId;
  final Value<String> taskDocId;
  final Value<String> sprintDocId;
  final Value<String?> retired;
  final Value<DateTime?> retiredDate;
  final Value<String> syncState;
  final Value<int> rowid;
  const SprintAssignmentsCompanion({
    this.docId = const Value.absent(),
    this.taskDocId = const Value.absent(),
    this.sprintDocId = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SprintAssignmentsCompanion.insert({
    required String docId,
    required String taskDocId,
    required String sprintDocId,
    this.retired = const Value.absent(),
    this.retiredDate = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : docId = Value(docId),
       taskDocId = Value(taskDocId),
       sprintDocId = Value(sprintDocId);
  static Insertable<SprintAssignment> custom({
    Expression<String>? docId,
    Expression<String>? taskDocId,
    Expression<String>? sprintDocId,
    Expression<String>? retired,
    Expression<DateTime>? retiredDate,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (docId != null) 'doc_id': docId,
      if (taskDocId != null) 'task_doc_id': taskDocId,
      if (sprintDocId != null) 'sprint_doc_id': sprintDocId,
      if (retired != null) 'retired': retired,
      if (retiredDate != null) 'retired_date': retiredDate,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SprintAssignmentsCompanion copyWith({
    Value<String>? docId,
    Value<String>? taskDocId,
    Value<String>? sprintDocId,
    Value<String?>? retired,
    Value<DateTime?>? retiredDate,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return SprintAssignmentsCompanion(
      docId: docId ?? this.docId,
      taskDocId: taskDocId ?? this.taskDocId,
      sprintDocId: sprintDocId ?? this.sprintDocId,
      retired: retired ?? this.retired,
      retiredDate: retiredDate ?? this.retiredDate,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (taskDocId.present) {
      map['task_doc_id'] = Variable<String>(taskDocId.value);
    }
    if (sprintDocId.present) {
      map['sprint_doc_id'] = Variable<String>(sprintDocId.value);
    }
    if (retired.present) {
      map['retired'] = Variable<String>(retired.value);
    }
    if (retiredDate.present) {
      map['retired_date'] = Variable<DateTime>(retiredDate.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SprintAssignmentsCompanion(')
          ..write('docId: $docId, ')
          ..write('taskDocId: $taskDocId, ')
          ..write('sprintDocId: $sprintDocId, ')
          ..write('retired: $retired, ')
          ..write('retiredDate: $retiredDate, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskRecurrencesTable taskRecurrences = $TaskRecurrencesTable(
    this,
  );
  late final $SprintsTable sprints = $SprintsTable(this);
  late final $SprintAssignmentsTable sprintAssignments =
      $SprintAssignmentsTable(this);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final TaskRecurrenceDao taskRecurrenceDao = TaskRecurrenceDao(
    this as AppDatabase,
  );
  late final SprintDao sprintDao = SprintDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    taskRecurrences,
    sprints,
    sprintAssignments,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String docId,
      required DateTime dateAdded,
      Value<String?> personDocId,
      required String name,
      Value<String?> description,
      Value<String?> project,
      Value<String?> taskContext,
      Value<int?> urgency,
      Value<int?> priority,
      Value<int?> duration,
      Value<int?> gamePoints,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<DateTime?> dueDate,
      Value<DateTime?> urgentDate,
      Value<DateTime?> completionDate,
      Value<int?> recurNumber,
      Value<String?> recurUnit,
      Value<bool?> recurWait,
      Value<String?> recurrenceDocId,
      Value<int?> recurIteration,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<bool> offCycle,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> docId,
      Value<DateTime> dateAdded,
      Value<String?> personDocId,
      Value<String> name,
      Value<String?> description,
      Value<String?> project,
      Value<String?> taskContext,
      Value<int?> urgency,
      Value<int?> priority,
      Value<int?> duration,
      Value<int?> gamePoints,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<DateTime?> dueDate,
      Value<DateTime?> urgentDate,
      Value<DateTime?> completionDate,
      Value<int?> recurNumber,
      Value<String?> recurUnit,
      Value<bool?> recurWait,
      Value<String?> recurrenceDocId,
      Value<int?> recurIteration,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<bool> offCycle,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get project => $composableBuilder(
    column: $table.project,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskContext => $composableBuilder(
    column: $table.taskContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamePoints => $composableBuilder(
    column: $table.gamePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get urgentDate => $composableBuilder(
    column: $table.urgentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurNumber => $composableBuilder(
    column: $table.recurNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurUnit => $composableBuilder(
    column: $table.recurUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recurWait => $composableBuilder(
    column: $table.recurWait,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceDocId => $composableBuilder(
    column: $table.recurrenceDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurIteration => $composableBuilder(
    column: $table.recurIteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get offCycle => $composableBuilder(
    column: $table.offCycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get project => $composableBuilder(
    column: $table.project,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskContext => $composableBuilder(
    column: $table.taskContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamePoints => $composableBuilder(
    column: $table.gamePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get urgentDate => $composableBuilder(
    column: $table.urgentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurNumber => $composableBuilder(
    column: $table.recurNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurUnit => $composableBuilder(
    column: $table.recurUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recurWait => $composableBuilder(
    column: $table.recurWait,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceDocId => $composableBuilder(
    column: $table.recurrenceDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurIteration => $composableBuilder(
    column: $table.recurIteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get offCycle => $composableBuilder(
    column: $table.offCycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get docId =>
      $composableBuilder(column: $table.docId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get project =>
      $composableBuilder(column: $table.project, builder: (column) => column);

  GeneratedColumn<String> get taskContext => $composableBuilder(
    column: $table.taskContext,
    builder: (column) => column,
  );

  GeneratedColumn<int> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get gamePoints => $composableBuilder(
    column: $table.gamePoints,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get urgentDate => $composableBuilder(
    column: $table.urgentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurNumber => $composableBuilder(
    column: $table.recurNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurUnit =>
      $composableBuilder(column: $table.recurUnit, builder: (column) => column);

  GeneratedColumn<bool> get recurWait =>
      $composableBuilder(column: $table.recurWait, builder: (column) => column);

  GeneratedColumn<String> get recurrenceDocId => $composableBuilder(
    column: $table.recurrenceDocId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurIteration => $composableBuilder(
    column: $table.recurIteration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get offCycle =>
      $composableBuilder(column: $table.offCycle, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> docId = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<String?> personDocId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> project = const Value.absent(),
                Value<String?> taskContext = const Value.absent(),
                Value<int?> urgency = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int?> gamePoints = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> urgentDate = const Value.absent(),
                Value<DateTime?> completionDate = const Value.absent(),
                Value<int?> recurNumber = const Value.absent(),
                Value<String?> recurUnit = const Value.absent(),
                Value<bool?> recurWait = const Value.absent(),
                Value<String?> recurrenceDocId = const Value.absent(),
                Value<int?> recurIteration = const Value.absent(),
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<bool> offCycle = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                docId: docId,
                dateAdded: dateAdded,
                personDocId: personDocId,
                name: name,
                description: description,
                project: project,
                taskContext: taskContext,
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
                recurrenceDocId: recurrenceDocId,
                recurIteration: recurIteration,
                retired: retired,
                retiredDate: retiredDate,
                offCycle: offCycle,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String docId,
                required DateTime dateAdded,
                Value<String?> personDocId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> project = const Value.absent(),
                Value<String?> taskContext = const Value.absent(),
                Value<int?> urgency = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int?> gamePoints = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> urgentDate = const Value.absent(),
                Value<DateTime?> completionDate = const Value.absent(),
                Value<int?> recurNumber = const Value.absent(),
                Value<String?> recurUnit = const Value.absent(),
                Value<bool?> recurWait = const Value.absent(),
                Value<String?> recurrenceDocId = const Value.absent(),
                Value<int?> recurIteration = const Value.absent(),
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<bool> offCycle = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                docId: docId,
                dateAdded: dateAdded,
                personDocId: personDocId,
                name: name,
                description: description,
                project: project,
                taskContext: taskContext,
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
                recurrenceDocId: recurrenceDocId,
                recurIteration: recurIteration,
                retired: retired,
                retiredDate: retiredDate,
                offCycle: offCycle,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskRecurrencesTableCreateCompanionBuilder =
    TaskRecurrencesCompanion Function({
      required String docId,
      required DateTime dateAdded,
      required String personDocId,
      required String name,
      required int recurNumber,
      required String recurUnit,
      required bool recurWait,
      required int recurIteration,
      required String anchorDateJson,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$TaskRecurrencesTableUpdateCompanionBuilder =
    TaskRecurrencesCompanion Function({
      Value<String> docId,
      Value<DateTime> dateAdded,
      Value<String> personDocId,
      Value<String> name,
      Value<int> recurNumber,
      Value<String> recurUnit,
      Value<bool> recurWait,
      Value<int> recurIteration,
      Value<String> anchorDateJson,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$TaskRecurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskRecurrencesTable> {
  $$TaskRecurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurNumber => $composableBuilder(
    column: $table.recurNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurUnit => $composableBuilder(
    column: $table.recurUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recurWait => $composableBuilder(
    column: $table.recurWait,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurIteration => $composableBuilder(
    column: $table.recurIteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorDateJson => $composableBuilder(
    column: $table.anchorDateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskRecurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskRecurrencesTable> {
  $$TaskRecurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurNumber => $composableBuilder(
    column: $table.recurNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurUnit => $composableBuilder(
    column: $table.recurUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recurWait => $composableBuilder(
    column: $table.recurWait,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurIteration => $composableBuilder(
    column: $table.recurIteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorDateJson => $composableBuilder(
    column: $table.anchorDateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskRecurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskRecurrencesTable> {
  $$TaskRecurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get docId =>
      $composableBuilder(column: $table.docId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get recurNumber => $composableBuilder(
    column: $table.recurNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurUnit =>
      $composableBuilder(column: $table.recurUnit, builder: (column) => column);

  GeneratedColumn<bool> get recurWait =>
      $composableBuilder(column: $table.recurWait, builder: (column) => column);

  GeneratedColumn<int> get recurIteration => $composableBuilder(
    column: $table.recurIteration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorDateJson => $composableBuilder(
    column: $table.anchorDateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$TaskRecurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskRecurrencesTable,
          TaskRecurrence,
          $$TaskRecurrencesTableFilterComposer,
          $$TaskRecurrencesTableOrderingComposer,
          $$TaskRecurrencesTableAnnotationComposer,
          $$TaskRecurrencesTableCreateCompanionBuilder,
          $$TaskRecurrencesTableUpdateCompanionBuilder,
          (
            TaskRecurrence,
            BaseReferences<
              _$AppDatabase,
              $TaskRecurrencesTable,
              TaskRecurrence
            >,
          ),
          TaskRecurrence,
          PrefetchHooks Function()
        > {
  $$TaskRecurrencesTableTableManager(
    _$AppDatabase db,
    $TaskRecurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRecurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRecurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskRecurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> docId = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<String> personDocId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> recurNumber = const Value.absent(),
                Value<String> recurUnit = const Value.absent(),
                Value<bool> recurWait = const Value.absent(),
                Value<int> recurIteration = const Value.absent(),
                Value<String> anchorDateJson = const Value.absent(),
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRecurrencesCompanion(
                docId: docId,
                dateAdded: dateAdded,
                personDocId: personDocId,
                name: name,
                recurNumber: recurNumber,
                recurUnit: recurUnit,
                recurWait: recurWait,
                recurIteration: recurIteration,
                anchorDateJson: anchorDateJson,
                retired: retired,
                retiredDate: retiredDate,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String docId,
                required DateTime dateAdded,
                required String personDocId,
                required String name,
                required int recurNumber,
                required String recurUnit,
                required bool recurWait,
                required int recurIteration,
                required String anchorDateJson,
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRecurrencesCompanion.insert(
                docId: docId,
                dateAdded: dateAdded,
                personDocId: personDocId,
                name: name,
                recurNumber: recurNumber,
                recurUnit: recurUnit,
                recurWait: recurWait,
                recurIteration: recurIteration,
                anchorDateJson: anchorDateJson,
                retired: retired,
                retiredDate: retiredDate,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskRecurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskRecurrencesTable,
      TaskRecurrence,
      $$TaskRecurrencesTableFilterComposer,
      $$TaskRecurrencesTableOrderingComposer,
      $$TaskRecurrencesTableAnnotationComposer,
      $$TaskRecurrencesTableCreateCompanionBuilder,
      $$TaskRecurrencesTableUpdateCompanionBuilder,
      (
        TaskRecurrence,
        BaseReferences<_$AppDatabase, $TaskRecurrencesTable, TaskRecurrence>,
      ),
      TaskRecurrence,
      PrefetchHooks Function()
    >;
typedef $$SprintsTableCreateCompanionBuilder =
    SprintsCompanion Function({
      required String docId,
      required DateTime dateAdded,
      required DateTime startDate,
      required DateTime endDate,
      Value<DateTime?> closeDate,
      required int numUnits,
      required String unitName,
      required String personDocId,
      required int sprintNumber,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$SprintsTableUpdateCompanionBuilder =
    SprintsCompanion Function({
      Value<String> docId,
      Value<DateTime> dateAdded,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<DateTime?> closeDate,
      Value<int> numUnits,
      Value<String> unitName,
      Value<String> personDocId,
      Value<int> sprintNumber,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$SprintsTableFilterComposer
    extends Composer<_$AppDatabase, $SprintsTable> {
  $$SprintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numUnits => $composableBuilder(
    column: $table.numUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sprintNumber => $composableBuilder(
    column: $table.sprintNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SprintsTableOrderingComposer
    extends Composer<_$AppDatabase, $SprintsTable> {
  $$SprintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numUnits => $composableBuilder(
    column: $table.numUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sprintNumber => $composableBuilder(
    column: $table.sprintNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SprintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SprintsTable> {
  $$SprintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get docId =>
      $composableBuilder(column: $table.docId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get closeDate =>
      $composableBuilder(column: $table.closeDate, builder: (column) => column);

  GeneratedColumn<int> get numUnits =>
      $composableBuilder(column: $table.numUnits, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<String> get personDocId => $composableBuilder(
    column: $table.personDocId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sprintNumber => $composableBuilder(
    column: $table.sprintNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$SprintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SprintsTable,
          Sprint,
          $$SprintsTableFilterComposer,
          $$SprintsTableOrderingComposer,
          $$SprintsTableAnnotationComposer,
          $$SprintsTableCreateCompanionBuilder,
          $$SprintsTableUpdateCompanionBuilder,
          (Sprint, BaseReferences<_$AppDatabase, $SprintsTable, Sprint>),
          Sprint,
          PrefetchHooks Function()
        > {
  $$SprintsTableTableManager(_$AppDatabase db, $SprintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SprintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SprintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SprintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> docId = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<DateTime?> closeDate = const Value.absent(),
                Value<int> numUnits = const Value.absent(),
                Value<String> unitName = const Value.absent(),
                Value<String> personDocId = const Value.absent(),
                Value<int> sprintNumber = const Value.absent(),
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SprintsCompanion(
                docId: docId,
                dateAdded: dateAdded,
                startDate: startDate,
                endDate: endDate,
                closeDate: closeDate,
                numUnits: numUnits,
                unitName: unitName,
                personDocId: personDocId,
                sprintNumber: sprintNumber,
                retired: retired,
                retiredDate: retiredDate,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String docId,
                required DateTime dateAdded,
                required DateTime startDate,
                required DateTime endDate,
                Value<DateTime?> closeDate = const Value.absent(),
                required int numUnits,
                required String unitName,
                required String personDocId,
                required int sprintNumber,
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SprintsCompanion.insert(
                docId: docId,
                dateAdded: dateAdded,
                startDate: startDate,
                endDate: endDate,
                closeDate: closeDate,
                numUnits: numUnits,
                unitName: unitName,
                personDocId: personDocId,
                sprintNumber: sprintNumber,
                retired: retired,
                retiredDate: retiredDate,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SprintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SprintsTable,
      Sprint,
      $$SprintsTableFilterComposer,
      $$SprintsTableOrderingComposer,
      $$SprintsTableAnnotationComposer,
      $$SprintsTableCreateCompanionBuilder,
      $$SprintsTableUpdateCompanionBuilder,
      (Sprint, BaseReferences<_$AppDatabase, $SprintsTable, Sprint>),
      Sprint,
      PrefetchHooks Function()
    >;
typedef $$SprintAssignmentsTableCreateCompanionBuilder =
    SprintAssignmentsCompanion Function({
      required String docId,
      required String taskDocId,
      required String sprintDocId,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$SprintAssignmentsTableUpdateCompanionBuilder =
    SprintAssignmentsCompanion Function({
      Value<String> docId,
      Value<String> taskDocId,
      Value<String> sprintDocId,
      Value<String?> retired,
      Value<DateTime?> retiredDate,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$SprintAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SprintAssignmentsTable> {
  $$SprintAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskDocId => $composableBuilder(
    column: $table.taskDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sprintDocId => $composableBuilder(
    column: $table.sprintDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SprintAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SprintAssignmentsTable> {
  $$SprintAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskDocId => $composableBuilder(
    column: $table.taskDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sprintDocId => $composableBuilder(
    column: $table.sprintDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SprintAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SprintAssignmentsTable> {
  $$SprintAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get docId =>
      $composableBuilder(column: $table.docId, builder: (column) => column);

  GeneratedColumn<String> get taskDocId =>
      $composableBuilder(column: $table.taskDocId, builder: (column) => column);

  GeneratedColumn<String> get sprintDocId => $composableBuilder(
    column: $table.sprintDocId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredDate => $composableBuilder(
    column: $table.retiredDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$SprintAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SprintAssignmentsTable,
          SprintAssignment,
          $$SprintAssignmentsTableFilterComposer,
          $$SprintAssignmentsTableOrderingComposer,
          $$SprintAssignmentsTableAnnotationComposer,
          $$SprintAssignmentsTableCreateCompanionBuilder,
          $$SprintAssignmentsTableUpdateCompanionBuilder,
          (
            SprintAssignment,
            BaseReferences<
              _$AppDatabase,
              $SprintAssignmentsTable,
              SprintAssignment
            >,
          ),
          SprintAssignment,
          PrefetchHooks Function()
        > {
  $$SprintAssignmentsTableTableManager(
    _$AppDatabase db,
    $SprintAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SprintAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SprintAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SprintAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> docId = const Value.absent(),
                Value<String> taskDocId = const Value.absent(),
                Value<String> sprintDocId = const Value.absent(),
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SprintAssignmentsCompanion(
                docId: docId,
                taskDocId: taskDocId,
                sprintDocId: sprintDocId,
                retired: retired,
                retiredDate: retiredDate,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String docId,
                required String taskDocId,
                required String sprintDocId,
                Value<String?> retired = const Value.absent(),
                Value<DateTime?> retiredDate = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SprintAssignmentsCompanion.insert(
                docId: docId,
                taskDocId: taskDocId,
                sprintDocId: sprintDocId,
                retired: retired,
                retiredDate: retiredDate,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SprintAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SprintAssignmentsTable,
      SprintAssignment,
      $$SprintAssignmentsTableFilterComposer,
      $$SprintAssignmentsTableOrderingComposer,
      $$SprintAssignmentsTableAnnotationComposer,
      $$SprintAssignmentsTableCreateCompanionBuilder,
      $$SprintAssignmentsTableUpdateCompanionBuilder,
      (
        SprintAssignment,
        BaseReferences<
          _$AppDatabase,
          $SprintAssignmentsTable,
          SprintAssignment
        >,
      ),
      SprintAssignment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskRecurrencesTableTableManager get taskRecurrences =>
      $$TaskRecurrencesTableTableManager(_db, _db.taskRecurrences);
  $$SprintsTableTableManager get sprints =>
      $$SprintsTableTableManager(_db, _db.sprints);
  $$SprintAssignmentsTableTableManager get sprintAssignments =>
      $$SprintAssignmentsTableTableManager(_db, _db.sprintAssignments);
}
