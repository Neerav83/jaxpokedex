import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'package:google_fonts/google_fonts.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header Logo and Title
          const Icon(
            Icons.catching_pokemon,
            color: Color(0xFFED1C24),
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            'Pokédex',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                final ownedList = provider.ownedPokemon;

                if (ownedList.isEmpty) {
                  return Center(
                    child: Text(
                      'Inga ägda Pokémon ännu.',
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
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: ownedList.length,
                  itemBuilder: (context, index) {
                    final pokemon = ownedList[index];
                    return PokemonCard(pokemon: pokemon);
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
