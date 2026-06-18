class ListingDensity {
  const ListingDensity({
    required this.areaName,
    required this.listingCount,
  });

  final String areaName;
  final int listingCount;

  factory ListingDensity.fromJson(Map<String, dynamic> json) {
    return ListingDensity(
      areaName: json['area_name'] as String,
      listingCount: (json['listing_count'] as num).toInt(),
    );
  }
}
