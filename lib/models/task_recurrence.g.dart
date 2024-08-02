// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskRecurrence extends TaskRecurrence {
  @override
  final int id;
  @override
  final int personId;
  @override
  final String name;
  @override
  final int recurNumber;
  @override
  final String recurUnit;
  @override
  final bool recurWait;
  @override
  final int recurIteration;
  @override
  final DateTime anchorDate;
  @override
  final String anchorType;

  factory _$TaskRecurrence([void Function(TaskRecurrenceBuilder)? updates]) =>
      (new TaskRecurrenceBuilder()..update(updates))._build();

  _$TaskRecurrence._(
      {required this.id,
      required this.personId,
      required this.name,
      required this.recurNumber,
      required this.recurUnit,
      required this.recurWait,
      required this.recurIteration,
      required this.anchorDate,
      required this.anchorType})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'TaskRecurrence', 'id');
    BuiltValueNullFieldError.checkNotNull(
        personId, r'TaskRecurrence', 'personId');
    BuiltValueNullFieldError.checkNotNull(name, r'TaskRecurrence', 'name');
    BuiltValueNullFieldError.checkNotNull(
        recurNumber, r'TaskRecurrence', 'recurNumber');
    BuiltValueNullFieldError.checkNotNull(
        recurUnit, r'TaskRecurrence', 'recurUnit');
    BuiltValueNullFieldError.checkNotNull(
        recurWait, r'TaskRecurrence', 'recurWait');
    BuiltValueNullFieldError.checkNotNull(
        recurIteration, r'TaskRecurrence', 'recurIteration');
    BuiltValueNullFieldError.checkNotNull(
        anchorDate, r'TaskRecurrence', 'anchorDate');
    BuiltValueNullFieldError.checkNotNull(
        anchorType, r'TaskRecurrence', 'anchorType');
  }

  @override
  TaskRecurrence rebuild(void Function(TaskRecurrenceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskRecurrenceBuilder toBuilder() =>
      new TaskRecurrenceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskRecurrence &&
        id == other.id &&
        personId == other.personId &&
        name == other.name &&
        recurNumber == other.recurNumber &&
        recurUnit == other.recurUnit &&
        recurWait == other.recurWait &&
        recurIteration == other.recurIteration &&
        anchorDate == other.anchorDate &&
        anchorType == other.anchorType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, personId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, recurNumber.hashCode);
    _$hash = $jc(_$hash, recurUnit.hashCode);
    _$hash = $jc(_$hash, recurWait.hashCode);
    _$hash = $jc(_$hash, recurIteration.hashCode);
    _$hash = $jc(_$hash, anchorDate.hashCode);
    _$hash = $jc(_$hash, anchorType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskRecurrence')
          ..add('id', id)
          ..add('personId', personId)
          ..add('name', name)
          ..add('recurNumber', recurNumber)
          ..add('recurUnit', recurUnit)
          ..add('recurWait', recurWait)
          ..add('recurIteration', recurIteration)
          ..add('anchorDate', anchorDate)
          ..add('anchorType', anchorType))
        .toString();
  }
}

class TaskRecurrenceBuilder
    implements Builder<TaskRecurrence, TaskRecurrenceBuilder> {
  _$TaskRecurrence? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _personId;
  int? get personId => _$this._personId;
  set personId(int? personId) => _$this._personId = personId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _recurNumber;
  int? get recurNumber => _$this._recurNumber;
  set recurNumber(int? recurNumber) => _$this._recurNumber = recurNumber;

  String? _recurUnit;
  String? get recurUnit => _$this._recurUnit;
  set recurUnit(String? recurUnit) => _$this._recurUnit = recurUnit;

  bool? _recurWait;
  bool? get recurWait => _$this._recurWait;
  set recurWait(bool? recurWait) => _$this._recurWait = recurWait;

  int? _recurIteration;
  int? get recurIteration => _$this._recurIteration;
  set recurIteration(int? recurIteration) =>
      _$this._recurIteration = recurIteration;

  DateTime? _anchorDate;
  DateTime? get anchorDate => _$this._anchorDate;
  set anchorDate(DateTime? anchorDate) => _$this._anchorDate = anchorDate;

  String? _anchorType;
  String? get anchorType => _$this._anchorType;
  set anchorType(String? anchorType) => _$this._anchorType = anchorType;

  TaskRecurrenceBuilder();

  TaskRecurrenceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _personId = $v.personId;
      _name = $v.name;
      _recurNumber = $v.recurNumber;
      _recurUnit = $v.recurUnit;
      _recurWait = $v.recurWait;
      _recurIteration = $v.recurIteration;
      _anchorDate = $v.anchorDate;
      _anchorType = $v.anchorType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskRecurrence other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TaskRecurrence;
  }

  @override
  void update(void Function(TaskRecurrenceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskRecurrence build() => _build();

  _$TaskRecurrence _build() {
    final _$result = _$v ??
        new _$TaskRecurrence._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'TaskRecurrence', 'id'),
            personId: BuiltValueNullFieldError.checkNotNull(
                personId, r'TaskRecurrence', 'personId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TaskRecurrence', 'name'),
            recurNumber: BuiltValueNullFieldError.checkNotNull(
                recurNumber, r'TaskRecurrence', 'recurNumber'),
            recurUnit: BuiltValueNullFieldError.checkNotNull(
                recurUnit, r'TaskRecurrence', 'recurUnit'),
            recurWait: BuiltValueNullFieldError.checkNotNull(
                recurWait, r'TaskRecurrence', 'recurWait'),
            recurIteration: BuiltValueNullFieldError.checkNotNull(
                recurIteration, r'TaskRecurrence', 'recurIteration'),
            anchorDate: BuiltValueNullFieldError.checkNotNull(
                anchorDate, r'TaskRecurrence', 'anchorDate'),
            anchorType: BuiltValueNullFieldError.checkNotNull(
                anchorType, r'TaskRecurrence', 'anchorType'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrence _$TaskRecurrenceFromJson(Map<String, dynamic> json) =>
    TaskRecurrence();

Map<String, dynamic> _$TaskRecurrenceToJson(TaskRecurrence instance) =>
    <String, dynamic>{};
