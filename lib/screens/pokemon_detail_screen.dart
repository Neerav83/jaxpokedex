import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/pokemon.dart';
import '../models/card_variant.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;
  final String heroTag;

  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
    required this.heroTag,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, PokemonProvider provider) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'pokemon_${widget.pokemon.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${directory.path}/$fileName';
        
        await File(image.path).copy(newPath);

        if (!mounted) return;
        await provider.setCustomImage(widget.pokemon.id, newPath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Foto sparat!',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: const Color(0xFF4A90E2),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kunde inte spara foto: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeCustomImage(PokemonProvider provider) async {
    final customPath = provider.getCustomImagePath(widget.pokemon.id);
    if (customPath != null) {
      try {
        final file = File(customPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting image file: $e');
      }
      
      await provider.removeCustomImage(widget.pokemon.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Återställd till standardbild',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF4A90E2),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(PokemonProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF4A90E2)),
                title: Text(
                  'Ta foto',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF4A90E2)),
                title: Text(
                  'Välj från galleri',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, provider);
                },
              ),
              if (provider.hasCustomImage(widget.pokemon.id))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Ta bort eget foto',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeCustomImage(provider);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pokemon.name,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          final collection = provider.getCardCollection(widget.pokemon.id);
          final customImagePath = provider.getCustomImagePath(widget.pokemon.id);
          final hasCustomImage = provider.hasCustomImage(widget.pokemon.id);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: widget.heroTag,
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(20),
                        child: hasCustomImage && customImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(customImagePath),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      widget.pokemon.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.error,
                                          size: 100,
                                          color: colorScheme.onSurfaceVariant,
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            : Image.network(
                                widget.pokemon.imageUrl,
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
                                    size: 100,
                                    color: colorScheme.onSurfaceVariant,
                                  );
                                },
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 20,
                      child: FloatingActionButton.small(
                        onPressed: () => _showImageSourceDialog(provider),
                        backgroundColor: const Color(0xFF4A90E2),
                        child: Icon(
                          hasCustomImage ? Icons.edit : Icons.add_a_photo,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasCustomImage)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A90E2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_camera,
                            size: 16,
                            color: Color(0xFF4A90E2),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Eget foto',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A90E2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kortvarianter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFED1C24),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${collection.variantCount}/${CardVariant.values.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: CardVariant.values.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final variant = CardVariant.values[index];
                      final isOwned = collection.hasVariant(variant);

                      return GestureDetector(
                        onTap: () {
                          provider.toggleCardVariant(widget.pokemon.id, variant);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isOwned
                                ? const Color(0xFF1E3A5F)
                                : (isDark 
                                    ? const Color(0xFF262238) 
                                    : colorScheme.surfaceContainerHighest),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOwned
                                  ? const Color(0xFF4A90E2)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isOwned
                                      ? const Color(0xFF4A90E2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isOwned
                                        ? const Color(0xFF4A90E2)
                                        : colorScheme.onSurfaceVariant,
                                    width: 2,
                                  ),
                                ),
                                child: isOwned
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                variant.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  variant.displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
