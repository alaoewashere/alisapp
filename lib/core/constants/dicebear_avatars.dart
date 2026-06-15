/// DiceBear glyphs avatar seeds and URL builder.
abstract final class DiceBearAvatars {
  static const defaultSeed = 'Felix';

  static const seeds = [
    'Felix', 'Aneka', 'Mia', 'Zoe', 'Leo', 'Sara', 'Omar', 'Lina',
    'Noor', 'Adam', 'Maya', 'Rami', 'Hana', 'Yousef', 'Layla', 'Tariq',
    'Dina', 'Khalid', 'Rana', 'Faris', 'Sana', 'Jad', 'Reem', 'Bilal',
    'Nadia', 'Samir', 'Huda', 'Ziad', 'Aya', 'Hassan',
  ];

  static String urlFor(String seed) =>
      'https://api.dicebear.com/10.x/glyphs/svg'
      '?seed=${Uri.encodeComponent(seed)}';

  static String resolveSeed(String? seed) {
    if (seed == null || seed.trim().isEmpty) return defaultSeed;
    return seed.trim();
  }

  static bool isValidSeed(String seed) => seeds.contains(seed);
}

/// Backward-compatible aliases.
const List<String> avatarSeeds = DiceBearAvatars.seeds;

String avatarUrl(String seed) => DiceBearAvatars.urlFor(seed);

String dicebearUrl(String seed) => DiceBearAvatars.urlFor(seed);
