import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';

class PokemonProvider with ChangeNotifier {
  List<Pokemon> _allPokemon = [];
  Set<int> _ownedPokemonIds = {};
  bool _isLoading = true;
  bool _isDarkMode = true;
  int _selectedGeneration = 1;

  List<Pokemon> get allPokemon => _allPokemon;
  Set<int> get ownedPokemonIds => _ownedPokemonIds;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get selectedGeneration => _selectedGeneration;

  List<Pokemon> get ownedPokemon =>
      _allPokemon.where((p) => _ownedPokemonIds.contains(p.id)).toList();

  List<Pokemon> get pokemonForSelectedGeneration {
    final range = idRangeForGeneration(_selectedGeneration);
    return _allPokemon
        .where((p) => p.id >= range.minId && p.id <= range.maxId)
        .toList();
  }

  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;

  PokemonProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _loadOwnedPokemon();
    await fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allPokemon = await _apiService.fetchPokemon(0, totalPokemonCount);
    } catch (e) {
      debugPrint('Error fetching Pokémon: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setGeneration(int gen) async {
    if (gen < 1 || gen > 9 || gen == _selectedGeneration) return;
    _selectedGeneration = gen;
    if (_prefs != null) {
      await _prefs!.setInt('selected_generation', gen);
    }
    notifyListeners();
  }

  Future<void> _loadOwnedPokemon() async {
    if (_prefs == null) return;
    final List<String>? ownedList = _prefs!.getStringList('owned_pokemon');
    if (ownedList != null) {
      _ownedPokemonIds = ownedList.map((e) => int.parse(e)).toSet();
    }
  }

  Future<void> toggleOwned(int id) async {
    if (_ownedPokemonIds.contains(id)) {
      _ownedPokemonIds.remove(id);
    } else {
      _ownedPokemonIds.add(id);
    }
    await _saveOwnedPokemon();
    notifyListeners();
  }

  Future<void> _saveOwnedPokemon() async {
    if (_prefs == null) return;
    final List<String> list =
        _ownedPokemonIds.map((e) => e.toString()).toList();
    await _prefs!.setStringList('owned_pokemon', list);
  }

  Future<void> clearOwnedData() async {
    _ownedPokemonIds.clear();
    await _saveOwnedPokemon();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    _isDarkMode = _prefs!.getBool('dark_mode') ?? true;
    _selectedGeneration = _prefs!.getInt('selected_generation') ?? 1;
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    if (_prefs != null) {
      await _prefs!.setBool('dark_mode', _isDarkMode);
    }
    notifyListeners();
  }
}

