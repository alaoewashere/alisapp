import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/theme/app_fonts.dart';

void main() {
  test('AppFonts exposes Thmanyah family names', () {
    expect(AppFonts.sansFamily, 'ThmanyahSans');
    expect(AppFonts.serifDisplayFamily, 'ThmanyahSerifDisplay');
    expect(AppFonts.serifTextFamily, 'ThmanyahSerifText');
  });

  test('AppFonts aliases apply correct fontFamily', () {
    expect(AppFonts.cairo().fontFamily, AppFonts.sansFamily);
    expect(AppFonts.tajawal().fontFamily, AppFonts.serifTextFamily);
    expect(AppFonts.robotoMono().fontFamily, AppFonts.serifDisplayFamily);
  });
}
