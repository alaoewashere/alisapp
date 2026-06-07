class ReportModel {
  const ReportModel({
    required this.listingId,
    required this.reporterId,
    required this.reason,
  });

  final String listingId;
  final String reporterId;
  final String reason;

  Map<String, dynamic> toInsertJson() {
    return {
      'listing_id': listingId,
      'reporter_id': reporterId,
      'reason': reason,
    };
  }
}

/// Predefined report reasons in Arabic.
abstract final class ReportReasons {
  static const duplicate = 'إعلان مكرر';
  static const misleadingPrice = 'سعر مضلل';
  static const fakePhotos = 'صور مزيفة';
  static const inappropriate = 'محتوى غير لائق';
  static const fraud = 'احتيال أو نصب';
  static const other = 'أخرى';

  static const options = [
    duplicate,
    misleadingPrice,
    fakePhotos,
    inappropriate,
    fraud,
    other,
  ];
}
