import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pokemon_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PokemonProvider(),
      child: const JaxPokedexApp(),
    ),
  );
}

class JaxPokedexApp extends StatelessWidget {
  const JaxPokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'JaxPokédex',
          debugShowCheckedModeBanner: false,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFED1C24),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFED1C24),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(
              0xFF130E26,
            ), // Dark purple as from design
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF130E26),
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF0F0B1E), // Darker navbar
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.white54,
            ),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
