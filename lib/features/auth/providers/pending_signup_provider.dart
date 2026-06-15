import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingSignupData {
  const PendingSignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String email;

  String get fullName => '$firstName $lastName'.trim();
}

class PendingSignupNotifier extends Notifier<PendingSignupData?> {
  @override
  PendingSignupData? build() => null;

  void set(PendingSignupData data) => state = data;

  void clear() => state = null;
}

final pendingSignupProvider =
    NotifierProvider<PendingSignupNotifier, PendingSignupData?>(
  PendingSignupNotifier.new,
);
