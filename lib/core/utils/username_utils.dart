enum UsernameState { idle, checking, available, taken, tooShort }

String normalizeUsername(String raw) => raw.trim().toLowerCase();

bool isValidUsernameLength(String username) =>
    username.length >= 3 && username.length <= 20;

bool isValidUsernameFormat(String username) =>
    RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username);
