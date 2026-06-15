class VerificationRequestModel {
  const VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.frontImageUrl,
    this.backImageUrl,
    required this.submittedAt,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String id;
  final String userId;
  final String documentType;
  final String frontImageUrl;
  final String? backImageUrl;
  final DateTime submittedAt;
  final String status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      documentType: json['document_type'] as String,
      frontImageUrl: json['front_image_url'] as String,
      backImageUrl: json['back_image_url'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      status: json['status'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}
