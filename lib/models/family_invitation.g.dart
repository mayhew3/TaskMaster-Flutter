// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_invitation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<FamilyInvitation> _$familyInvitationSerializer =
    _$FamilyInvitationSerializer();

class _$FamilyInvitationSerializer
    implements StructuredSerializer<FamilyInvitation> {
  @override
  final Iterable<Type> types = const [FamilyInvitation, _$FamilyInvitation];
  @override
  final String wireName = 'FamilyInvitation';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    FamilyInvitation object, {
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
      'inviterPersonDocId',
      serializers.serialize(
        object.inviterPersonDocId,
        specifiedType: const FullType(String),
      ),
      'inviterFamilyDocId',
      serializers.serialize(
        object.inviterFamilyDocId,
        specifiedType: const FullType(String),
      ),
      'inviteeEmail',
      serializers.serialize(
        object.inviteeEmail,
        specifiedType: const FullType(String),
      ),
      'status',
      serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.inviterDisplayName;

    result
      ..add('inviterDisplayName')
      ..add(
        serializers.serialize(value, specifiedType: const FullType(String)),
      );

    return result;
  }

  @override
  FamilyInvitation deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FamilyInvitationBuilder();

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
        case 'inviterPersonDocId':
          result.inviterPersonDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'inviterFamilyDocId':
          result.inviterFamilyDocId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'inviterDisplayName':
          result.inviterDisplayName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'inviteeEmail':
          result.inviteeEmail =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'status':
          result.status =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
      }
    }

    return result.build();
  }
}

class _$FamilyInvitation extends FamilyInvitation {
  @override
  final String docId;
  @override
  final DateTime dateAdded;
  @override
  final String inviterPersonDocId;
  @override
  final String inviterFamilyDocId;
  @override
  final String? inviterDisplayName;
  @override
  final String inviteeEmail;
  @override
  final String status;

  factory _$FamilyInvitation([
    void Function(FamilyInvitationBuilder)? updates,
  ]) => (FamilyInvitationBuilder()..update(updates))._build();

  _$FamilyInvitation._({
    required this.docId,
    required this.dateAdded,
    required this.inviterPersonDocId,
    required this.inviterFamilyDocId,
    this.inviterDisplayName,
    required this.inviteeEmail,
    required this.status,
  }) : super._();
  @override
  FamilyInvitation rebuild(void Function(FamilyInvitationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FamilyInvitationBuilder toBuilder() =>
      FamilyInvitationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FamilyInvitation &&
        docId == other.docId &&
        dateAdded == other.dateAdded &&
        inviterPersonDocId == other.inviterPersonDocId &&
        inviterFamilyDocId == other.inviterFamilyDocId &&
        inviterDisplayName == other.inviterDisplayName &&
        inviteeEmail == other.inviteeEmail &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docId.hashCode);
    _$hash = $jc(_$hash, dateAdded.hashCode);
    _$hash = $jc(_$hash, inviterPersonDocId.hashCode);
    _$hash = $jc(_$hash, inviterFamilyDocId.hashCode);
    _$hash = $jc(_$hash, inviterDisplayName.hashCode);
    _$hash = $jc(_$hash, inviteeEmail.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FamilyInvitation')
          ..add('docId', docId)
          ..add('dateAdded', dateAdded)
          ..add('inviterPersonDocId', inviterPersonDocId)
          ..add('inviterFamilyDocId', inviterFamilyDocId)
          ..add('inviterDisplayName', inviterDisplayName)
          ..add('inviteeEmail', inviteeEmail)
          ..add('status', status))
        .toString();
  }
}

class FamilyInvitationBuilder
    implements Builder<FamilyInvitation, FamilyInvitationBuilder> {
  _$FamilyInvitation? _$v;

  String? _docId;
  String? get docId => _$this._docId;
  set docId(String? docId) => _$this._docId = docId;

  DateTime? _dateAdded;
  DateTime? get dateAdded => _$this._dateAdded;
  set dateAdded(DateTime? dateAdded) => _$this._dateAdded = dateAdded;

  String? _inviterPersonDocId;
  String? get inviterPersonDocId => _$this._inviterPersonDocId;
  set inviterPersonDocId(String? inviterPersonDocId) =>
      _$this._inviterPersonDocId = inviterPersonDocId;

  String? _inviterFamilyDocId;
  String? get inviterFamilyDocId => _$this._inviterFamilyDocId;
  set inviterFamilyDocId(String? inviterFamilyDocId) =>
      _$this._inviterFamilyDocId = inviterFamilyDocId;

  String? _inviterDisplayName;
  String? get inviterDisplayName => _$this._inviterDisplayName;
  set inviterDisplayName(String? inviterDisplayName) =>
      _$this._inviterDisplayName = inviterDisplayName;

  String? _inviteeEmail;
  String? get inviteeEmail => _$this._inviteeEmail;
  set inviteeEmail(String? inviteeEmail) => _$this._inviteeEmail = inviteeEmail;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  FamilyInvitationBuilder();

  FamilyInvitationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docId = $v.docId;
      _dateAdded = $v.dateAdded;
      _inviterPersonDocId = $v.inviterPersonDocId;
      _inviterFamilyDocId = $v.inviterFamilyDocId;
      _inviterDisplayName = $v.inviterDisplayName;
      _inviteeEmail = $v.inviteeEmail;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FamilyInvitation other) {
    _$v = other as _$FamilyInvitation;
  }

  @override
  void update(void Function(FamilyInvitationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FamilyInvitation build() => _build();

  _$FamilyInvitation _build() {
    final _$result =
        _$v ??
        _$FamilyInvitation._(
          docId: BuiltValueNullFieldError.checkNotNull(
            docId,
            r'FamilyInvitation',
            'docId',
          ),
          dateAdded: BuiltValueNullFieldError.checkNotNull(
            dateAdded,
            r'FamilyInvitation',
            'dateAdded',
          ),
          inviterPersonDocId: BuiltValueNullFieldError.checkNotNull(
            inviterPersonDocId,
            r'FamilyInvitation',
            'inviterPersonDocId',
          ),
          inviterFamilyDocId: BuiltValueNullFieldError.checkNotNull(
            inviterFamilyDocId,
            r'FamilyInvitation',
            'inviterFamilyDocId',
          ),
          inviterDisplayName: inviterDisplayName,
          inviteeEmail: BuiltValueNullFieldError.checkNotNull(
            inviteeEmail,
            r'FamilyInvitation',
            'inviteeEmail',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'FamilyInvitation',
            'status',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
