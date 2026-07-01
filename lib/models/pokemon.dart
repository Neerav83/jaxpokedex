class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Extract ID from url, e.g., "https://pokeapi.co/api/v2/pokemon/1/"
    final url = json['url'] as String;
    final segments = url.split('/');
    // Get the second to last segment (since there's a trailing slash)
    final idStr = segments[segments.length - 2];
    final id = int.parse(idStr);
    
    // Capitalize first letter of name
    final rawName = json['name'] as String;
    final capitalizedName = rawName[0].toUpperCase() + rawName.substring(1);

    return Pokemon(
      id: id,
      name: capitalizedName,
      // Use official artwork instead of default small sprite for better look
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }
}
