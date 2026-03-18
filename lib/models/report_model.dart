import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a listing report stored in Firestore under reports/{report_id}.
class ReportModel {
  final String id;
  final String itemId;
  final String reporterId;
  final String reason;
  final String? details;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.itemId,
    required this.reporterId,
    required this.reason,
    this.details,
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      itemId: data['item_id'] as String? ?? '',
      reporterId: data['reporter_id'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      details: data['details'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'item_id': itemId,
        'reporter_id': reporterId,
        'reason': reason,
        'details': details,
        'created_at': Timestamp.fromDate(createdAt),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReportModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
