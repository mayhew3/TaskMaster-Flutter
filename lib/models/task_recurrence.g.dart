// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<TaskRecurrence> _$taskRecurrenceSerializer =
    new _$TaskRecurrenceSerializer();

class _$TaskRecurrenceSerializer
    implements StructuredSerializer<TaskRecurrence> {
  @override
  final Iterable<Type> types = const [TaskRecurrence, _$TaskRecurrence];
  @override
  final String wireName = 'TaskRecurrence';

  @override
  Iterable<Object?> serialize(Serializers serializers, TaskRecurrence object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'docId',
      serializers.serialize(object.docId,
          specifiedType: const FullType(String)),
      'dateAdded',
      serializers.serialize(object.dateAdded,
          specifiedType: const FullType(DateTime)),
      'personDocId',
      serializers.serialize(object.personDocId,
          specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'recurNumber',
      serializers.serialize(object.recurNumber,
          specifiedType: const FullType(int)),
      'recurUnit',
      serializers.serialize(object.recurUnit,
          specifiedType: const FullType(String)),
      'recurWait',
      serializers.serialize(object.recurWait,
          specifiedType: const FullType(bool)),
      'recurIteration',
      serializers.serialize(object.recurIteration,
          specifiedType: const FullType(int)),
      'anchorDate',
      serializers.serialize(object.anchorDate,
          specifiedType: const FullType(DateTime)),
      'anchorType',
      serializers.serialize(object.anchorType,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.id;

    result
      ..add('id')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));

    return result;
  }

  @override
  TaskRecurrence deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TaskRecurrenceBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'docId':
          result.docId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'dateAdded':
          result.dateAdded = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
        case 'personDocId':
          result.personDocId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'recurNumber':
          result.recurNumber = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'recurUnit':
          result.recurUnit = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'recurWait':
          result.recurWait = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'recurIteration':
          result.recurIteration = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'anchorDate':
          result.anchorDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
        case 'anchorType':
          result.anchorType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$TaskRecurrence extends TaskRecurrence {
  @override
  final int? id;
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String personDocId;
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
      {this.id,
      required this.docId,
      required this.dateAdded,
      required this.personDocId,
      required this.name,
      required this.recurNumber,
      required this.recurUnit,
      required this.recurWait,
      required this.recurIteration,
      required this.anchorDate,
      required this.anchorType})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(docId, r'TaskRecurrence', 'docId');
    BuiltValueNullFieldError.checkNotNull(
        dateAdded, r'TaskRecurrence', 'dateAdded');
    BuiltValueNullFieldError.checkNotNull(
        personDocId, r'TaskRecurrence', 'personDocId');
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
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        personDocId == other.personDocId &&
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
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
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
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('personDocId', personDocId)
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

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

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
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _personDocId = $v.personDocId;
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
            id: id,
            docId: BuiltValueNullFieldError.checkNotNull(
                docId, r'TaskRecurrence', 'docId'),
            dateAdded: BuiltValueNullFieldError.checkNotNull(
                dateAdded, r'TaskRecurrence', 'dateAdded'),
            personDocId: BuiltValueNullFieldError.checkNotNull(
                personDocId, r'TaskRecurrence', 'personDocId'),
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
            anchorType: BuiltValueNullFieldError.checkNotNull(anchorType, r'TaskRecurrence', 'anchorType'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
