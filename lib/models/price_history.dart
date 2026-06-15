class PriceHistoryEntry {
  const PriceHistoryEntry({
    required this.id,
    required this.listingId,
    required this.oldPrice,
    required this.newPrice,
    required this.changedAt,
  });

  final String id;
  final String listingId;
  final int oldPrice;
  final int newPrice;
  final DateTime changedAt;

  int get difference => newPrice - oldPrice;

  double get percentChange =>
      oldPrice == 0 ? 0 : ((newPrice - oldPrice) / oldPrice) * 100;

  bool get isDropped => newPrice < oldPrice;

  factory PriceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PriceHistoryEntry(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      oldPrice: (json['old_price'] as num).toInt(),
      newPrice: (json['new_price'] as num).toInt(),
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }
}

/// Timeline point for the price history UI (original + each change).
class PriceHistoryPoint {
  const PriceHistoryPoint({
    required this.price,
    required this.at,
    this.changeAmount,
    this.isOriginal = false,
    this.isCurrent = false,
  });

  final int price;
  final DateTime at;
  final int? changeAmount;
  final bool isOriginal;
  final bool isCurrent;
}

class PriceHistoryData {
  const PriceHistoryData({
    required this.originalPrice,
    required this.listedAt,
    required this.changes,
    required this.timeline,
  });

  final int originalPrice;
  final DateTime listedAt;
  final List<PriceHistoryEntry> changes;
  final List<PriceHistoryPoint> timeline;

  bool get hasChanges => changes.isNotEmpty;

  int get currentPrice =>
      changes.isEmpty ? originalPrice : changes.last.newPrice;

  int get totalChangeFromOriginal => currentPrice - originalPrice;

  double get totalPercentFromOriginal => originalPrice == 0
      ? 0
      : ((currentPrice - originalPrice) / originalPrice) * 100;

  bool get overallDropped => currentPrice < originalPrice;
}

List<PriceHistoryPoint> buildPriceHistoryTimeline({
  required int originalPrice,
  required DateTime listedAt,
  required List<PriceHistoryEntry> changes,
}) {
  if (changes.isEmpty) return const [];

  final points = <PriceHistoryPoint>[
    PriceHistoryPoint(
      price: originalPrice,
      at: listedAt,
      isOriginal: true,
    ),
  ];

  for (final change in changes) {
    points.add(
      PriceHistoryPoint(
        price: change.newPrice,
        at: change.changedAt,
        changeAmount: change.difference,
      ),
    );
  }

  final last = points.last;
  points[points.length - 1] = PriceHistoryPoint(
    price: last.price,
    at: last.at,
    changeAmount: last.changeAmount,
    isCurrent: true,
  );

  return points;
}

String formatPriceHistoryDurationAr(DateTime from, DateTime to) {
  final days = to.difference(from).inDays;
  final weeks = (days / 7).floor();
  if (weeks <= 0) return 'أقل من أسبوع';
  if (weeks == 1) return 'أسبوع واحد';
  if (weeks == 2) return 'أسبوعين';
  return '$weeks أسابيع';
}
