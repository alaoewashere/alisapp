/// Arabic + Arabizi normalization for profanity matching (evasion-resistant).
String normalizeArabicForModeration(String input) {
  var text = input.toLowerCase();

  // Strip tashkeel / diacritics
  text = text.replaceAll(
    RegExp(r'[\u064B-\u065F\u0670]'),
    '',
  );

  // Unify common letter variants
  const variantMap = {
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ة': 'ه',
    'ى': 'ي',
    'ؤ': 'و',
    'ئ': 'ي',
  };
  for (final entry in variantMap.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }

  final buffer = StringBuffer();
  String? prev;
  var repeatRun = 0;

  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    final isAlnum = RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(ch);
    if (!isAlnum) {
      prev = null;
      repeatRun = 0;
      continue;
    }

    if (ch == prev) {
      repeatRun++;
      if (repeatRun >= 2) continue;
    } else {
      repeatRun = 0;
    }

    buffer.write(ch);
    prev = ch;
  }

  return buffer.toString();
}

/// Maps normalized indices to original character spans for censorship.
class _NormSpan {
  const _NormSpan(this.origStart, this.origEnd);
  final int origStart;
  final int origEnd;
}

List<_NormSpan> _buildNormalizationSpans(String original) {
  final spans = <_NormSpan>[];
  var prevRune = '';
  var repeatRun = 0;

  for (var i = 0; i < original.length;) {
    final rune = original[i];
    final codeUnit = rune.codeUnitAt(0);
    if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF && i + 1 < original.length) {
      // surrogate pair — skip as single char via runes below
    }

    final normalizedChar = _normalizeSingleChar(rune);
    if (normalizedChar == null) {
      prevRune = '';
      repeatRun = 0;
      i += rune.length;
      continue;
    }

    if (normalizedChar == prevRune) {
      repeatRun++;
      if (repeatRun >= 2) {
        i += rune.length;
        continue;
      }
    } else {
      repeatRun = 0;
    }

    spans.add(_NormSpan(i, i + rune.length));
    prevRune = normalizedChar;
    i += rune.length;
  }

  return spans;
}

String? _normalizeSingleChar(String ch) {
  final lower = ch.toLowerCase();
  const variantMap = {
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ة': 'ه',
    'ى': 'ي',
    'ؤ': 'و',
    'ئ': 'ي',
  };
  final mapped = variantMap[lower] ?? lower;
  if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(mapped)) {
    return mapped;
  }
  return null;
}

String _normalizeOriginalToMatchString(String original) {
  final buffer = StringBuffer();
  for (final span in _buildNormalizationSpans(original)) {
    final ch = original.substring(span.origStart, span.origEnd);
    final norm = _normalizeSingleChar(ch);
    if (norm != null) buffer.write(norm);
  }
  return buffer.toString();
}

/// Replaces detected blocked words in [original] with asterisks of similar length.
String censorBlockedWords(String original, Iterable<String> blockedNormalized) {
  if (original.isEmpty || blockedNormalized.isEmpty) return original;

  final normalized = _normalizeOriginalToMatchString(original);
  final spans = _buildNormalizationSpans(original);
  if (normalized.isEmpty || spans.isEmpty) return original;

  final replacements = <int, int>{};

  for (final word in blockedNormalized) {
    if (word.isEmpty) continue;
    var start = 0;
    while (true) {
      final idx = normalized.indexOf(word, start);
      if (idx < 0) break;
      final end = idx + word.length;
      if (idx < spans.length && end - 1 < spans.length) {
        final origStart = spans[idx].origStart;
        final origEnd = spans[end - 1].origEnd;
        replacements[origStart] = origEnd;
      }
      start = idx + 1;
    }
  }

  if (replacements.isEmpty) return original;

  final sorted = replacements.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final out = StringBuffer();
  var cursor = 0;
  for (final entry in sorted) {
    if (entry.key < cursor) continue;
    out.write(original.substring(cursor, entry.key));
    final matchLen = entry.value - entry.key;
    out.write('*' * matchLen.clamp(3, 12));
    cursor = entry.value;
  }
  out.write(original.substring(cursor));
  return out.toString();
}

/// True when normalized [text] contains any blocked normalized form.
bool containsBlockedWord(String text, Iterable<String> blockedNormalized) {
  if (text.isEmpty) return false;
  final normalized = normalizeArabicForModeration(text);
  for (final word in blockedNormalized) {
    if (word.isNotEmpty && normalized.contains(word)) return true;
  }
  return false;
}
