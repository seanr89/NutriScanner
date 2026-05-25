import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/nutrition_analysis.dart';
import 'services/gemini_service.dart';
import 'widgets/header.dart';
import 'widgets/loading_view.dart';
import 'widgets/results_view.dart';
import 'widgets/upload_zone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff10b981), // Premium emerald green
          primary: const Color(0xff10b981),
          secondary: const Color(0xff1e293b),
        ),
        scaffoldBackgroundColor: const Color(0xfff8fafc), // Slate 50 background
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

enum AppScanState { idle, scanning, results, error }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppScanState _appState = AppScanState.idle;
  String _apiKey = '';

  Uint8List? _selectedImageBytes;
  String _selectedMimeType = '';
  String _selectedFileName = '';

  NutritionAnalysis? _nutritionAnalysis;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Automated ingestion of Gemini API Key from environment variables loaded via .env
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  void _handlePhotoSelected(
      Uint8List bytes, String mimeType, String fileName) async {
    setState(() {
      _selectedImageBytes = bytes;
      _selectedMimeType = mimeType;
      _selectedFileName = fileName;
      _appState = AppScanState.scanning;
      _errorMessage = '';
    });

    try {
      if (_apiKey.trim().isEmpty) {
        throw Exception(
            'Gemini API Key is empty. Please open the settings panel in the header and paste your API Key, or configure it in the .env file.');
      }

      // Live API Mode: Call Gemini HTTP endpoint (targets gemini-flash-lite-latest)
      final analysis = await GeminiService.analyzeFoodImage(
        imageBytes: bytes,
        mimeType: mimeType,
        apiKey: _apiKey,
      );

      setState(() {
        _nutritionAnalysis = analysis;
        _appState = AppScanState.results;
      });
    } catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('ClientException')) {
        msg =
            'Network connection failed. Please ensure your device is connected to the internet and can resolve Google APIs. (Make sure you have restarted the app after granting Android manifest internet permissions.)';
      }
      setState(() {
        _errorMessage = msg;
        _appState = AppScanState.error;
      });
    }
  }

  void _resetScan() {
    setState(() {
      _appState = AppScanState.idle;
      _nutritionAnalysis = null;
      _selectedImageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Branding + API drawer header (Demo Mode removed)
            AppHeader(
              apiKey: _apiKey,
              onApiKeyChanged: (key) {
                setState(() {
                  _apiKey = key;
                });
              },
            ),
            // Central Content Section (State Machine)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildCurrentStateWidget(),
              ),
            ),
            // Footer (Show in idle or bottom layout)
            if (_appState == AppScanState.idle) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStateWidget() {
    switch (_appState) {
      case AppScanState.idle:
        return UploadZone(
          key: const ValueKey('upload_zone'),
          onPhotoSelected: _handlePhotoSelected,
        );
      case AppScanState.scanning:
        return LoadingView(
          key: const ValueKey('loading_view'),
          imageBytes: _selectedImageBytes!,
        );
      case AppScanState.results:
        return ResultsView(
          key: const ValueKey('results_view'),
          analysis: _nutritionAnalysis!,
          imageBytes: _selectedImageBytes!,
          onAnalyzeAnother: _resetScan,
        );
      case AppScanState.error:
        return _buildErrorView();
    }
  }

  // A gorgeous glowing error warning state card (Demo Mode buttons removed)
  Widget _buildErrorView() {
    return Center(
      key: const ValueKey('error_view'),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xfffef2f2), // Red 50
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xffef4444), // Red 500
                size: 38,
              ),
            ),
            const SizedBox(height: 24),
            // Headline
            Text(
              'Analysis Failed',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1e293b),
              ),
            ),
            const SizedBox(height: 12),
            // Detailed message
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xff64748b),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Go Back button
            OutlinedButton(
              onPressed: _resetScan,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff475569),
                side: const BorderSide(color: Color(0xffcbd5e1)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Go Back & Select Another Photo',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        '© 2026 NutriScan AI. Not medical advice. Estimates only.',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xff94a3b8), // Slate 400
        ),
      ),
    );
  }
}
