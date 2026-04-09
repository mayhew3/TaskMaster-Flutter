/// Represents a Firestore task document that failed deserialization.
/// Displayed in the UI with warning styling and disabled interaction.
class BadSchemaTask {
  final String docId;
  final String? rawName;
  final String errorMessage;
  final DateTime detectedAt;

  BadSchemaTask({
    required this.docId,
    this.rawName,
    required this.errorMessage,
  }) : detectedAt = DateTime.now();

  String get displayName => rawName ?? 'Unknown Task ($docId)';
}
