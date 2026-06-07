import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  const AuthResult({
    required this.user,
    required this.isNewUser,
  });

  final User user;
  final bool isNewUser;
}
