import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';

part 'family_invitation.g.dart';

abstract class FamilyInvitation
    implements Built<FamilyInvitation, FamilyInvitationBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<FamilyInvitation> get serializer =>
      _$familyInvitationSerializer;

  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusDeclined = 'declined';

  String get docId;
  DateTime get dateAdded;

  String get inviterPersonDocId;
  String get inviterFamilyDocId;
  String? get inviterDisplayName;

  String get inviteeEmail;
  String get status;

  FamilyInvitation._();
  factory FamilyInvitation([Function(FamilyInvitationBuilder) updates]) =
      _$FamilyInvitation;

  static FamilyInvitation fromJson(dynamic json) {
    return serializers.deserializeWith(FamilyInvitation.serializer, json)!;
  }
}
