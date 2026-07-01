import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();
    final isOwned = provider.ownedPokemonIds.contains(pokemon.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262238), // dark grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
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
                  return const Icon(Icons.error, color: Colors.white54);
                },
              ),
            ),
          ),
          Text(
            pokemon.name,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          IconButton(
            icon: Icon(
              isOwned ? Icons.favorite : Icons.favorite_border,
              color: isOwned ? const Color(0xFFED1C24) : Colors.white54,
              size: 20,
            ),
            onPressed: () {
              provider.toggleOwned(pokemon.id);
            },
          ),
        ],
      ),
    );
  }
}
