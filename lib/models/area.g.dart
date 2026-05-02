// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Area> _$areaSerializer = _$AreaSerializer();

class _$AreaSerializer implements StructuredSerializer<Area> {
  @override
  final Iterable<Type> types = const [Area, _$Area];
  @override
  final String wireName = 'Area';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Area object, {
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
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'sortOrder',
      serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(int),
      ),
      'personDocId',
      serializers.serialize(
        object.personDocId,
        specifiedType: const FullType(String),
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
  Area deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AreaBuilder();

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
        case 'name':
          result.name =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'sortOrder':
          result.sortOrder =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'personDocId':
          result.personDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
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

class _$Area extends Area {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String name;
  @override
  final int sortOrder;
  @override
  final String personDocId;
  @override
  final String? retired;
  @override
  final DateTime? retiredDate;

  factory _$Area([void Function(AreaBuilder)? updates]) =>
      (AreaBuilder()..update(updates))._build();

  _$Area._({
    required this.docId,
    required this.dateAdded,
    required this.name,
    required this.sortOrder,
    required this.personDocId,
    this.retired,
    this.retiredDate,
  }) : super._();
  @override
  Area rebuild(void Function(AreaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AreaBuilder toBuilder() => AreaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Area &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        name == other.name &&
        sortOrder == other.sortOrder &&
        personDocId == other.personDocId &&
        retired == other.retired &&
        retiredDate == other.retiredDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Area')
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('name', name)
          ..add('sortOrder', sortOrder)
          ..add('personDocId', personDocId)
          ..add('retired', retired)
          ..add('retiredDate', retiredDate))
        .toString();
  }
}

class AreaBuilder implements Builder<Area, AreaBuilder> {
  _$Area? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  AreaBuilder();

  AreaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _name = $v.name;
      _sortOrder = $v.sortOrder;
      _personDocId = $v.personDocId;
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Area other) {
    _$v = other as _$Area;
  }

  @override
  void update(void Function(AreaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Area build() => _build();

  _$Area _build() {
    final _$result =
        _$v ??
        _$Area._(
          docId: BuiltValueNullFieldError.checkNotNull(docId, r'Area', 'docId'),
          dateAdded: BuiltValueNullFieldError.checkNotNull(
            dateAdded,
            r'Area',
            'dateAdded',
          ),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Area', 'name'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
            sortOrder,
            r'Area',
            'sortOrder',
          ),
          personDocId: BuiltValueNullFieldError.checkNotNull(
            personDocId,
            r'Area',
            'personDocId',
          ),
          retired: retired,
          retiredDate: retiredDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
