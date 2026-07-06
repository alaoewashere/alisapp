/// Analytics summary returned by `get_listing_analytics` RPC.
class ListingAnalytics {
  const ListingAnalytics({
    required this.totalViews,
    required this.totalContacts,
    required this.views7d,
    required this.views30d,
    this.peakHour,
    this.hourlyViews = const [],
  });

  final int totalViews;
  final int totalContacts;
  final int views7d;
  final int views30d;

  /// Hour of day (0-23) with the most views, or null if no data yet.
  final int? peakHour;

  /// Per-hour view counts for the last 7 days (may be empty).
  final List<HourlyViewCount> hourlyViews;

  double get contactRate =>
      totalViews == 0 ? 0 : totalContacts / totalViews;

  factory ListingAnalytics.fromJson(Map<String, dynamic> json) {
    final raw = json['hourly_views'];
    final hourly = (raw is List)
        ? raw
            .whereType<Map>()
            .map((e) => HourlyViewCount.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <HourlyViewCount>[];

    return ListingAnalytics(
      totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
      totalContacts: (json['total_contacts'] as num?)?.toInt() ?? 0,
      views7d: (json['views_7d'] as num?)?.toInt() ?? 0,
      views30d: (json['views_30d'] as num?)?.toInt() ?? 0,
      peakHour: (json['peak_hour'] as num?)?.toInt(),
      hourlyViews: hourly,
    );
  }
}

class HourlyViewCount {
  const HourlyViewCount({required this.hour, required this.views});

  final int hour;
  final int views;

  factory HourlyViewCount.fromJson(Map<String, dynamic> json) {
    return HourlyViewCount(
      hour: (json['hour'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }

  /// Arabic label e.g. "03:00"
  String get label {
    final h = hour.toString().padLeft(2, '0');
    return '$h:00';
  }
}
