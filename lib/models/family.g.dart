// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Family> _$familySerializer = _$FamilySerializer();

class _$FamilySerializer implements StructuredSerializer<Family> {
  @override
  final Iterable<Type> types = const [Family, _$Family];
  @override
  final String wireName = 'Family';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Family object, {
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
      'ownerPersonDocId',
      serializers.serialize(
        object.ownerPersonDocId,
        specifiedType: const FullType(String),
      ),
      'members',
      serializers.serialize(
        object.members,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
    ];
    Object? value;
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
  Family deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FamilyBuilder();

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
        case 'ownerPersonDocId':
          result.ownerPersonDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'members':
          result.members.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(String),
                  ]),
                )!
                as BuiltList<Object?>,
          );
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
      }
    }

    return result.build();
  }
}

class _$Family extends Family {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String ownerPersonDocId;
  @override
  final BuiltList<String> members;
  @override
  final String? retired;
  @override
  final DateTime? retiredDate;

  factory _$Family([void Function(FamilyBuilder)? updates]) =>
      (FamilyBuilder()..update(updates))._build();

  _$Family._({
    required this.docId,
    required this.dateAdded,
    required this.ownerPersonDocId,
    required this.members,
    this.retired,
    this.retiredDate,
  }) : super._();
  @override
  Family rebuild(void Function(FamilyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FamilyBuilder toBuilder() => FamilyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Family &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        ownerPersonDocId == other.ownerPersonDocId &&
        members == other.members &&
        retired == other.retired &&
        retiredDate == other.retiredDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, ownerPersonDocId.hashCode);
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Family')
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('ownerPersonDocId', ownerPersonDocId)
          ..add('members', members)
          ..add('retired', retired)
          ..add('retiredDate', retiredDate))
        .toString();
  }
}

class FamilyBuilder implements Builder<Family, FamilyBuilder> {
  _$Family? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  String? _ownerPersonDocId;
  String? get ownerPersonDocId => _$this._ownerPersonDocId;
  set ownerPersonDocId(String? ownerPersonDocId) =>
      _$this._ownerPersonDocId = ownerPersonDocId;

  ListBuilder<String>? _members;
  ListBuilder<String> get members => _$this._members ??= ListBuilder<String>();
  set members(ListBuilder<String>? members) => _$this._members = members;

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  FamilyBuilder();

  FamilyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _ownerPersonDocId = $v.ownerPersonDocId;
      _members = $v.members.toBuilder();
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Family other) {
    _$v = other as _$Family;
  }

  @override
  void update(void Function(FamilyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Family build() => _build();

  _$Family _build() {
    _$Family _$result;
    try {
      _$result =
          _$v ??
          _$Family._(
            docId: BuiltValueNullFieldError.checkNotNull(
              docId,
              r'Family',
              'docId',
            ),
            dateAdded: BuiltValueNullFieldError.checkNotNull(
              dateAdded,
              r'Family',
              'dateAdded',
            ),
            ownerPersonDocId: BuiltValueNullFieldError.checkNotNull(
              ownerPersonDocId,
              r'Family',
              'ownerPersonDocId',
            ),
            members: members.build(),
            retired: retired,
            retiredDate: retiredDate,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'members';
        members.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'Family',
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
