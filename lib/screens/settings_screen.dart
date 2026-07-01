import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/statistics_section.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: SingleChildScrollView(
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
              'Profil & Inställningar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            
            // Statistics Section
            const StatisticsSection(),
            
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                thickness: 1,
              ),
            ),
            const SizedBox(height: 16),
            
            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '⚙️ Inställningar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF262238) 
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Enable Notifications',
                        style: GoogleFonts.plusJakartaSans(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Switch(
                        value: true,
                        onChanged: (val) {},
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.green,
                      ),
                    ),
                    Divider(
                      color: colorScheme.outlineVariant.withOpacity(0.3), 
                      height: 1,
                    ),
                    Consumer<PokemonProvider>(
                      builder: (context, provider, child) {
                        return ListTile(
                          title: Text(
                            'Dark Mode',
                            style: GoogleFonts.plusJakartaSans(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Switch(
                            value: provider.isDarkMode,
                            onChanged: (val) {
                              provider.toggleDarkMode();
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.grey,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF3B151A,
                            ),
                            foregroundColor: const Color(0xFFED1C24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            _showClearDataDialog(context);
                          },
                          child: Text(
                            'Clear Owned Data',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark 
            ? const Color(0xFF262238) 
            : colorScheme.surfaceContainerHigh,
        title: Text(
          'Töm data',
          style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface),
        ),
        content: Text(
          'Är du säker på att du vill ta bort alla fångade Pokémon? Detta kan inte ångras.',
          style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Avbryt',
              style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<PokemonProvider>().clearOwnedData();
              Navigator.pop(ctx);
            },
            child: Text(
              'Rensa',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFED1C24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
