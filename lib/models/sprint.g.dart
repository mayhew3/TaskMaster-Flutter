// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Sprint> _$sprintSerializer = new _$SprintSerializer();

class _$SprintSerializer implements StructuredSerializer<Sprint> {
  @override
  final Iterable<Type> types = const [Sprint, _$Sprint];
  @override
  final String wireName = 'Sprint';

  @override
  Iterable<Object?> serialize(Serializers serializers, Sprint object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'startDate',
      serializers.serialize(object.startDate,
          specifiedType: const FullType(DateTime)),
      'endDate',
      serializers.serialize(object.endDate,
          specifiedType: const FullType(DateTime)),
      'numUnits',
      serializers.serialize(object.numUnits,
          specifiedType: const FullType(int)),
      'unitName',
      serializers.serialize(object.unitName,
          specifiedType: const FullType(String)),
      'personId',
      serializers.serialize(object.personId,
          specifiedType: const FullType(int)),
    ];
    Object? value;
    value = object.id;

    result
      ..add('id')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    value = object.dateAdded;

    result
      ..add('dateAdded')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.closeDate;

    result
      ..add('closeDate')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.sprintNumber;

    result
      ..add('sprintNumber')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));

    return result;
  }

  @override
  Sprint deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SprintBuilder();

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
        case 'dateAdded':
          result.dateAdded = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'startDate':
          result.startDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
        case 'endDate':
          result.endDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime))! as DateTime;
          break;
        case 'closeDate':
          result.closeDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'numUnits':
          result.numUnits = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'unitName':
          result.unitName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'personId':
          result.personId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'sprintNumber':
          result.sprintNumber = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$Sprint extends Sprint {
  @override
  final int? id;
  @override
  final DateTime? dateAdded;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final DateTime? closeDate;
  @override
  final int numUnits;
  @override
  final String unitName;
  @override
  final int personId;
  @override
  final int? sprintNumber;

  factory _$Sprint([void Function(SprintBuilder)? updates]) =>
      (new SprintBuilder()..update(updates))._build();

  _$Sprint._(
      {this.id,
      this.dateAdded,
      required this.startDate,
      required this.endDate,
      this.closeDate,
      required this.numUnits,
      required this.unitName,
      required this.personId,
      this.sprintNumber})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(startDate, r'Sprint', 'startDate');
    BuiltValueNullFieldError.checkNotNull(endDate, r'Sprint', 'endDate');
    BuiltValueNullFieldError.checkNotNull(numUnits, r'Sprint', 'numUnits');
    BuiltValueNullFieldError.checkNotNull(unitName, r'Sprint', 'unitName');
    BuiltValueNullFieldError.checkNotNull(personId, r'Sprint', 'personId');
  }

  @override
  Sprint rebuild(void Function(SprintBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SprintBuilder toBuilder() => new SprintBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Sprint &&
        id == other.id &&
        dateAdded == other.dateAdded &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        closeDate == other.closeDate &&
        numUnits == other.numUnits &&
        unitName == other.unitName &&
        personId == other.personId &&
        sprintNumber == other.sprintNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, closeDate.hashCode);
    _$hash = $jc(_$hash, numUnits.hashCode);
    _$hash = $jc(_$hash, unitName.hashCode);
    _$hash = $jc(_$hash, personId.hashCode);
    _$hash = $jc(_$hash, sprintNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Sprint')
          ..add('id', id)
          ..add('dateAdded', dateAdded)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('closeDate', closeDate)
          ..add('numUnits', numUnits)
          ..add('unitName', unitName)
          ..add('personId', personId)
          ..add('sprintNumber', sprintNumber))
        .toString();
  }
}

class SprintBuilder implements Builder<Sprint, SprintBuilder> {
  _$Sprint? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  DateTime? _startDate;
  DateTime? get startDate => _$this._startDate;
  set startDate(DateTime? startDate) => _$this._startDate = startDate;

  DateTime? _endDate;
  DateTime? get endDate => _$this._endDate;
  set endDate(DateTime? endDate) => _$this._endDate = endDate;

  DateTime? _closeDate;
  DateTime? get closeDate => _$this._closeDate;
  set closeDate(DateTime? closeDate) => _$this._closeDate = closeDate;

  int? _numUnits;
  int? get numUnits => _$this._numUnits;
  set numUnits(int? numUnits) => _$this._numUnits = numUnits;

  String? _unitName;
  String? get unitName => _$this._unitName;
  set unitName(String? unitName) => _$this._unitName = unitName;

  int? _personId;
  int? get personId => _$this._personId;
  set personId(int? personId) => _$this._personId = personId;

  int? _sprintNumber;
  int? get sprintNumber => _$this._sprintNumber;
  set sprintNumber(int? sprintNumber) => _$this._sprintNumber = sprintNumber;

  SprintBuilder();

  SprintBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _dateAdded = $v.dateAdded;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _closeDate = $v.closeDate;
      _numUnits = $v.numUnits;
      _unitName = $v.unitName;
      _personId = $v.personId;
      _sprintNumber = $v.sprintNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Sprint other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Sprint;
  }

  @override
  void update(void Function(SprintBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Sprint build() => _build();

  _$Sprint _build() {
    final _$result = _$v ??
        new _$Sprint._(
            id: id,
            dateAdded: dateAdded,
            startDate: BuiltValueNullFieldError.checkNotNull(
                startDate, r'Sprint', 'startDate'),
            endDate: BuiltValueNullFieldError.checkNotNull(
                endDate, r'Sprint', 'endDate'),
            closeDate: closeDate,
            numUnits: BuiltValueNullFieldError.checkNotNull(
                numUnits, r'Sprint', 'numUnits'),
            unitName: BuiltValueNullFieldError.checkNotNull(
                unitName, r'Sprint', 'unitName'),
            personId: BuiltValueNullFieldError.checkNotNull(
                personId, r'Sprint', 'personId'),
            sprintNumber: sprintNumber);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
