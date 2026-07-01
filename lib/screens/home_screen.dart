import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'package:google_fonts/google_fonts.dart';

const List<String> _genLabels = [
  'Gen I', 'Gen II', 'Gen III', 'Gen IV', 'Gen V',
  'Gen VI', 'Gen VII', 'Gen VIII', 'Gen IX',
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
            'JaxPokédex',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Generation selector chips
          Consumer<PokemonProvider>(
            builder: (context, provider, _) {
              final colorScheme = Theme.of(context).colorScheme;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _genLabels.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final gen = index + 1;
                    final isSelected = provider.selectedGeneration == gen;
                    return GestureDetector(
                      onTap: () => provider.setGeneration(gen),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFED1C24)
                              : (isDark 
                                  ? const Color(0xFF262238) 
                                  : colorScheme.surfaceContainerHighest),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _genLabels[index],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? Colors.white 
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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

                final pokemonList = provider.pokemonForSelectedGeneration;

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
                  itemCount: pokemonList.length,
                  itemBuilder: (context, index) {
                    final pokemon = pokemonList[index];
                    return PokemonCard(pokemon: pokemon, heroScope: 'home');
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

