// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Sprint> _$sprintSerializer = _$SprintSerializer();

class _$SprintSerializer implements StructuredSerializer<Sprint> {
  @override
  final Iterable<Type> types = const [Sprint, _$Sprint];
  @override
  final String wireName = 'Sprint';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Sprint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'docId',
      serializers.serialize(
        object.docId,
        specifiedType: const FullType(String),
      ),
      'dateAdded',
      serializers.serialize(
        object.dateAdded,
        specifiedType: const FullType(DateTime),
      ),
      'startDate',
      serializers.serialize(
        object.startDate,
        specifiedType: const FullType(DateTime),
      ),
      'endDate',
      serializers.serialize(
        object.endDate,
        specifiedType: const FullType(DateTime),
      ),
      'numUnits',
      serializers.serialize(
        object.numUnits,
        specifiedType: const FullType(int),
      ),
      'unitName',
      serializers.serialize(
        object.unitName,
        specifiedType: const FullType(String),
      ),
      'personDocId',
      serializers.serialize(
        object.personDocId,
        specifiedType: const FullType(String),
      ),
      'sprintNumber',
      serializers.serialize(
        object.sprintNumber,
        specifiedType: const FullType(int),
      ),
      'sprintAssignments',
      serializers.serialize(
        object.sprintAssignments,
        specifiedType: const FullType(BuiltList, const [
          const FullType(SprintAssignment),
        ]),
      ),
    ];
    Object? value;
    value = object.closeDate;

    result
      ..add('closeDate')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(DateTime)),
      );
    value = object.retired;

    result
      ..add('retired')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(String)),
      );
    value = object.retiredDate;

    result
      ..add('retiredDate')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(DateTime)),
      );

    return result;
  }

  @override
  Sprint deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SprintBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'docId':
          result.docId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'dateAdded':
          result.dateAdded =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'startDate':
          result.startDate =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'endDate':
          result.endDate =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'closeDate':
          result.closeDate =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime?;
          break;
        case 'numUnits':
          result.numUnits =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'unitName':
          result.unitName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'personDocId':
          result.personDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'sprintNumber':
          result.sprintNumber =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'retired':
          result.retired =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'retiredDate':
          result.retiredDate =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime?;
          break;
        case 'sprintAssignments':
          result.sprintAssignments.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(SprintAssignment),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$Sprint extends Sprint {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
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
  final String personDocId;
  @override
  final int sprintNumber;
  @override
  final String? retired;
  @override
  final DateTime? retiredDate;
  @override
  final BuiltList<SprintAssignment> sprintAssignments;

  factory _$Sprint([void Function(SprintBuilder)? updates]) =>
      (SprintBuilder()..update(updates))._build();

  _$Sprint._({
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
    required this.sprintAssignments,
  }) : super._();
  @override
  Sprint rebuild(void Function(SprintBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SprintBuilder toBuilder() => SprintBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Sprint &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        closeDate == other.closeDate &&
        numUnits == other.numUnits &&
        unitName == other.unitName &&
        personDocId == other.personDocId &&
        sprintNumber == other.sprintNumber &&
        retired == other.retired &&
        retiredDate == other.retiredDate &&
        sprintAssignments == other.sprintAssignments;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, closeDate.hashCode);
    _$hash = $jc(_$hash, numUnits.hashCode);
    _$hash = $jc(_$hash, unitName.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jc(_$hash, sprintNumber.hashCode);
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jc(_$hash, sprintAssignments.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Sprint')
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('closeDate', closeDate)
          ..add('numUnits', numUnits)
          ..add('unitName', unitName)
          ..add('personDocId', personDocId)
          ..add('sprintNumber', sprintNumber)
          ..add('retired', retired)
          ..add('retiredDate', retiredDate)
          ..add('sprintAssignments', sprintAssignments))
        .toString();
  }
}

class SprintBuilder implements Builder<Sprint, SprintBuilder> {
  _$Sprint? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

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

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  int? _sprintNumber;
  int? get sprintNumber => _$this._sprintNumber;
  set sprintNumber(int? sprintNumber) => _$this._sprintNumber = sprintNumber;

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  ListBuilder<SprintAssignment>? _sprintAssignments;
  ListBuilder<SprintAssignment> get sprintAssignments =>
      _$this._sprintAssignments ??= ListBuilder<SprintAssignment>();
  set sprintAssignments(ListBuilder<SprintAssignment>? sprintAssignments) =>
      _$this._sprintAssignments = sprintAssignments;

  SprintBuilder();

  SprintBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _closeDate = $v.closeDate;
      _numUnits = $v.numUnits;
      _unitName = $v.unitName;
      _personDocId = $v.personDocId;
      _sprintNumber = $v.sprintNumber;
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
      _sprintAssignments = $v.sprintAssignments.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Sprint other) {
    _$v = other as _$Sprint;
  }

  @override
  void update(void Function(SprintBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Sprint build() => _build();

  _$Sprint _build() {
    _$Sprint _$result;
    try {
      _$result =
          _$v ??
          _$Sprint._(
            docId: BuiltValueNullFieldError.checkNotNull(
              docId,
              r'Sprint',
              'docId',
            ),
            dateAdded: BuiltValueNullFieldError.checkNotNull(
              dateAdded,
              r'Sprint',
              'dateAdded',
            ),
            startDate: BuiltValueNullFieldError.checkNotNull(
              startDate,
              r'Sprint',
              'startDate',
            ),
            endDate: BuiltValueNullFieldError.checkNotNull(
              endDate,
              r'Sprint',
              'endDate',
            ),
            closeDate: closeDate,
            numUnits: BuiltValueNullFieldError.checkNotNull(
              numUnits,
              r'Sprint',
              'numUnits',
            ),
            unitName: BuiltValueNullFieldError.checkNotNull(
              unitName,
              r'Sprint',
              'unitName',
            ),
            personDocId: BuiltValueNullFieldError.checkNotNull(
              personDocId,
              r'Sprint',
              'personDocId',
            ),
            sprintNumber: BuiltValueNullFieldError.checkNotNull(
              sprintNumber,
              r'Sprint',
              'sprintNumber',
            ),
            retired: retired,
            retiredDate: retiredDate,
            sprintAssignments: sprintAssignments.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sprintAssignments';
        sprintAssignments.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'Sprint',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
