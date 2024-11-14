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
      'docId',
      serializers.serialize(object.docId,
          specifiedType: const FullType(String)),
      'taskDocId',
      serializers.serialize(object.taskDocId,
          specifiedType: const FullType(String)),
      'sprintDocId',
      serializers.serialize(object.sprintDocId,
          specifiedType: const FullType(String)),
    ];
    Object? value;
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
        case 'docId':
          result.docId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskDocId':
          result.taskDocId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'sprintDocId':
          result.sprintDocId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'retired':
          result.retired = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'retiredDate':
          result.retiredDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$SprintAssignment extends SprintAssignment {
  @override
  final String docId;
  @override
  final String taskDocId;
  @override
  final String sprintDocId;
  @override
  final String? retired;
  @override
  final DateTime? retiredDate;

  factory _$SprintAssignment(
          [void Function(SprintAssignmentBuilder)? updates]) =>
      (new SprintAssignmentBuilder()..update(updates))._build();

  _$SprintAssignment._(
      {required this.docId,
      required this.taskDocId,
      required this.sprintDocId,
      this.retired,
      this.retiredDate})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(docId, r'SprintAssignment', 'docId');
    BuiltValueNullFieldError.checkNotNull(
        taskDocId, r'SprintAssignment', 'taskDocId');
    BuiltValueNullFieldError.checkNotNull(
        sprintDocId, r'SprintAssignment', 'sprintDocId');
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
        docId == other.docId &&
        taskDocId == other.taskDocId &&
        sprintDocId == other.sprintDocId &&
        retired == other.retired &&
        retiredDate == other.retiredDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, taskDocId.hashCode);
    _$hash = $jc(_$hash, sprintDocId.hashCode);
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SprintAssignment')
          ..add('docId', docId)
          ..add('taskDocId', taskDocId)
          ..add('sprintDocId', sprintDocId)
          ..add('retired', retired)
          ..add('retiredDate', retiredDate))
        .toString();
  }
}

class SprintAssignmentBuilder
    implements Builder<SprintAssignment, SprintAssignmentBuilder> {
  _$SprintAssignment? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  String? _taskDocId;
  String? get taskDocId => _$this._taskDocId;
  set taskDocId(String? taskDocId) => _$this._taskDocId = taskDocId;

  String? _sprintDocId;
  String? get sprintDocId => _$this._sprintDocId;
  set sprintDocId(String? sprintDocId) => _$this._sprintDocId = sprintDocId;

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  SprintAssignmentBuilder();

  SprintAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _taskDocId = $v.taskDocId;
      _sprintDocId = $v.sprintDocId;
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
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
            docId: BuiltValueNullFieldError.checkNotNull(
                docId, r'SprintAssignment', 'docId'),
            taskDocId: BuiltValueNullFieldError.checkNotNull(
                taskDocId, r'SprintAssignment', 'taskDocId'),
            sprintDocId: BuiltValueNullFieldError.checkNotNull(
                sprintDocId, r'SprintAssignment', 'sprintDocId'),
            retired: retired,
            retiredDate: retiredDate);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
