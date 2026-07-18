enum CardVariant {
  common('Common', '⚪'),
  uncommon('Uncommon', '🔷'),
  rare('Rare', '⭐'),
  holoRare('Holo Rare', '✨'),
  reverseHolo('Reverse Holo', '🔄'),
  fullArt('Full Art', '🌟'),
  rainbowRare('Rainbow Rare', '🌈'),
  goldRare('Gold/Secret', '🥇'),
  hyperRare('Hyper Rare', '💎'),
  vCard('V Card', '⚡'),
  vmaxCard('VMAX Card', '🔥'),
  megaCard('Mega Card', '💫'),
  exCard('EX Card', '💥'),
  gxCard('GX Card', '🎯'),
  shiny('Shiny', '✨'),
  promo('Promo', '🎁'),
  firstEdition('1st Edition', '👑');

  final String displayName;
  final String emoji;

  const CardVariant(this.displayName, this.emoji);

  String get key => name;

  static CardVariant fromKey(String key) {
    return CardVariant.values.firstWhere((v) => v.name == key);
  }
}

class CardCollection {
  final int pokemonId;
  final Set<CardVariant> ownedVariants;

  CardCollection({
    required this.pokemonId,
    Set<CardVariant>? ownedVariants,
  }) : ownedVariants = ownedVariants ?? {};

  bool hasVariant(CardVariant variant) {
    return ownedVariants.contains(variant);
  }

  int get variantCount => ownedVariants.length;

  bool get hasAnyVariant => ownedVariants.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'pokemonId': pokemonId,
      'ownedVariants': ownedVariants.map((v) => v.key).toList(),
    };
  }

  factory CardCollection.fromJson(Map<String, dynamic> json) {
    final variantKeys = List<String>.from(json['ownedVariants'] ?? []);
    final variants = variantKeys
        .map((key) {
          try {
            return CardVariant.fromKey(key);
          } catch (e) {
            return null;
          }
        })
        .whereType<CardVariant>()
        .toSet();

    return CardCollection(
      pokemonId: json['pokemonId'],
      ownedVariants: variants,
    );
  }
}
