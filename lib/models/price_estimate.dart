import 'dart:convert';

/// AI-generated price range for a vehicle listing (IQD).
class PriceEstimate {
  const PriceEstimate({
    required this.minPrice,
    required this.maxPrice,
    required this.confidence,
    required this.reasoning,
  });

  final int minPrice;
  final int maxPrice;

  /// `high`, `medium`, or `low`.
  final String confidence;
  final String reasoning;

  factory PriceEstimate.fromJson(Map<String, dynamic> json) {
    final min = _parseInt(json['min']);
    final max = _parseInt(json['max']);
    if (min == null || max == null) {
      throw const FormatException('Price estimate JSON missing min/max');
    }

    final confidence = (json['confidence'] as String?)?.trim().toLowerCase();
    if (confidence == null ||
        !{'high', 'medium', 'low'}.contains(confidence)) {
      throw const FormatException('Price estimate JSON has invalid confidence');
    }

    final reasoning = (json['reasoning'] as String?)?.trim();
    if (reasoning == null || reasoning.isEmpty) {
      throw const FormatException('Price estimate JSON missing reasoning');
    }

    return PriceEstimate(
      minPrice: min,
      maxPrice: max,
      confidence: confidence,
      reasoning: reasoning,
    );
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.replaceAll(',', '').trim());
    return null;
  }

  /// Parses model output that may include markdown fences or extra text.
  static PriceEstimate parseResponseContent(String content) {
    final trimmed = content.trim();
    final jsonText = _extractJsonObject(trimmed);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Price estimate response is not a JSON object');
    }
    return PriceEstimate.fromJson(decoded);
  }

  static String _extractJsonObject(String text) {
    final fenced = RegExp(
      r'```(?:json)?\s*(\{[\s\S]*?\})\s*```',
      multiLine: true,
    ).firstMatch(text);
    if (fenced != null) return fenced.group(1)!;

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end > start) {
      return text.substring(start, end + 1);
    }

    return text;
  }
}
