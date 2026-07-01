import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../models/card_variant.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();
    final collection = provider.getCardCollection(pokemon.id);
    final isOwned = collection.hasAnyVariant;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailScreen(pokemon: pokemon),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF262238) 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isOwned
              ? Border.all(color: const Color(0xFF4A90E2), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error, 
                            color: colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    ),
                  ),
                  if (isOwned)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFED1C24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${collection.variantCount}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                pokemon.name,
                style: GoogleFonts.plusJakartaSans(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isOwned ? Icons.check_circle : Icons.circle_outlined,
              color: isOwned 
                  ? const Color(0xFF4A90E2) 
                  : colorScheme.onSurfaceVariant.withOpacity(0.3),
              size: 20,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
