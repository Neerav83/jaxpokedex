import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'package:google_fonts/google_fonts.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

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
            'Pokédex',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final generation = index + 1;
                    final ownedCount =
                        provider.ownedCountForGeneration(generation);
                    final totalCount =
                        provider.totalCountForGeneration(generation);
                    final ownedList =
                        provider.ownedPokemonForGeneration(generation);

                    return _GenerationSection(
                      generation: generation,
                      ownedCount: ownedCount,
                      totalCount: totalCount,
                      ownedList: ownedList,
                    );
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

class _GenerationSection extends StatelessWidget {
  final int generation;
  final int ownedCount;
  final int totalCount;
  final List<Pokemon> ownedList;

  const _GenerationSection({
    required this.generation,
    required this.ownedCount,
    required this.totalCount,
    required this.ownedList,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF262238) 
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: colorScheme.onSurfaceVariant,
          collapsedIconColor: colorScheme.onSurfaceVariant,
          title: Text(
            'Gen $generation  $ownedCount/$totalCount',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          children: [
            if (ownedList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Inga ägda Pokémon i denna generation.',
                  style: GoogleFonts.plusJakartaSans(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: ownedList.length,
                itemBuilder: (context, index) {
                  return PokemonCard(
                    pokemon: ownedList[index],
                    heroScope: 'pokedex',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
