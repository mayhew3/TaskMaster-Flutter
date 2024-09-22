// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Snooze> _$snoozeSerializer = new _$SnoozeSerializer();

class _$SnoozeSerializer implements StructuredSerializer<Snooze> {
  @override
  final Iterable<Type> types = const [Snooze, _$Snooze];
  @override
  final String wireName = 'Snooze';

  @override
  Iterable<Object?> serialize(Serializers serializers, Snooze object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'dateAdded',
      serializers.serialize(object.dateAdded,
          specifiedType: const FullType(DateTime)),
      'personId',
      serializers.serialize(object.personId,
          specifiedType: const FullType(int)),
      'taskId',
      serializers.serialize(object.taskId, specifiedType: const FullType(int)),
      'snoozeNumber',
      serializers.serialize(object.snoozeNumber,
          specifiedType: const FullType(int)),
      'snoozeUnits',
      serializers.serialize(object.snoozeUnits,
          specifiedType: const FullType(String)),
      'snoozeAnchor',
      serializers.serialize(object.snoozeAnchor,
          specifiedType: const FullType(String)),
      'newAnchor',
      serializers.serialize(object.newAnchor,
          specifiedType: const FullType(DateTime)),
    ];
    Object? value;
    value = object.previousAnchor;

    result
      ..add('previousAnchor')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));

    return result;
  }

  @override
  Snooze deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SnoozeBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'dateAdded':
          result.dateAdded = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
        case 'personId':
          result.personId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'taskId':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'snoozeNumber':
          result.snoozeNumber = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'snoozeUnits':
          result.snoozeUnits = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'snoozeAnchor':
          result.snoozeAnchor = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'previousAnchor':
          result.previousAnchor = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'newAnchor':
          result.newAnchor = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$Snooze extends Snooze {
  @override
  final int id;
  @override
  final DateTime dateAdded;
  @override
  final int personId;
  @override
  final int taskId;
  @override
  final int snoozeNumber;
  @override
  final String snoozeUnits;
  @override
  final String snoozeAnchor;
  @override
  final DateTime? previousAnchor;
  @override
  final DateTime newAnchor;

  factory _$Snooze([void Function(SnoozeBuilder)? updates]) =>
      (new SnoozeBuilder()..update(updates))._build();

  _$Snooze._(
      {required this.id,
      required this.dateAdded,
      required this.personId,
      required this.taskId,
      required this.snoozeNumber,
      required this.snoozeUnits,
      required this.snoozeAnchor,
      this.previousAnchor,
      required this.newAnchor})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'Snooze', 'id');
    BuiltValueNullFieldError.checkNotNull(dateAdded, r'Snooze', 'dateAdded');
    BuiltValueNullFieldError.checkNotNull(personId, r'Snooze', 'personId');
    BuiltValueNullFieldError.checkNotNull(taskId, r'Snooze', 'taskId');
    BuiltValueNullFieldError.checkNotNull(
        snoozeNumber, r'Snooze', 'snoozeNumber');
    BuiltValueNullFieldError.checkNotNull(
        snoozeUnits, r'Snooze', 'snoozeUnits');
    BuiltValueNullFieldError.checkNotNull(
        snoozeAnchor, r'Snooze', 'snoozeAnchor');
    BuiltValueNullFieldError.checkNotNull(newAnchor, r'Snooze', 'newAnchor');
  }

  @override
  Snooze rebuild(void Function(SnoozeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SnoozeBuilder toBuilder() => new SnoozeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Snooze &&
        id == other.id &&
        dateAdded == other.dateAdded &&
        personId == other.personId &&
        taskId == other.taskId &&
        snoozeNumber == other.snoozeNumber &&
        snoozeUnits == other.snoozeUnits &&
        snoozeAnchor == other.snoozeAnchor &&
        previousAnchor == other.previousAnchor &&
        newAnchor == other.newAnchor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, personId.hashCode);
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, snoozeNumber.hashCode);
    _$hash = $jc(_$hash, snoozeUnits.hashCode);
    _$hash = $jc(_$hash, snoozeAnchor.hashCode);
    _$hash = $jc(_$hash, previousAnchor.hashCode);
    _$hash = $jc(_$hash, newAnchor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Snooze')
          ..add('id', id)
          ..add('dateAdded', dateAdded)
          ..add('personId', personId)
          ..add('taskId', taskId)
          ..add('snoozeNumber', snoozeNumber)
          ..add('snoozeUnits', snoozeUnits)
          ..add('snoozeAnchor', snoozeAnchor)
          ..add('previousAnchor', previousAnchor)
          ..add('newAnchor', newAnchor))
        .toString();
  }
}

class SnoozeBuilder implements Builder<Snooze, SnoozeBuilder> {
  _$Snooze? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  int? _personId;
  int? get personId => _$this._personId;
  set personId(int? personId) => _$this._personId = personId;

  int? _taskId;
  int? get taskId => _$this._taskId;
  set taskId(int? taskId) => _$this._taskId = taskId;

  int? _snoozeNumber;
  int? get snoozeNumber => _$this._snoozeNumber;
  set snoozeNumber(int? snoozeNumber) => _$this._snoozeNumber = snoozeNumber;

  String? _snoozeUnits;
  String? get snoozeUnits => _$this._snoozeUnits;
  set snoozeUnits(String? snoozeUnits) => _$this._snoozeUnits = snoozeUnits;

  String? _snoozeAnchor;
  String? get snoozeAnchor => _$this._snoozeAnchor;
  set snoozeAnchor(String? snoozeAnchor) => _$this._snoozeAnchor = snoozeAnchor;

  DateTime? _previousAnchor;
  DateTime? get previousAnchor => _$this._previousAnchor;
  set previousAnchor(DateTime? previousAnchor) =>
      _$this._previousAnchor = previousAnchor;

  DateTime? _newAnchor;
  DateTime? get newAnchor => _$this._newAnchor;
  set newAnchor(DateTime? newAnchor) => _$this._newAnchor = newAnchor;

  SnoozeBuilder();

  SnoozeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _dateAdded = $v.dateAdded;
      _personId = $v.personId;
      _taskId = $v.taskId;
      _snoozeNumber = $v.snoozeNumber;
      _snoozeUnits = $v.snoozeUnits;
      _snoozeAnchor = $v.snoozeAnchor;
      _previousAnchor = $v.previousAnchor;
      _newAnchor = $v.newAnchor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Snooze other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Snooze;
  }

  @override
  void update(void Function(SnoozeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Snooze build() => _build();

  _$Snooze _build() {
    final _$result = _$v ??
        new _$Snooze._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Snooze', 'id'),
            dateAdded: BuiltValueNullFieldError.checkNotNull(
                dateAdded, r'Snooze', 'dateAdded'),
            personId: BuiltValueNullFieldError.checkNotNull(
                personId, r'Snooze', 'personId'),
            taskId: BuiltValueNullFieldError.checkNotNull(
                taskId, r'Snooze', 'taskId'),
            snoozeNumber: BuiltValueNullFieldError.checkNotNull(
                snoozeNumber, r'Snooze', 'snoozeNumber'),
            snoozeUnits: BuiltValueNullFieldError.checkNotNull(
                snoozeUnits, r'Snooze', 'snoozeUnits'),
            snoozeAnchor: BuiltValueNullFieldError.checkNotNull(
                snoozeAnchor, r'Snooze', 'snoozeAnchor'),
            previousAnchor: previousAnchor,
            newAnchor: BuiltValueNullFieldError.checkNotNull(
                newAnchor, r'Snooze', 'newAnchor'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
