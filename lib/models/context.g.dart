// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Context> _$contextSerializer = _$ContextSerializer();

class _$ContextSerializer implements StructuredSerializer<Context> {
  @override
  final Iterable<Type> types = const [Context, _$Context];
  @override
  final String wireName = 'Context';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Context object, {
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
    value = object.iconName;

    result
      ..add('iconName')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(String)),
      );
    value = object.color;

    result
      ..add('color')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(String)),
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
  Context deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContextBuilder();

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
        case 'iconName':
          result.iconName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'color':
          result.color =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
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

class _$Context extends Context {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String name;
  @override
  final int sortOrder;
  @override
  final String? iconName;
  @override
  final String? color;
  @override
  final String personDocId;
  @override
  final String? retired;
  @override
  final DateTime? retiredDate;

  factory _$Context([void Function(ContextBuilder)? updates]) =>
      (ContextBuilder()..update(updates))._build();

  _$Context._({
    required this.docId,
    required this.dateAdded,
    required this.name,
    required this.sortOrder,
    this.iconName,
    this.color,
    required this.personDocId,
    this.retired,
    this.retiredDate,
  }) : super._();
  @override
  Context rebuild(void Function(ContextBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContextBuilder toBuilder() => ContextBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Context &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        name == other.name &&
        sortOrder == other.sortOrder &&
        iconName == other.iconName &&
        color == other.color &&
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
    _$hash = $jc(_$hash, iconName.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Context')
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('name', name)
          ..add('sortOrder', sortOrder)
          ..add('iconName', iconName)
          ..add('color', color)
          ..add('personDocId', personDocId)
          ..add('retired', retired)
          ..add('retiredDate', retiredDate))
        .toString();
  }
}

class ContextBuilder implements Builder<Context, ContextBuilder> {
  _$Context? _$v;

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

  String? _iconName;
  String? get iconName => _$this._iconName;
  set iconName(String? iconName) => _$this._iconName = iconName;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  ContextBuilder();

  ContextBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _name = $v.name;
      _sortOrder = $v.sortOrder;
      _iconName = $v.iconName;
      _color = $v.color;
      _personDocId = $v.personDocId;
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Context other) {
    _$v = other as _$Context;
  }

  @override
  void update(void Function(ContextBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Context build() => _build();

  _$Context _build() {
    final _$result =
        _$v ??
        _$Context._(
          docId: BuiltValueNullFieldError.checkNotNull(
            docId,
            r'Context',
            'docId',
          ),
          dateAdded: BuiltValueNullFieldError.checkNotNull(
            dateAdded,
            r'Context',
            'dateAdded',
          ),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Context', 'name'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
            sortOrder,
            r'Context',
            'sortOrder',
          ),
          iconName: iconName,
          color: color,
          personDocId: BuiltValueNullFieldError.checkNotNull(
            personDocId,
            r'Context',
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
