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
}
