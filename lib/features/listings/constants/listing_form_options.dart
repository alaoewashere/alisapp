/// Shared "Other" option for listing form pickers.
abstract final class ListingFormOptions {
  static const other = 'أخرى';

  static List<String> withOther(Iterable<String> options) {
    final base = options.where((o) => o != other).toList();
    if (!base.contains(other)) {
      base.add(other);
    }
    return base;
  }

  static List<String> withoutOther(Iterable<String> options) {
    return options.where((o) => o != other).toList();
  }

  static bool isCustomValue(String? value, Iterable<String> predefined) {
    if (value == null || value.trim().isEmpty) return false;
    return !withoutOther(predefined).contains(value);
  }

  static String? chipDisplayValue(String? value, Iterable<String> predefined) {
    if (isCustomValue(value, predefined)) return other;
    return value;
  }

  static String? customValueInList(
    List<String> selected,
    Iterable<String> predefined,
  ) {
    for (final item in selected) {
      if (isCustomValue(item, predefined)) return item;
    }
    return null;
  }

  static bool hasCustomInList(
    List<String> selected,
    Iterable<String> predefined,
  ) {
    return customValueInList(selected, predefined) != null;
  }

  static List<String> replaceCustomInList({
    required List<String> selected,
    required Iterable<String> predefined,
    required String? customValue,
  }) {
    final base = withoutOther(predefined);
    final kept = selected.where(base.contains).toList();
    if (customValue != null && customValue.trim().isNotEmpty) {
      kept.add(customValue.trim());
    }
    return kept;
  }
}
