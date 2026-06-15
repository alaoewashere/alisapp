import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/utils/svg_sanitizer.dart';

void main() {
  test('sanitizeSvgMarkup removes unsupported flutter_svg elements', () {
    const dirty = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sf.net/DTD/sodipodi-0.dtd">
  <metadata>info</metadata>
  <defs><filter id="f"/></defs>
  <sodipodi:namedview pagecolor="#ffffff"/>
  <path d="M0 0"/>
</svg>''';

    final clean = sanitizeSvgMarkup(dirty);
    expect(clean.contains('metadata'), isFalse);
    expect(clean.contains('defs'), isFalse);
    expect(clean.contains('filter'), isFalse);
    expect(clean.contains('sodipodi'), isFalse);
    expect(clean.contains('<path'), isTrue);
  });
}
