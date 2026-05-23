import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/nutrition_analysis.dart';

class GeminiService {
  static const String _baseModel = 'gemini-flash-lite-latest';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent';

  /// Performs the actual API call to Gemini using JSON schema structure.
  static Future<NutritionAnalysis> analyzeFoodImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String apiKey,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    final payload = {
      'contents': [
        {
          'parts': [
            {
              'inlineData': {'mimeType': mimeType, 'data': base64Image},
            },
            {
              'text':
                  "Identify this food dish and provide a detailed nutritional analysis. Estimate the portion size shown. Return the data in strict JSON format matching the schema.",
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'foodName': {
              'type': 'STRING',
              'description': 'The name of the identified dish',
            },
            'calories': {
              'type': 'NUMBER',
              'description': 'Estimated total calories for the visible portion',
            },
            'servingSize': {
              'type': 'STRING',
              'description':
                  'Estimated serving size description (e.g., \'1 bowl\', \'200g\')',
            },
            'macros': {
              'type': 'OBJECT',
              'properties': {
                'protein': {
                  'type': 'NUMBER',
                  'description': 'Protein in grams',
                },
                'carbs': {
                  'type': 'NUMBER',
                  'description': 'Carbohydrates in grams',
                },
                'fat': {'type': 'NUMBER', 'description': 'Total fat in grams'},
                'fiber': {
                  'type': 'NUMBER',
                  'description': 'Dietary fiber in grams',
                },
                'sugar': {
                  'type': 'NUMBER',
                  'description': 'Total sugar in grams',
                },
              },
              'required': ['protein', 'carbs', 'fat', 'fiber', 'sugar'],
            },
            'vitaminsAndMinerals': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description': 'List of key vitamins and minerals present',
            },
            'healthSummary': {
              'type': 'STRING',
              'description':
                  'A brief 2-sentence summary of the health benefits or concerns',
            },
            'confidenceScore': {
              'type': 'NUMBER',
              'description':
                  'Confidence score from 0 to 100 regarding the food identification',
            },
          },
          'required': [
            'foodName',
            'calories',
            'servingSize',
            'macros',
            'vitaminsAndMinerals',
            'healthSummary',
            'confidenceScore',
          ],
        },
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to communicate with Gemini API: ${response.statusCode}\n${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw Exception('No analysis result received from Gemini.');
    }

    try {
      final parsedJson = jsonDecode(text);
      return NutritionAnalysis.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
        'Failed to parse nutrition analysis JSON from response: $e',
      );
    }
  }

  /// High-fidelity mock templates to support instant out-of-the-box UI demonstration.
  static final List<NutritionAnalysis> _mockDishes = [
    // Meal 1: Salmon Quinoa Bowl (Matches exactly the UI Design screenshot!)
    NutritionAnalysis(
      foodName:
          'Salmon Quinoa Bowl with Green Beans, Tomatoes, Olives, and Feta',
      calories: 480.0,
      servingSize: '1 bowl (approx. 350g)',
      macros: MacroData(
        protein: 38.0,
        carbs: 26.0,
        fat: 20.0,
        fiber: 5.0,
        sugar: 4.0,
      ),
      vitaminsAndMinerals: [
        'Omega-3 Fatty Acids',
        'Vitamin D',
        'Vitamin C',
        'Vitamin K',
        'B Vitamins',
        'Magnesium',
        'Potassium',
        'Calcium',
        'Iron',
        'Selenium',
      ],
      healthSummary:
          'This is a highly nutritious and well-balanced meal, featuring lean protein and healthy omega-3 fats from salmon. It also provides complex carbohydrates, fiber, and various vitamins and minerals from the quinoa and fresh vegetables, supporting overall health and satiety.',
      confidenceScore: 95.0,
    ),
    // Meal 2: Avocado Toast
    NutritionAnalysis(
      foodName: 'Avocado Sourdough Toast with Poached Egg and Chili Flakes',
      calories: 320.0,
      servingSize: '1 slice (approx. 180g)',
      macros: MacroData(
        protein: 14.0,
        carbs: 28.0,
        fat: 18.0,
        fiber: 8.0,
        sugar: 2.0,
      ),
      vitaminsAndMinerals: [
        'Healthy Monounsaturated Fats',
        'Vitamin E',
        'Vitamin B6',
        'Folate',
        'Lutein',
        'Potassium',
        'Calcium',
        'Iron',
        'Zinc',
      ],
      healthSummary:
          'An excellent source of healthy monounsaturated fats and dietary fiber, paired with high-quality protein from the poached egg. It provides steady, long-lasting energy and helps support cardiovascular health.',
      confidenceScore: 98.0,
    ),
    // Meal 3: Acai Berry Bowl
    NutritionAnalysis(
      foodName: 'Vibrant Berry Acai Bowl with Granola, Chia Seeds, and Coconut',
      calories: 390.0,
      servingSize: '1 bowl (approx. 300g)',
      macros: MacroData(
        protein: 8.0,
        carbs: 62.0,
        fat: 12.0,
        fiber: 11.0,
        sugar: 22.0,
      ),
      vitaminsAndMinerals: [
        'Antioxidants',
        'Vitamin C',
        'Vitamin E',
        'Omega-3 Fatty Acids',
        'Manganese',
        'Magnesium',
        'Iron',
        'Potassium',
      ],
      healthSummary:
          'Rich in powerful antioxidants and dietary fiber from berries, chia seeds, and acai. This bowl is highly energizing and helps reduce oxidative stress while promoting digestive health.',
      confidenceScore: 92.0,
    ),
  ];

  /// Simulates a network scanning delay and returns one of the premium mock analyses.
  static Future<NutritionAnalysis> getMockAnalysis(int index) async {
    await Future.delayed(const Duration(milliseconds: 3200));
    final clampedIndex = index.clamp(0, _mockDishes.length - 1);
    return _mockDishes[clampedIndex];
  }

  /// Randomly selects a mock analysis (excluding the last one if specified).
  static Future<NutritionAnalysis> getRandomMockAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    final random = Random();
    return _mockDishes[random.nextInt(_mockDishes.length)];
  }
}
