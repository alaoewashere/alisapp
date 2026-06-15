enum UsernameState { idle, checking, available, taken, tooShort }

String normalizeUsername(String raw) => raw.trim().toLowerCase();

bool isValidUsernameLength(String username) => username.length >= 3;
