import '../../shared/models/category_model.dart';
import '../../shared/models/general_listing_metadata.dart';
import '../../shared/models/listing_model.dart';

const generalMarketplaceRootSlug = 'buy_sell';

bool isGeneralMarketplaceCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == generalMarketplaceRootSlug;
}

GeneralListingMetadata initialGeneralDetailsForPath(List<CategoryModel> path) {
  return const GeneralListingMetadata();
}

ListingCondition? generalDbCondition(String? itemCondition) {
  return switch (itemCondition) {
    'جديد' => ListingCondition.newItem,
    'مستعمل' || 'ممتاز' || 'جيد' || 'مقبول' => ListingCondition.used,
    _ => null,
  };
}

String buildGeneralListingTitle(
  List<CategoryModel> path,
  GeneralListingMetadata details,
) {
  final parts = <String>[];
  if (details.brand != null && details.brand!.trim().isNotEmpty) {
    parts.add(details.brand!.trim());
  }
  if (path.isNotEmpty) {
    parts.add(path.last.nameAr);
  }
  return parts.isNotEmpty ? parts.join(' ') : 'إعلان سوق';
}

String buildGeneralListingDescription(GeneralListingMetadata details) {
  final lines = <String>[];

  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('الحالة', details.itemCondition);
  add('الماركة', details.brand);
  if (details.exchangePossible == true) lines.add('قابل للتبادل');
  if (details.deliveryAvailable == true) {
    lines.add('توصيل متاح');
    add('تكلفة التوصيل', details.deliveryCost);
  }

  return lines.isEmpty ? 'إعلان سوق المستعمل والجديد' : lines.join('\n');
}

Map<String, dynamic> generalMetadataForStorage(GeneralListingMetadata details) {
  return details.toJson();
}
