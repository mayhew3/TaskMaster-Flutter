// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_date.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<AnchorDate> _$anchorDateSerializer = _$AnchorDateSerializer();

class _$AnchorDateSerializer implements StructuredSerializer<AnchorDate> {
  @override
  final Iterable<Type> types = const [AnchorDate, _$AnchorDate];
  @override
  final String wireName = 'AnchorDate';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    AnchorDate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'dateValue',
      serializers.serialize(
        object.dateValue,
        specifiedType: const FullType(DateTime),
      ),
      'dateType',
      serializers.serialize(
        object.dateType,
        specifiedType: const FullType(TaskDateType),
      ),
    ];

    return result;
  }

  @override
  AnchorDate deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnchorDateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'dateValue':
          result.dateValue =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'dateType':
          result.dateType =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(TaskDateType),
                  )!
                  as TaskDateType;
          break;
      }
    }

    return result.build();
  }
}

class _$AnchorDate extends AnchorDate {
  @override
  final DateTime dateValue;
  @override
  final TaskDateType dateType;

  factory _$AnchorDate([void Function(AnchorDateBuilder)? updates]) =>
      (AnchorDateBuilder()..update(updates))._build();

  _$AnchorDate._({required this.dateValue, required this.dateType}) : super._();
  @override
  AnchorDate rebuild(void Function(AnchorDateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AnchorDateBuilder toBuilder() => AnchorDateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AnchorDate &&
        dateValue == other.dateValue &&
        dateType == other.dateType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dateValue.hashCode);
    _$hash = $jc(_$hash, dateType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AnchorDate')
          ..add('dateValue', dateValue)
          ..add('dateType', dateType))
        .toString();
  }
}

class AnchorDateBuilder implements Builder<AnchorDate, AnchorDateBuilder> {
  _$AnchorDate? _$v;

  DateTime? _dateValue;
  DateTime? get dateValue => _$this._dateValue;
  set dateValue(DateTime? dateValue) => _$this._dateValue = dateValue;

  TaskDateType? _dateType;
  TaskDateType? get dateType => _$this._dateType;
  set dateType(TaskDateType? dateType) => _$this._dateType = dateType;

  AnchorDateBuilder();

  AnchorDateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dateValue = $v.dateValue;
      _dateType = $v.dateType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AnchorDate other) {
    _$v = other as _$AnchorDate;
  }

  @override
  void update(void Function(AnchorDateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AnchorDate build() => _build();

  _$AnchorDate _build() {
    final _$result =
        _$v ??
        _$AnchorDate._(
          dateValue: BuiltValueNullFieldError.checkNotNull(
            dateValue,
            r'AnchorDate',
            'dateValue',
          ),
          dateType: BuiltValueNullFieldError.checkNotNull(
            dateType,
            r'AnchorDate',
            'dateType',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
