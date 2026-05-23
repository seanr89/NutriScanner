import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_client/models/nutrition_analysis.dart';
import 'package:nutri_client/widgets/donut_chart.dart';
import 'package:nutri_client/widgets/header.dart';

void main() {
  group('NutritionAnalysis Model Tests', () {
    test('MacroData fromJson and toJson serialization', () {
      final jsonMap = {
        'protein': 30.5,
        'carbs': 40.0,
        'fat': 12.2,
        'fiber': 6.0,
        'sugar': 3.1,
      };

      final macro = MacroData.fromJson(jsonMap);

      expect(macro.protein, 30.5);
      expect(macro.carbs, 40.0);
      expect(macro.fat, 12.2);
      expect(macro.fiber, 6.0);
      expect(macro.sugar, 3.1);

      final backToJson = macro.toJson();
      expect(backToJson['protein'], 30.5);
      expect(backToJson['carbs'], 40.0);
      expect(backToJson['fat'], 12.2);
      expect(backToJson['fiber'], 6.0);
      expect(backToJson['sugar'], 3.1);
    });

    test('NutritionAnalysis fromJson and toJson serialization', () {
      final jsonMap = {
        'foodName': 'Avocado Salad',
        'calories': 250.0,
        'servingSize': '1 bowl',
        'macros': {
          'protein': 10.0,
          'carbs': 15.0,
          'fat': 20.0,
          'fiber': 5.0,
          'sugar': 2.0,
        },
        'vitaminsAndMinerals': ['Vitamin E', 'Potassium'],
        'healthSummary': 'Very healthy dish.',
        'confidenceScore': 90.0,
      };

      final analysis = NutritionAnalysis.fromJson(jsonMap);

      expect(analysis.foodName, 'Avocado Salad');
      expect(analysis.calories, 250.0);
      expect(analysis.servingSize, '1 bowl');
      expect(analysis.macros.protein, 10.0);
      expect(analysis.vitaminsAndMinerals.length, 2);
      expect(analysis.vitaminsAndMinerals[0], 'Vitamin E');
      expect(analysis.healthSummary, 'Very healthy dish.');
      expect(analysis.confidenceScore, 90.0);

      final backToJson = analysis.toJson();
      expect(backToJson['foodName'], 'Avocado Salad');
      expect(backToJson['calories'], 250.0);
      expect(backToJson['macros']['protein'], 10.0);
      expect(backToJson['vitaminsAndMinerals'][1], 'Potassium');
    });

    test('NutritionAnalysis fromJson with null values defaults safely', () {
      final jsonMap = <String, dynamic>{};
      final analysis = NutritionAnalysis.fromJson(jsonMap);

      expect(analysis.foodName, 'Unknown Dish');
      expect(analysis.calories, 0.0);
      expect(analysis.servingSize, '');
      expect(analysis.macros.protein, 0.0);
      expect(analysis.vitaminsAndMinerals, isEmpty);
      expect(analysis.healthSummary, '');
      expect(analysis.confidenceScore, 0.0);
    });
  });

  group('Widget UI Smoke Tests', () {
    testWidgets('AppHeader renders title and Powered by text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              apiKey: '',
              onApiKeyChanged: (_) {},
              isDemoMode: true,
              onDemoModeChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify branding items exist
      expect(find.text('NutriScan AI'), findsOneWidget);
      expect(find.text('Powered by Gemini'), findsOneWidget);
    });

    testWidgets('DonutChart renders CustomPaint child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DonutChart(
              protein: 30,
              carbs: 40,
              fat: 20,
            ),
          ),
        ),
      );

      // Verify that the DonutChart custom paints
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });
  });
}
