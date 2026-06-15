import '../../shared/models/category_model.dart';
import '../../shared/models/electronics_listing_metadata.dart';
import '../../shared/models/listing_model.dart';

const electronicsRootSlug = 'electronics';
const electronicsPhoneBranchSlug = 'elec_smartphones';
const electronicsLaptopBranchSlug = 'elec_laptops';
const electronicsTvBranchSlug = 'elec_displays';

bool isElectronicsCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == electronicsRootSlug;
}

bool _pathUnderBranch(List<CategoryModel> path, String branchSlug) {
  return path.any(
    (c) => c.slug == branchSlug || c.slug.startsWith('${branchSlug}_'),
  );
}

ElectronicsFormKind electronicsFormKind(List<CategoryModel> path) {
  if (!isElectronicsCategoryPath(path)) return ElectronicsFormKind.none;
  if (_pathUnderBranch(path, electronicsPhoneBranchSlug)) {
    return ElectronicsFormKind.phone;
  }
  if (_pathUnderBranch(path, electronicsLaptopBranchSlug)) {
    return ElectronicsFormKind.laptop;
  }
  if (_pathUnderBranch(path, electronicsTvBranchSlug)) {
    return ElectronicsFormKind.tv;
  }
  return ElectronicsFormKind.none;
}

bool hasElectronicsSubForm(List<CategoryModel> path) {
  return electronicsFormKind(path) != ElectronicsFormKind.none;
}

String _kindToListingKind(ElectronicsFormKind kind) {
  return switch (kind) {
    ElectronicsFormKind.phone => ElectronicsListingMetadata.phoneKind,
    ElectronicsFormKind.laptop => ElectronicsListingMetadata.laptopKind,
    ElectronicsFormKind.tv => ElectronicsListingMetadata.tvKind,
    ElectronicsFormKind.none => '',
  };
}

ElectronicsListingMetadata deriveElectronicsDetailsFromPath(
  List<CategoryModel> path,
  ElectronicsFormKind kind,
) {
  String? brand;
  String? model;

  for (final category in path) {
    if (category.icon == 'brand') brand = category.nameAr;
    if (category.icon == 'model') model = category.nameAr;
  }

  if (model == null && path.isNotEmpty && path.last.icon == 'model') {
    model = path.last.nameAr;
  }

  return ElectronicsListingMetadata(
    listingKind: _kindToListingKind(kind),
    brand: brand,
    model: model,
  );
}

ListingCondition? electronicsDbCondition(String? condition) {
  return switch (condition) {
    'جديد' => ListingCondition.newItem,
    'مستعمل' || 'مكسور الشاشة' => ListingCondition.used,
    _ => null,
  };
}

String buildElectronicsListingTitle(
  List<CategoryModel> path,
  ElectronicsListingMetadata details,
) {
  final parts = <String>[];
  if (details.brand != null && details.brand!.isNotEmpty) {
    parts.add(details.brand!);
  }
  if (details.model != null && details.model!.isNotEmpty) {
    parts.add(details.model!);
  }
  if (parts.isNotEmpty) return parts.join(' ');
  return path.isNotEmpty ? path.last.nameAr : 'إعلان إلكترونيات';
}

String buildElectronicsListingDescription(ElectronicsListingMetadata details) {
  final lines = <String>[];

  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('الماركة', details.brand);
  add('الموديل', details.model);
  add('التخزين', details.storage);
  add('الرام', details.ram);
  add('اللون', details.color);
  add('الحالة', details.condition);
  add('صحة البطارية', details.batteryHealth);
  if (details.hasBox == true) lines.add('مع العلبة');
  if (details.hasCharger == true) lines.add('مع الشاحن');
  add('الضمان', details.warranty);
  add('المعالج', details.processor);
  add('حجم الشاشة', details.screenSize);
  add('الدقة', details.resolution);
  if (details.smart == true) lines.add('سمарт TV');

  return lines.isEmpty ? 'إعلان إلكترونيات' : lines.join('\n');
}

Map<String, dynamic> electronicsMetadataForStorage(
  ElectronicsListingMetadata details,
) {
  return details.toJson();
}

String electronicsFormTitle(ElectronicsFormKind kind) {
  return switch (kind) {
    ElectronicsFormKind.phone => 'تفاصيل الهاتف',
    ElectronicsFormKind.laptop => 'تفاصيل اللابتوب',
    ElectronicsFormKind.tv => 'تفاصيل التلفزيون',
    ElectronicsFormKind.none => 'تفاصيل الإلكترونيات',
  };
}
