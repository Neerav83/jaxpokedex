import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pokemon.dart';
import '../models/card_variant.dart';
import '../services/api_service.dart';

class PokemonProvider with ChangeNotifier {
  List<Pokemon> _allPokemon = [];
  Set<int> _ownedPokemonIds = {};
  Map<int, CardCollection> _cardCollections = {};
  bool _isLoading = true;
  bool _isDarkMode = true;
  int _selectedGeneration = 1;

  List<Pokemon> get allPokemon => _allPokemon;
  Set<int> get ownedPokemonIds => _ownedPokemonIds;
  Map<int, CardCollection> get cardCollections => _cardCollections;
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

  List<Pokemon> ownedPokemonForGeneration(int generation) {
    final range = idRangeForGeneration(generation);
    return _allPokemon
        .where(
          (p) =>
              _ownedPokemonIds.contains(p.id) &&
              p.id >= range.minId &&
              p.id <= range.maxId,
        )
        .toList();
  }

  int ownedCountForGeneration(int generation) {
    final range = idRangeForGeneration(generation);
    return _ownedPokemonIds
        .where((id) => id >= range.minId && id <= range.maxId)
        .length;
  }

  int totalCountForGeneration(int generation) =>
      generationData[generation]!.count;

  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;

  PokemonProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _loadOwnedPokemon();
    await _loadCardCollections();
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
    _cardCollections.clear();
    await _saveOwnedPokemon();
    await _saveCardCollections();
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

  CardCollection getCardCollection(int pokemonId) {
    return _cardCollections[pokemonId] ??
        CardCollection(pokemonId: pokemonId);
  }

  Future<void> toggleCardVariant(int pokemonId, CardVariant variant) async {
    final collection = getCardCollection(pokemonId);
    
    if (collection.hasVariant(variant)) {
      collection.ownedVariants.remove(variant);
    } else {
      collection.ownedVariants.add(variant);
    }

    if (collection.ownedVariants.isEmpty) {
      _cardCollections.remove(pokemonId);
      _ownedPokemonIds.remove(pokemonId);
    } else {
      _cardCollections[pokemonId] = collection;
      _ownedPokemonIds.add(pokemonId);
    }

    await _saveCardCollections();
    notifyListeners();
  }

  Future<void> _loadCardCollections() async {
    if (_prefs == null) return;
    final String? collectionsJson = _prefs!.getString('card_collections');
    if (collectionsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(collectionsJson);
        _cardCollections = decoded.map((key, value) {
          final pokemonId = int.parse(key);
          return MapEntry(
            pokemonId,
            CardCollection.fromJson(value as Map<String, dynamic>),
          );
        });
        _ownedPokemonIds = _cardCollections.keys.toSet();
      } catch (e) {
        debugPrint('Error loading card collections: $e');
      }
    }
  }

  Future<void> _saveCardCollections() async {
    if (_prefs == null) return;
    final Map<String, dynamic> toSave = _cardCollections.map((key, value) {
      return MapEntry(key.toString(), value.toJson());
    });
    await _prefs!.setString('card_collections', json.encode(toSave));
    await _saveOwnedPokemon();
  }

  Future<void> clearCardCollections() async {
    _cardCollections.clear();
    _ownedPokemonIds.clear();
    await _saveCardCollections();
    notifyListeners();
  }
}

