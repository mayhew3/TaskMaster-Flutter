// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Snooze> _$snoozeSerializer = _$SnoozeSerializer();

class _$SnoozeSerializer implements StructuredSerializer<Snooze> {
  @override
  final Iterable<Type> types = const [Snooze, _$Snooze];
  @override
  final String wireName = 'Snooze';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Snooze object, {
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
      'taskDocId',
      serializers.serialize(
        object.taskDocId,
        specifiedType: const FullType(String),
      ),
      'snoozeNumber',
      serializers.serialize(
        object.snoozeNumber,
        specifiedType: const FullType(int),
      ),
      'snoozeUnits',
      serializers.serialize(
        object.snoozeUnits,
        specifiedType: const FullType(String),
      ),
      'snoozeAnchor',
      serializers.serialize(
        object.snoozeAnchor,
        specifiedType: const FullType(String),
      ),
      'newAnchor',
      serializers.serialize(
        object.newAnchor,
        specifiedType: const FullType(DateTime),
      ),
    ];
    Object? value;
    value = object.previousAnchor;

    result
      ..add('previousAnchor')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(DateTime)),
      );

    return result;
  }

  @override
  Snooze deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SnoozeBuilder();

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
        case 'taskDocId':
          result.taskDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'snoozeNumber':
          result.snoozeNumber =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'snoozeUnits':
          result.snoozeUnits =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'snoozeAnchor':
          result.snoozeAnchor =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'previousAnchor':
          result.previousAnchor =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime?;
          break;
        case 'newAnchor':
          result.newAnchor =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$Snooze extends Snooze {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String taskDocId;
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
      (SnoozeBuilder()..update(updates))._build();

  _$Snooze._({
    required this.docId,
    required this.dateAdded,
    required this.taskDocId,
    required this.snoozeNumber,
    required this.snoozeUnits,
    required this.snoozeAnchor,
    this.previousAnchor,
    required this.newAnchor,
  }) : super._();
  @override
  Snooze rebuild(void Function(SnoozeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SnoozeBuilder toBuilder() => SnoozeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Snooze &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        taskDocId == other.taskDocId &&
        snoozeNumber == other.snoozeNumber &&
        snoozeUnits == other.snoozeUnits &&
        snoozeAnchor == other.snoozeAnchor &&
        previousAnchor == other.previousAnchor &&
        newAnchor == other.newAnchor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, taskDocId.hashCode);
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
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('taskDocId', taskDocId)
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

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  String? _taskDocId;
  String? get taskDocId => _$this._taskDocId;
  set taskDocId(String? taskDocId) => _$this._taskDocId = taskDocId;

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
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _taskDocId = $v.taskDocId;
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
    _$v = other as _$Snooze;
  }

  @override
  void update(void Function(SnoozeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Snooze build() => _build();

  _$Snooze _build() {
    final _$result =
        _$v ??
        _$Snooze._(
          docId: BuiltValueNullFieldError.checkNotNull(
            docId,
            r'Snooze',
            'docId',
          ),
          dateAdded: BuiltValueNullFieldError.checkNotNull(
            dateAdded,
            r'Snooze',
            'dateAdded',
          ),
          taskDocId: BuiltValueNullFieldError.checkNotNull(
            taskDocId,
            r'Snooze',
            'taskDocId',
          ),
          snoozeNumber: BuiltValueNullFieldError.checkNotNull(
            snoozeNumber,
            r'Snooze',
            'snoozeNumber',
          ),
          snoozeUnits: BuiltValueNullFieldError.checkNotNull(
            snoozeUnits,
            r'Snooze',
            'snoozeUnits',
          ),
          snoozeAnchor: BuiltValueNullFieldError.checkNotNull(
            snoozeAnchor,
            r'Snooze',
            'snoozeAnchor',
          ),
          previousAnchor: previousAnchor,
          newAnchor: BuiltValueNullFieldError.checkNotNull(
            newAnchor,
            r'Snooze',
            'newAnchor',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
