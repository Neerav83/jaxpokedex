import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

// Offset and count for each generation (1-indexed).
const Map<int, ({int offset, int count})> generationData = {
  1: (offset: 0, count: 151),
  2: (offset: 151, count: 100),
  3: (offset: 251, count: 135),
  4: (offset: 386, count: 107),
  5: (offset: 493, count: 156),
  6: (offset: 649, count: 72),
  7: (offset: 721, count: 88),
  8: (offset: 809, count: 96),
  9: (offset: 905, count: 120),
};

int get totalPokemonCount =>
    generationData.values.fold(0, (sum, gen) => sum + gen.count);

({int minId, int maxId}) idRangeForGeneration(int generation) {
  final gen = generationData[generation]!;
  return (minId: gen.offset + 1, maxId: gen.offset + gen.count);
}

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> fetchPokemon(int offset, int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> results = jsonData['results'];
        return results.map((json) => Pokemon.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load Pokémon. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
