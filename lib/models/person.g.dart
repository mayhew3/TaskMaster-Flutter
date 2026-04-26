// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Person> _$personSerializer = _$PersonSerializer();

class _$PersonSerializer implements StructuredSerializer<Person> {
  @override
  final Iterable<Type> types = const [Person, _$Person];
  @override
  final String wireName = 'Person';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Person object, {
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
      'email',
      serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.displayName;

    result
      ..add('displayName')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(String)),
      );
    value = object.familyDocId;

    result
      ..add('familyDocId')
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
  Person deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonBuilder();

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
        case 'email':
          result.email =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'displayName':
          result.displayName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'familyDocId':
          result.familyDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
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

class _$Person extends Person {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? familyDocId;
  @override
  final String? retired;
  @override
  final DateTime? retiredDate;

  factory _$Person([void Function(PersonBuilder)? updates]) =>
      (PersonBuilder()..update(updates))._build();

  _$Person._({
    required this.docId,
    required this.dateAdded,
    required this.email,
    this.displayName,
    this.familyDocId,
    this.retired,
    this.retiredDate,
  }) : super._();
  @override
  Person rebuild(void Function(PersonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonBuilder toBuilder() => PersonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Person &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        email == other.email &&
        displayName == other.displayName &&
        familyDocId == other.familyDocId &&
        retired == other.retired &&
        retiredDate == other.retiredDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, familyDocId.hashCode);
    _$hash = $jc(_$hash, retired.hashCode);
    _$hash = $jc(_$hash, retiredDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Person')
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('email', email)
          ..add('displayName', displayName)
          ..add('familyDocId', familyDocId)
          ..add('retired', retired)
          ..add('retiredDate', retiredDate))
        .toString();
  }
}

class PersonBuilder implements Builder<Person, PersonBuilder> {
  _$Person? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _familyDocId;
  String? get familyDocId => _$this._familyDocId;
  set familyDocId(String? familyDocId) => _$this._familyDocId = familyDocId;

  String? _retired;
  String? get retired => _$this._retired;
  set retired(String? retired) => _$this._retired = retired;

  DateTime? _retiredDate;
  DateTime? get retiredDate => _$this._retiredDate;
  set retiredDate(DateTime? retiredDate) => _$this._retiredDate = retiredDate;

  PersonBuilder();

  PersonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _email = $v.email;
      _displayName = $v.displayName;
      _familyDocId = $v.familyDocId;
      _retired = $v.retired;
      _retiredDate = $v.retiredDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Person other) {
    _$v = other as _$Person;
  }

  @override
  void update(void Function(PersonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Person build() => _build();

  _$Person _build() {
    final _$result =
        _$v ??
        _$Person._(
          docId: BuiltValueNullFieldError.checkNotNull(
            docId,
            r'Person',
            'docId',
          ),
          dateAdded: BuiltValueNullFieldError.checkNotNull(
            dateAdded,
            r'Person',
            'dateAdded',
          ),
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'Person',
            'email',
          ),
          displayName: displayName,
          familyDocId: familyDocId,
          retired: retired,
          retiredDate: retiredDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
