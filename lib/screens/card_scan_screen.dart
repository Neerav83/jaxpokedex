import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/card_scanner_service.dart';
import '../screens/scan_result_screen.dart';

class CardScanScreen extends StatefulWidget {
  const CardScanScreen({super.key});

  @override
  State<CardScanScreen> createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  final CardScannerService _scannerService = CardScannerService();
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _scanFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _processScan(image.path);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Kunde inte öppna kamera: $e');
      }
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _processScan(image.path);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Kunde inte öppna galleri: $e');
      }
    }
  }

  Future<void> _processScan(String imagePath) async {
    setState(() {
      _isScanning = true;
    });

    try {
      final result = await _scannerService.scanCard(imagePath);

      if (mounted) {
        setState(() {
          _isScanning = false;
        });

        if (result.isSuccess && result.pokemon != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanResultScreen(
                pokemon: result.pokemon!,
                imagePath: imagePath,
                detectedText: result.detectedText,
              ),
            ),
          );
        } else {
          _showErrorDialog(
            result.errorMessage ?? 'Kunde inte identifiera kortet. Försök igen.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showErrorDialog('Ett fel uppstod: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark 
              ? const Color(0xFF262238) 
              : colorScheme.surfaceContainerHigh,
          title: Text(
            'Kunde inte scanna',
            style: GoogleFonts.plusJakartaSans(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF4A90E2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _isScanning
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFFED1C24),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Scannar kort...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI läser texten på kortet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFFED1C24),
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Scanna Pokémon-kort',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ta ett foto av ditt Pokémon-kort så identifierar AI det automatiskt!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? const Color(0xFF262238) 
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: const Color(0xFFFFD700),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tips för bästa resultat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTip('✓', 'Ha bra belysning'),
                            _buildTip('✓', 'Håll kortet plant och rakt'),
                            _buildTip('✓', 'Se till att texten är tydlig'),
                            _buildTip('✓', 'Inkludera kortnumret (t.ex. 12/102)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _scanFromCamera,
                          icon: const Icon(Icons.camera_alt, size: 28),
                          label: Text(
                            'Ta foto med kamera',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED1C24),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton.icon(
                          onPressed: _scanFromGallery,
                          icon: const Icon(Icons.photo_library, size: 28),
                          label: Text(
                            'Välj från galleri',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4A90E2),
                            side: const BorderSide(
                              color: Color(0xFF4A90E2),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTip(String bullet, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            bullet,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
