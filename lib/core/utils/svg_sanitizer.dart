/// Strips Inkscape / Illustrator elements that flutter_svg cannot render.
String sanitizeSvgMarkup(String svg) {
  var result = svg;

  // Remove block elements (multiline).
  for (final tag in ['metadata', 'defs', 'filter', 'title', 'desc']) {
    result = result.replaceAll(
      RegExp('<$tag\\b[^>]*>[\\s\\S]*?</$tag>', caseSensitive: false),
      '',
    );
  }

  // Remove sodipodi / inkscape namespaced blocks and self-closing tags.
  result = result.replaceAll(
    RegExp('<(?:sodipodi|inkscape):[^>]+>[\\s\\S]*?</(?:sodipodi|inkscape):[^>]+>',
        caseSensitive: false),
    '',
  );
  result = result.replaceAll(
    RegExp('<(?:sodipodi|inkscape):[^>]*/?>', caseSensitive: false),
    '',
  );

  // Drop xmlns for unused namespaces after cleanup.
  result = result.replaceAll(
    RegExp('\\sxmlns:(?:sodipodi|inkscape|dc|rdf|cc)="[^"]*"'),
    '',
  );

  return result.trim();
}
