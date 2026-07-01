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
  Map<int, String> _customImagePaths = {};
  bool _isLoading = true;
  bool _isDarkMode = true;
  int _selectedGeneration = 1;

  List<Pokemon> get allPokemon {
    return _allPokemon.map((pokemon) {
      final customPath = _customImagePaths[pokemon.id];
      if (customPath != null) {
        return pokemon.copyWith(customImagePath: customPath);
      }
      return pokemon;
    }).toList();
  }
  
  Set<int> get ownedPokemonIds => _ownedPokemonIds;
  Map<int, CardCollection> get cardCollections => _cardCollections;
  Map<int, String> get customImagePaths => _customImagePaths;
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

  int get totalOwnedCount => _ownedPokemonIds.length;

  double get overallCompletionPercentage =>
      _allPokemon.isEmpty ? 0.0 : (_ownedPokemonIds.length / _allPokemon.length) * 100;

  double completionPercentageForGeneration(int generation) {
    final total = totalCountForGeneration(generation);
    final owned = ownedCountForGeneration(generation);
    return total == 0 ? 0.0 : (owned / total) * 100;
  }

  int get totalVariantCount {
    return _cardCollections.values.fold(0, (sum, collection) => sum + collection.variantCount);
  }

  Map<CardVariant, int> get variantBreakdown {
    final Map<CardVariant, int> breakdown = {};
    for (var collection in _cardCollections.values) {
      for (var variant in collection.ownedVariants) {
        breakdown[variant] = (breakdown[variant] ?? 0) + 1;
      }
    }
    return breakdown;
  }

  int get bestGenerationIndex {
    int bestGen = 1;
    double bestPercentage = 0.0;
    for (int gen = 1; gen <= 9; gen++) {
      final percentage = completionPercentageForGeneration(gen);
      if (percentage > bestPercentage) {
        bestPercentage = percentage;
        bestGen = gen;
      }
    }
    return bestGen;
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
    final oldOwnedIds = Set<int>.from(_ownedPokemonIds);
    await _loadCardCollections();
    await _migrateOldOwnedPokemon(oldOwnedIds);
    await _loadCustomImagePaths();
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
    _customImagePaths.clear();
    await _saveOwnedPokemon();
    await _saveCardCollections();
    await _saveCustomImagePaths();
    notifyListeners();
  }

  Future<void> _loadCustomImagePaths() async {
    if (_prefs == null) return;
    final String? customImagesJson = _prefs!.getString('custom_image_paths');
    if (customImagesJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(customImagesJson);
        _customImagePaths = decoded.map((key, value) {
          return MapEntry(int.parse(key), value as String);
        });
      } catch (e) {
        debugPrint('Error loading custom image paths: $e');
      }
    }
  }

  Future<void> _saveCustomImagePaths() async {
    if (_prefs == null) return;
    final Map<String, String> toSave = _customImagePaths.map((key, value) {
      return MapEntry(key.toString(), value);
    });
    await _prefs!.setString('custom_image_paths', json.encode(toSave));
  }

  Future<void> setCustomImage(int pokemonId, String imagePath) async {
    _customImagePaths[pokemonId] = imagePath;
    await _saveCustomImagePaths();
    notifyListeners();
  }

  Future<void> removeCustomImage(int pokemonId) async {
    _customImagePaths.remove(pokemonId);
    await _saveCustomImagePaths();
    notifyListeners();
  }

  String? getCustomImagePath(int pokemonId) {
    return _customImagePaths[pokemonId];
  }

  bool hasCustomImage(int pokemonId) {
    return _customImagePaths.containsKey(pokemonId);
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

  Future<void> _migrateOldOwnedPokemon(Set<int> oldOwnedIds) async {
    if (_prefs == null || oldOwnedIds.isEmpty) return;
    
    bool needsSave = false;
    
    for (final pokemonId in oldOwnedIds) {
      if (!_cardCollections.containsKey(pokemonId)) {
        final collection = CardCollection(
          pokemonId: pokemonId,
          ownedVariants: {CardVariant.common},
        );
        _cardCollections[pokemonId] = collection;
        _ownedPokemonIds.add(pokemonId);
        needsSave = true;
        
        debugPrint('Migrated Pokemon #$pokemonId to Common variant');
      }
    }
    
    if (needsSave) {
      await _saveCardCollections();
      debugPrint('Migration complete: ${oldOwnedIds.length - _cardCollections.length} Pokemon migrated');
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

