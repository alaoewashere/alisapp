import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When true, post-listing form widgets render embedded (no inner scroll)
/// and category breadcrumb is read-only.
class IsEditListingFormNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool enabled) => state = enabled;
}

final isEditListingFormProvider =
    NotifierProvider<IsEditListingFormNotifier, bool>(
  IsEditListingFormNotifier.new,
);
