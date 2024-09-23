// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_assignment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<SprintAssignment> _$sprintAssignmentSerializer =
    new _$SprintAssignmentSerializer();

class _$SprintAssignmentSerializer
    implements StructuredSerializer<SprintAssignment> {
  @override
  final Iterable<Type> types = const [SprintAssignment, _$SprintAssignment];
  @override
  final String wireName = 'SprintAssignment';

  @override
  Iterable<Object?> serialize(Serializers serializers, SprintAssignment object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'taskId',
      serializers.serialize(object.taskId, specifiedType: const FullType(int)),
      'sprintId',
      serializers.serialize(object.sprintId,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  SprintAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SprintAssignmentBuilder();

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
        case 'taskId':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'sprintId':
          result.sprintId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$SprintAssignment extends SprintAssignment {
  @override
  final int id;
  @override
  final int taskId;
  @override
  final int sprintId;

  factory _$SprintAssignment(
          [void Function(SprintAssignmentBuilder)? updates]) =>
      (new SprintAssignmentBuilder()..update(updates))._build();

  _$SprintAssignment._(
      {required this.id, required this.taskId, required this.sprintId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'SprintAssignment', 'id');
    BuiltValueNullFieldError.checkNotNull(
        taskId, r'SprintAssignment', 'taskId');
    BuiltValueNullFieldError.checkNotNull(
        sprintId, r'SprintAssignment', 'sprintId');
  }

  @override
  SprintAssignment rebuild(void Function(SprintAssignmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SprintAssignmentBuilder toBuilder() =>
      new SprintAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SprintAssignment &&
        id == other.id &&
        taskId == other.taskId &&
        sprintId == other.sprintId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, sprintId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SprintAssignment')
          ..add('id', id)
          ..add('taskId', taskId)
          ..add('sprintId', sprintId))
        .toString();
  }
}

class SprintAssignmentBuilder
    implements Builder<SprintAssignment, SprintAssignmentBuilder> {
  _$SprintAssignment? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _taskId;
  int? get taskId => _$this._taskId;
  set taskId(int? taskId) => _$this._taskId = taskId;

  int? _sprintId;
  int? get sprintId => _$this._sprintId;
  set sprintId(int? sprintId) => _$this._sprintId = sprintId;

  SprintAssignmentBuilder();

  SprintAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _taskId = $v.taskId;
      _sprintId = $v.sprintId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SprintAssignment other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SprintAssignment;
  }

  @override
  void update(void Function(SprintAssignmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SprintAssignment build() => _build();

  _$SprintAssignment _build() {
    final _$result = _$v ??
        new _$SprintAssignment._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'SprintAssignment', 'id'),
            taskId: BuiltValueNullFieldError.checkNotNull(
                taskId, r'SprintAssignment', 'taskId'),
            sprintId: BuiltValueNullFieldError.checkNotNull(
                sprintId, r'SprintAssignment', 'sprintId'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
