/// App bar titles for the post-listing wizard steps.
String postListingStepAppBarTitle(int step) {
  final ordinal = _arabicOrdinalFeminine(step);
  if (ordinal == null) return 'الخطوة $step';
  return 'الخطوة $ordinal';
}

String? _arabicOrdinalFeminine(int step) {
  return switch (step) {
    1 => 'الأولى',
    2 => 'الثانية',
    3 => 'الثالثة',
    4 => 'الرابعة',
    5 => 'الخامسة',
    6 => 'السادسة',
    7 => 'السابعة',
    8 => 'الثامنة',
    _ => null,
  };
}
