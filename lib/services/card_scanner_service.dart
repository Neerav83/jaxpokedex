import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon.dart';

class ScanResult {
  final Pokemon? pokemon;
  final String? errorMessage;
  final String? detectedText;
  final double? confidence;

  ScanResult({
    this.pokemon,
    this.errorMessage,
    this.detectedText,
    this.confidence,
  });

  bool get isSuccess => pokemon != null;
}

class CardScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  static const String _pokemonTcgApiBase = 'https://api.pokemontcg.io/v2';

  Future<ScanResult> scanCard(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        return ScanResult(
          errorMessage: 'Ingen text hittades på bilden. Försök ta ett tydligare foto.',
        );
      }

      debugPrint('Detected text: ${recognizedText.text}');

      final extractedData = _extractCardInfo(recognizedText.text);
      
      if (extractedData == null) {
        return ScanResult(
          errorMessage: 'Kunde inte hitta kortnummer. Se till att kortet är tydligt synligt.',
          detectedText: recognizedText.text,
        );
      }

      final pokemon = await _searchPokemonCard(extractedData);
      
      if (pokemon != null) {
        return ScanResult(
          pokemon: pokemon,
          detectedText: recognizedText.text,
          confidence: 0.85,
        );
      } else {
        return ScanResult(
          errorMessage: 'Kortet kunde inte identifieras. Försök igen.',
          detectedText: recognizedText.text,
        );
      }
    } catch (e) {
      debugPrint('Error scanning card: $e');
      return ScanResult(
        errorMessage: 'Ett fel uppstod: $e',
      );
    }
  }

  Map<String, String>? _extractCardInfo(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    String? cardNumber;
    String? setNumber;
    String? cardName;

    final cardNumberPattern = RegExp(r'(\d+)/(\d+)');
    
    for (var line in lines) {
      final match = cardNumberPattern.firstMatch(line);
      if (match != null) {
        cardNumber = match.group(1);
        setNumber = match.group(2);
        break;
      }
    }

    if (lines.isNotEmpty) {
      cardName = lines.first;
    }

    if (cardNumber != null || cardName != null) {
      return {
        if (cardNumber != null) 'number': cardNumber,
        if (setNumber != null) 'setTotal': setNumber,
        if (cardName != null) 'name': cardName,
      };
    }

    return null;
  }

  Future<Pokemon?> _searchPokemonCard(Map<String, String> cardInfo) async {
    try {
      String query = '';
      
      if (cardInfo.containsKey('name')) {
        final name = cardInfo['name']!.toLowerCase();
        final cleanName = name
            .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
            .trim();
        query += 'name:"$cleanName"';
      }
      
      if (cardInfo.containsKey('number')) {
        if (query.isNotEmpty) query += ' ';
        query += 'number:${cardInfo['number']}';
      }

      final url = Uri.parse('$_pokemonTcgApiBase/cards?q=$query&pageSize=10');
      
      debugPrint('Searching with query: $query');
      debugPrint('URL: $url');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cards = data['data'] as List;

        if (cards.isNotEmpty) {
          final card = cards.first;
          
          return Pokemon(
            id: int.tryParse(card['nationalPokedexNumbers']?[0]?.toString() ?? '0') ?? 
                _extractIdFromCard(card['id']),
            name: card['name'] ?? 'Unknown',
            imageUrl: card['images']?['large'] ?? 
                     card['images']?['small'] ?? 
                     'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching card: $e');
    }
    return null;
  }

  int _extractIdFromCard(String cardId) {
    final match = RegExp(r'\d+').firstMatch(cardId);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '1') ?? 1;
    }
    return 1;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
