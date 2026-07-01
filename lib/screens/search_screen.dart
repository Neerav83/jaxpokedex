import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.catching_pokemon,
            color: Color(0xFFED1C24),
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            'Sök',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF262238),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sök på namn eller id.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (_searchQuery.isEmpty) {
                  return const SizedBox.shrink();
                }

                final filteredList = provider.allPokemon.where((p) {
                  return p.name.toLowerCase().contains(_searchQuery) ||
                      p.id.toString() == _searchQuery;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      'Inga Pokémon hittades.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return PokemonCard(pokemon: filteredList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
